use std::{hash::Hash, io::Write, path::PathBuf, time::Duration};

use futures::{pin_mut, Future, Stream, StreamExt};
use once_cell::sync::Lazy;
use regex::Regex;

use anyhow::Context;
use serde::ser::SerializeStruct;
use tokio::io::BufReader;
use tokio::{io::AsyncBufReadExt, select};
use tracing::Span;
use tracing_futures::Instrument;

static FMT_STR: &'static str = r#"status:{{status}},title:{{title}},artist:{{artist}},album:{{album}},length:{{mpris:length}},url:{{mpris:artUrl}},position:{{position}}"#;

static PARSE_RE: Lazy<Regex> = Lazy::new(|| Regex::new(r#"([a-z]+):([^,]+),?"#).unwrap());

static NAME: &str = env!("CARGO_BIN_NAME");
static VERSION: &str = env!("CARGO_PKG_VERSION");

macro_rules! hash {
    ($($it:expr),+ $(,)?) => {{
        let mut hasher = ::std::collections::hash_map::DefaultHasher::new();

        $(::std::hash::Hash::hash(&($it), &mut hasher);)*

        ::std::hash::Hasher::finish(&hasher)
    }};
}

#[derive(Debug)]
pub struct Playerctl {
    span: tracing::Span,
}

impl Playerctl {
    pub fn new() -> Self {
        Self {
            span: tracing::info_span!("playerctl"),
        }
    }

    pub fn start_watching(&self) -> anyhow::Result<impl Stream<Item = String>> {
        let stream_span = self.span.in_scope(|| {
            tracing::info!("Building Metadata Child");
            tracing::info_span!("watch_child")
        });

        let mut child = tokio::process::Command::new("playerctl")
            .args(["metadata", "--follow", "--player=spotify", "-f", FMT_STR])
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::piped())
            .stdin(std::process::Stdio::null())
            .spawn()
            .context("Spawning playerctl")?;

        let stdout_reader = BufReader::new(child.stdout.take().unwrap());
        let stderr_reader = BufReader::new(child.stderr.take().unwrap());

        let inner = async_stream::stream! {
            tracing::info!("Starting");
            let mut stdout_lines = stdout_reader.lines();
            let mut stderr_lines = stderr_reader.lines();

            loop {
                select! {
                    Ok(Some(line)) = stdout_lines.next_line() => {
                        tracing::trace!("Got new line: {line}");
                        yield line;
                    },
                    Ok(Some(line)) = stderr_lines.next_line() => {
                        tracing::warn!("Got stderr line:\n{line}");
                    },
                    exit = child.wait() => {
                        tracing::error!("Child Exited with {exit:#?}");
                        break;
                    },
                }
            }

            tracing::warn!("Exiting!");
        };

        Ok(tracing_futures::Instrument::instrument(inner, stream_span))
    }
}

#[derive(Debug, Clone, Copy, Hash)]
struct InputData<'a> {
    pub playing: bool,
    pub title: &'a str,
    pub artist: &'a str,
    pub album: &'a str,
    pub length: &'a str,
    pub position: &'a str,
    pub art_url: &'a str,
}

#[derive(Debug, Clone, Default, serde::Serialize)]
struct SpotifyOutput {
    pub title: String,
    pub artist: String,
    pub album: String,
    pub length: TimeStamp,
    pub position: TimeStamp,
    pub progress: f64,
    pub art_path: Option<PathBuf>,
}

impl SpotifyOutput {
    pub fn same_song(&self, input: &InputData<'_>) -> bool {
        self.title == input.title && self.artist == input.artist && self.album == input.album
    }

    pub fn update(&mut self, input: &InputData<'_>) -> bool {
        let changed = !self.same_song(input);

        if self.title != input.title {
            self.title = input.title.into();
        }

        if self.artist != input.artist {
            self.artist = input.artist.into();
        }

        if self.album != input.album {
            self.album = input.album.into();
        }

        match TimeStamp::from_millis(input.length) {
            Ok(ts) => self.length = ts,
            Err(e) => tracing::warn!("Not updating length field: {e}"),
        }

        match TimeStamp::from_millis(input.position) {
            Ok(ts) => self.position = ts,
            Err(e) => tracing::warn!("Not updating position field: {e}"),
        }

        self.progress = self.position / self.length;

        if changed {
            self.art_path = None;
        }

        changed
    }
}

