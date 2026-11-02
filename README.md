# squish

**Compress videos, images, PDFs and audio from your terminal.** Free and open source (MIT). Point it at a folder, answer a few questions (or just hit Enter), and get everything back smaller in a `compressed` folder. Originals are never touched.

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
curl -fsSL https://raw.githubusercontent.com/romainmaxxing/squish-mac-compressor/main/install.sh | bash
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

## Uninstall

```bash
squish --uninstall
```

## License

MIT — see [LICENSE](LICENSE). squish drives [FFmpeg](https://ffmpeg.org), [Ghostscript](https://ghostscript.com) and [pngquant](https://pngquant.org), which are separate projects with their own licenses.
