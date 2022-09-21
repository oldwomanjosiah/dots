use std::{
    hash::{Hash, Hasher},
    path::PathBuf,
};

use futures::{pin_mut, StreamExt};
use once_cell::sync::Lazy;
use regex::Regex;

use tokio::io::AsyncBufReadExt;

const FMT_STR: &str = r#"status:{{status}},title:{{title}},artist:{{artist}},album:{{album}},length:{{mpris:length}},url:{{mpris:artUrl}}"#;
const RE_STR: &str = r#"([a-z]+):([^,]+),?"#;

const STORE_LOC: &str = "./images";
const RE_REPLACE: &str = "open.spotify.com";
const RE_REPLACE_WITH: &str = "i.scdn.co";

static PARSE_RE: Lazy<Regex> = Lazy::new(|| Regex::new(RE_STR).unwrap());

#[derive(Debug, Clone, Default, serde::Serialize)]
struct SpotifyData {
    closed: bool,
    mins: u32,
    secs: u32,
    pos_secs: u32,
    progress: f32,
    title: String,
    playing: bool,
    pos_str: Option<String>,
    artist: Option<String>,
    album: Option<String>,
    art: Option<String>,
}

fn parse(input: String) -> Option<SpotifyData> {
    let mut out = SpotifyData::default();

    for captures in PARSE_RE.captures_iter(&input) {
        let key = captures.get(1).unwrap();
        let value = captures.get(2).unwrap();

        let key_str = key.as_str();
        let val_str = value.as_str();

        match key_str {
            "url" => out.art = Some(val_str.into()),
            "title" => out.title = val_str.into(),
            "artist" => out.artist = Some(val_str.into()),
            "album" => out.album = Some(val_str.into()),
            "length" => {
                let micros = val_str.parse::<usize>().unwrap();
                let secs = micros / 1_000_000;

                out.mins = (secs / 60) as u32;
                out.secs = (secs % 60) as u32;
            }
            "status" => out.playing = val_str.eq_ignore_ascii_case("playing"),
            _ => (),
        }
    }

    if out.mins > 0 || out.secs > 0 || !out.title.is_empty() {
        Some(out)
    } else {
        None
    }
}

async fn replace_image(mut data: SpotifyData) -> SpotifyData {
    let replace = if let Some(url) = data.art {
        let url = Regex::new(RE_REPLACE)
            .unwrap()
            .replace(&url, RE_REPLACE_WITH)
            .to_string();

        let mut hash = std::collections::hash_map::DefaultHasher::new();
        url.hash(&mut hash);
        let hash = hash.finish();

        // replace open.spotify.com with i.scdn.co in the download url

        let base_path = PathBuf::from(STORE_LOC);
        std::fs::create_dir_all(&base_path).unwrap();
        let base_path = base_path.canonicalize().unwrap();

        let path = base_path.join(format!("{hash:X}"));

        if !path.exists() {
            let resp = reqwest::get(&url).await.unwrap();
            std::fs::write(&path, resp.bytes().await.unwrap()).unwrap();
        }

        Some(path.to_string_lossy().to_string())
    } else {
        None
    };

    data.art = replace;
    data
}

fn get_metadata() -> impl futures::Stream<Item = SpotifyData> {
    async_stream::stream! {
        let mut child = tokio::process::Command::new("playerctl")
            .args(["metadata", "--follow", "--player=spotify", "-f", FMT_STR])
            .stdout(std::process::Stdio::piped())
            .spawn()
            .expect("Could not spawn playerctl");

        let reader = tokio::io::BufReader::new(child.stdout.take().unwrap());

        let mut lines = reader.lines();

        while let Some(line) = lines.next_line().await.unwrap() {
            if let Some(line) = parse(line) {
                yield line;
            } else {
                break;
            }
        }
    }
}

async fn get_playtime() -> u32 {
    let output = tokio::process::Command::new("playerctl")
        .args(["position", "--player=spotify"])
        .output()
        .await
        .unwrap()
        .stdout;

    let output = std::str::from_utf8(output.as_ref()).unwrap();

    let (time, _) = output.split_once('.').unwrap();

    time.parse().unwrap()
}

#[tokio::main]
async fn main() {
    let mut latest_metadata = Option::<SpotifyData>::None;
    let mut latest_playing = false;
    let mut showing_as_playing = false;
    let mut last_pos_secs = 0;

    let meta_stream = get_metadata();

    pin_mut!(meta_stream);

    let timeout = std::time::Duration::from_secs(120);
    let track_time = std::time::Duration::from_millis(500);

    loop {
        match latest_metadata.as_mut() {
            Some(meta) if showing_as_playing => {
                meta.playing = latest_playing;
                meta.pos_secs = last_pos_secs;
                meta.progress = last_pos_secs as f32 / (meta.mins * 60 + meta.secs) as f32;

                meta.pos_str.replace(format!(
                    "{:02}:{:02}",
                    last_pos_secs / 60,
                    last_pos_secs % 60
                ));

                let out = serde_json::to_string(&meta).unwrap();
                println!("{out}");
            }
            _ => {
                let out = serde_json::to_string(&serde_json::json!({})).unwrap();
                println!("{out}");
            }
        }

        tokio::select! {
            new_meta = meta_stream.next() => {
                let new_meta = replace_image(new_meta.unwrap()).await;

                latest_playing = new_meta.playing;
                showing_as_playing = showing_as_playing || latest_playing;

                latest_metadata.replace(new_meta);
            },
            _ = tokio::time::sleep(track_time), if latest_playing => {
                let playtime = get_playtime().await;

                last_pos_secs = playtime;
            },
            _ = tokio::time::sleep(timeout), if showing_as_playing && !latest_playing => {
                showing_as_playing = false;
            }
        }
    }
}
