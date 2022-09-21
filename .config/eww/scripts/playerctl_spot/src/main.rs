use std::{
    hash::{Hash, Hasher},
    io::{BufRead, BufReader, Write},
    path::PathBuf,
    process::ChildStdout,
};

use futures::{pin_mut, StreamExt};
use regex::Regex;
use reqwest::Method;
use tokio::io::AsyncBufReadExt;

const FMT_STR: &'static str = r#"status:{{status}},title:{{title}},artist:{{artist}},album:{{album}},length:{{mpris:length}},url:{{mpris:artUrl}}"#;
const RE_STR: &'static str = r#"([a-z]+):([^,]+),?"#;

const STORE_LOC: &'static str = "./images";
const RE_REPLACE: &'static str = "open.spotify.com";
const RE_REPLACE_WITH: &'static str = "i.scdn.co";

#[derive(Debug, Clone, serde::Serialize)]
#[serde(untagged)]
enum Response {
    Data(SpotifyData),
    None { closed: bool },
}

#[derive(Debug, Clone, Default, serde::Serialize)]
struct SpotifyData {
    closed: bool,
    mins: u32,
    secs: u32,
    title: String,
    playing: bool,
    artist: Option<String>,
    album: Option<String>,
    art: Option<String>,
}

fn parse(input: String) -> Option<SpotifyData> {
    let re = Regex::new(RE_STR).unwrap();

    let mut out = SpotifyData::default();

    for captures in re.captures_iter(&input) {
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

        while let Ok(Some(line)) = lines.next_line().await {
            if let Some(line) = parse(line) {
                yield line;
            } else {
                break;
            }
        }
    }
}

fn get_playing() -> impl futures::Stream<Item = bool> {
    async_stream::stream! {
        yield false;

        let mut child = tokio::process::Command::new("playerctl")
            .args(["status", "--follow", "--player=spotify"])
            .stdout(std::process::Stdio::piped())
            .spawn()
            .expect("Could not spawn playerctl");

        let reader = tokio::io::BufReader::new(child.stdout.take().unwrap());

        let mut lines = reader.lines();

        while let Ok(Some(line)) = lines.next_line().await {
            yield line.eq_ignore_ascii_case("Playing");
        }
    }
}

#[tokio::main]
async fn main() {
    let mut latest_metadata = Option::<SpotifyData>::None;
    let mut latest_playing = false;
    let mut showing_as_playing = false;

    let meta_stream = get_metadata();
    let playing_stream = get_playing();

    pin_mut!(meta_stream);
    pin_mut!(playing_stream);

    let timeout = std::time::Duration::from_secs(10);

    loop {
        match latest_metadata.as_mut() {
            Some(meta) if showing_as_playing => {
                meta.playing = latest_playing;

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

                latest_metadata.replace(new_meta);
            },
            new_playing = playing_stream.next() => {
                let new_playing = new_playing.unwrap();
                latest_playing = new_playing;
                showing_as_playing = true;
            },
            _ = tokio::time::sleep(timeout), if showing_as_playing && !latest_playing => {
                showing_as_playing = false;
            }
        }
    }
}