#[derive(Debug, Clone, Default, serde::Serialize)]
struct OutputData {
    pub playing: bool,
    pub open: bool,
    pub song: Option<SpotifyOutput>,
}

impl OutputData {
    pub fn update(&mut self, input: &InputData<'_>) -> bool {
        let song_changed = match self.song.as_mut() {
            Some(data) => data.update(input),
            None => {
                let mut new = SpotifyOutput::default();
                new.update(input);
                self.song = Some(new);
                true
            }
        };

        self.playing = input.playing;
        self.open = self.open || self.playing;

        song_changed
    }

    pub fn update_url(&mut self, path: PathBuf) {
        if let Some(art_path) = self.song.as_mut().map(|it| &mut it.art_path) {
            *art_path = Some(path);
        }
    }

    pub fn emit(&self) -> anyhow::Result<()> {
        let mut out = std::io::stdout().lock();

        serde_json::to_writer(&mut out, self).context("Serializing data to stdout")?;
        write!(&mut out, "\n")?;

        Ok(())
    }
}

impl<'a> InputData<'a> {
    const NONE: &'static str = "";

    fn empty() -> Self {
        Self {
            playing: false,
            title: Self::NONE,
            artist: Self::NONE,
            album: Self::NONE,
            length: Self::NONE,
            position: Self::NONE,
            art_url: Self::NONE,
        }
    }

    pub fn from_input(input: &'a str) -> Self {
        let mut out = Self::empty();

        for captures in PARSE_RE.captures_iter(&input) {
            let key = captures.get(1).unwrap();
            let value = captures.get(2).unwrap();

            let key_str = key.as_str();
            let val_str = value.as_str();

            match key_str {
                "url" => out.art_url = val_str,
                "title" => out.title = val_str,
                "artist" => out.artist = val_str,
                "album" => out.album = val_str,
                "length" => out.length = val_str,
                "position" => out.position = val_str,
                "status" => out.playing = val_str.eq_ignore_ascii_case("playing"),
                _ => (),
            }
        }

        out
    }
}

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
struct TimeStamp {
    pub min: u16,
    pub sec: u16,
    pub millis: u16,
}

impl TimeStamp {
    const MIC_CONV: usize = 1_000_000;
    const MIL_CONV: usize = 1_000;
    const SEC_CONV: usize = 60;

    pub fn from_millis(millis: &str) -> anyhow::Result<Self> {
        let micros: usize = millis.parse().context("Parsing as timestamp")?;

        tracing::debug!("Got millis {millis}");

        let it = Self {
            min: ((micros / Self::MIC_CONV) / Self::SEC_CONV) as _,
            sec: ((micros / Self::MIC_CONV) % Self::SEC_CONV) as _,
            millis: (micros / Self::MIL_CONV % Self::MIL_CONV) as _,
        };

        tracing::debug!("Parsed as {it:?}");

        Ok(it)
    }
}

impl serde::Serialize for TimeStamp {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        let mut out = serializer.serialize_struct("TimeStamp", 4)?;
        out.serialize_field("min", &self.min)?;
        out.serialize_field("sec", &self.sec)?;
        out.serialize_field("millis", &self.millis)?;
        out.serialize_field("formatted", &format!("{:02}:{:02}", self.min, self.sec))?;
        out.end()
    }
}

impl std::ops::Div for TimeStamp {
    type Output = f64;

    fn div(self, rhs: Self) -> Self::Output {
        let divident =
            (self.min as f64 * 60.0 * 1000.0) + (self.sec as f64 * 1000.0) + (self.millis as f64);

        let divisor =
            (rhs.min as f64 * 60.0 * 1000.0) + (rhs.sec as f64 * 1000.0) + (rhs.millis as f64);

        divident / divisor
    }
}

