# squish

[![CI](https://github.com/romainmaxxing/squish-mac-compressor/actions/workflows/ci.yml/badge.svg)](https://github.com/romainmaxxing/squish-mac-compressor/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-ff5faf.svg)](LICENSE)
![macOS & Linux](https://img.shields.io/badge/macOS%20%26%20Linux-bash%203.2%2B-875fff.svg)

**Compress videos, images, PDFs and audio from your terminal.** Free and open source (MIT). Point it at a folder, answer a few questions (or just hit Enter), and get everything back smaller in a `compressed` folder. Originals are never touched.

Website: **[squish-compressor.com](https://squish-compressor.com)** ([source](https://github.com/romainmaxxing/squish-compressor-web)).

```
   ███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗
   ██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║
   ███████╗██║   ██║██║   ██║██║███████╗███████║
   ╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║
   ███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║
   ╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝

┌  squish — let's make things smaller
│
◆  Which folder do you want to compress?
│  › /Users/alex/Movies/Vacation
│
●  Found 6 videos · 42 images
│
◆  How much should videos shrink?
│  ● Balanced       much smaller, no visible difference
│  ○ Strong
│  ○ Gentle
│  ○ Target size
└  ↑↓ move · enter select
…
│  beach-sunset.mov  1/48
│  ✓ ▰▰▰▱▱▱▱▱▱▱  412.6 MB → 96.3 MB  −77%  0:41
```

## Install

```bash
curl -fsSL https://get.squish-compressor.com | bash
```

Works on **macOS** and **Linux**. No admin rights needed: `squish` goes in `~/.local/bin`.
If FFmpeg or Ghostscript is missing, squish offers to install it the first time it needs it.

## Use

```bash
squish                          # asks for a folder (drag it in, or pick it in Finder)
squish ~/Movies/Trip            # compress a folder
squish clip.mov photo.heic      # or specific files
squish -y -r ~/Pictures         # everything, subfolders included, recommended settings
squish -s 25 -t video ~/Clips   # make every video fit under 25 MB (Discord, email…)
```

| | What you can choose | Tool used |
|---|---|---|
| **Videos** — mp4, mov, mkv, avi, webm… | Balanced / Strong / Gentle / **Target size** · H.264 or H.265 · 1080p/720p/480p · keep or drop sound · normal or fast | FFmpeg |
| **Images** — jpg, png, heic, webp, tiff, gif… | Keep format / JPEG / WebP · Balanced / Strong / Gentle · max 4K / 2560 / 1920 / 1280 px | macOS `sips`, FFmpeg, pngquant (if installed) |
| **PDFs** | Balanced (150 dpi) / Strong (72 dpi) / Gentle (300 dpi) | Ghostscript |
| **Audio** — wav, flac, aiff, m4a, mp3… | MP3 / AAC / Opus · Balanced / Strong / Gentle | FFmpeg |

### Options

```
-y, --yes          use the recommended settings, don't ask
-r, --recursive    include subfolders (keeps the folder structure)
-o, --output DIR   where to put results (default: "compressed" next to the originals)
-t, --type LIST    only these kinds: video,image,pdf,audio
-s, --size MB      videos: aim for this file size
    --update       update to the latest version
    --uninstall    remove squish
-h, --help         help      -V, --version   version
```

### Good to know

- **Nothing is ever overwritten.** Results go to a `compressed` folder (or `-o`).
- **Never bigger.** If a file wouldn't get smaller, the original is copied as is.
- **Resumable.** Stop with Ctrl-C, run again: finished files are skipped.
- Photos are rotated correctly, keep their dates, and transparent PNGs stay transparent (except in JPEG, where the background becomes white).
- Errors are written to `.squish-errors.log` in the output folder.

## Requirements

- macOS (any recent version, Apple Silicon or Intel) or Linux, with `bash` 3.2 or later and `curl`.
- [FFmpeg](https://ffmpeg.org) for videos, audio and most images. If it is missing, squish offers
  `brew install ffmpeg`, or on a Mac without Homebrew a standalone FFmpeg (~20 MB, checksum-verified) kept in
  `~/.squish`. On Linux: `sudo apt install ffmpeg` (or your distribution's package).
- [Ghostscript](https://ghostscript.com) for PDFs (`brew install ghostscript` / `sudo apt install ghostscript`).
- Optional: [pngquant](https://pngquant.org) for much smaller PNGs (`brew install pngquant`).

On a Mac, JPEG and HEIC photos are handled by `sips`, which is built into macOS.

## What the presets do

| | Balanced (default) | Strong | Gentle |
|---|---|---|---|
| **Video** H.264 / H.265 | CRF 24 / 28 | CRF 28 / 32 | CRF 20 / 24 |
| **Images** | quality 80 | quality 62 | quality 90 |
| **PDF** (images inside) | 150 dpi | 72 dpi | 300 dpi |
| **Audio** MP3 / AAC / Opus | 160 / 128 / 96 kbps | 96 / 80 / 48 kbps | 256 / 192 / 160 kbps |

**Target size** (`-s 25`) computes the bitrate from the video length and encodes in two passes, so the file
lands just under the limit. Videos already under the limit get the Balanced treatment.

## Troubleshooting

- **`squish: command not found`** right after installing: open a new Terminal window (the installer added
  `~/.local/bin` to your PATH in `~/.zshrc`).
- **A file shows `couldn't compress this file`**: details are in `.squish-errors.log` in the output folder
  (often a damaged or password-protected file).
- **No colours / no arrow keys**: when squish is not in a real terminal (or with `NO_COLOR=1`), it falls back
  to plain text and numbered menus — type the number and press Enter.
- **iPhone HDR videos look a little washed out**: squish encodes in 8-bit SDR for maximum compatibility;
  keep the originals of HDR clips you care about.

## Uninstall

```bash
squish --uninstall
```

## Contributing

Bug reports, ideas and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
The whole program is one readable bash script: [`squish`](squish).
The website lives in its own repo: [squish-compressor-web](https://github.com/romainmaxxing/squish-compressor-web).

## License

MIT — see [LICENSE](LICENSE). squish drives [FFmpeg](https://ffmpeg.org), [Ghostscript](https://ghostscript.com) and [pngquant](https://pngquant.org), which are separate projects with their own licenses.