#[derive(Debug)]
pub struct CoverArtCache {
    span: Span,
    cache_dir: PathBuf,
    replacement: Regex,
}

impl CoverArtCache {
    const CDN_URL: &'static str = "i.scdn.co";

    pub fn new(cache_dir: impl Into<PathBuf>) -> anyhow::Result<Self> {
        let cache_dir = cache_dir
            .into()
            .canonicalize()
            .context("Canonicalizing cache dir")?;
        std::fs::create_dir_all(&cache_dir).context("Creating Cache Dir")?;
        Ok(Self {
            span: tracing::info_span!("cover_art_cache", loc = %cache_dir.display()),
            cache_dir,
            replacement: Regex::new(r#"open\.spotify\.com"#).unwrap(),
        })
    }

    pub fn get(&self, input: &str) -> impl Future<Output = anyhow::Result<PathBuf>> {
        let working_span = self
            .span
            .in_scope(|| tracing::info_span!("Getting File", url = %input));

        let hash_key = format!("{}", hash!(input));
        let cached_name = {
            let mut it = self.cache_dir.clone();
            it.push(&hash_key);
            it
        };
        let real_url = self.replacement.replace(input, Self::CDN_URL).to_string();

        async move {
            tracing::trace!("Hash Key: {hash_key}");

            if cached_name.exists() {
                tracing::info!("File already cached, returning it");
                return Ok(cached_name);
            }

            tracing::info!("Downloading new file");

            let download_res = reqwest::get(&real_url).await.context("Downloading Image")?;

            tracing::info!("Download Finished");

            std::fs::write(
                &cached_name,
                download_res
                    .bytes()
                    .await
                    .context("Getting Download Contents")?,
            )
            .context("Writing downlaod to disk")?;

            tracing::info!("Write to disk complete");

            Ok(cached_name)
        }
        .instrument(working_span)
    }
}

#[derive(Debug)]
pub struct Watcher {
    timeout: Duration,
    playerctl: Playerctl,
    cache: CoverArtCache,
}

async fn optional<F: Future + std::marker::Unpin>(it: &mut Option<F>) -> Option<F::Output> {
    match it.as_mut() {
        Some(it) => Some(it.await),
        None => None,
    }
}

impl Watcher {
    pub fn new(timeout: Duration, cache_dir: impl Into<PathBuf>) -> anyhow::Result<Self> {
        let playerctl = Playerctl::new();
        let cache = CoverArtCache::new(cache_dir.into()).context("Creating Cache")?;

        Ok(Self {
            timeout,
            playerctl,
            cache,
        })
    }

    pub fn run(self) -> impl Future<Output = anyhow::Result<()>> {
        let task_span = tracing::info_span!("watcher");

        async move {
            tracing::info!("Starting");
            let mut output = OutputData::default();
            let mut download_fut = None;

            let data_stream = self
                .playerctl
                .start_watching()
                .context("Starting watcher stream")?;

            pin_mut!(data_stream);

            loop {
                output.emit().context("Writing Output")?;

                select! {
                    Some(line) = data_stream.next() => {
                        let data = InputData::from_input(&line);

                        if output.update(&data) {
                            // Needs update, start a download
                            download_fut = Some(Box::pin(self.cache.get(data.art_url)));
                        }
                    }
                    Some(url) = optional(&mut download_fut) => {
                        match url {
                            Ok(url) => output.update_url(url),
                            Err(e) => tracing::warn!("Could not download image: {}", e),
                        }
                        download_fut = None;
                    }
                    _ = tokio::time::sleep(self.timeout), if !output.playing && output.open => {
                        tracing::info!("Closing bar due to timeout");
                        output.open = false;
                    }
                    else => {
                        break;
                    }
                }
            }

            tracing::info!("Exiting");
            Ok(())
        }
        .instrument(task_span)
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .with_writer(|| std::io::stderr())
        .init();

    tracing::info!("Staring {NAME} ({VERSION})");

    Watcher::new(Duration::from_secs(120), "./images")
        .context("Building Watcher")?
        .run()
        .await
        .context("Running Watcher")?;

    Ok(())
}
