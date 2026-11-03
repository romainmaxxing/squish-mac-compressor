# Contributing to squish

Thanks for helping! squish is deliberately small: **one bash script**, no build step, no runtime besides
the tools it drives. Please keep it that way.

## Ground rules

- **Bash 3.2.** macOS still ships bash 3.2 as `/bin/bash`, and that is what squish runs with. No
  associative arrays, no `${var,,}`, no `mapfile`, no `|&`, no negative array indexes.
- **Originals are never modified.** Every result is written to a temporary `.part` file, then moved into
  the output folder. Never write next to an input under its own name.
- **Never bigger.** If the result is not smaller, the original is copied as is.
- **Sensible defaults.** Option 1 of every menu is the recommended one, and `-y` must always give a good
  result without any question.
- **No new hard dependency.** FFmpeg (videos, audio, most images) and Ghostscript (PDFs) are offered on
  first use. Anything else must stay optional (like pngquant).

## Running it from a clone

```bash
git clone https://github.com/romainmaxxing/squish-mac-compressor.git
cd squish-mac-compressor
./squish ~/some/folder          # run without installing
bash install.sh                 # install this copy in ~/.local/bin
```

## Tests

```bash
bash tests/smoke.sh             # needs ffmpeg and ghostscript
/bin/bash tests/smoke.sh        # on a Mac: the same with Apple's bash 3.2
shellcheck squish install.sh    # lint
```

The smoke test builds sample files (video, JPEG, transparent PNG, TIFF, WAV, PDF), runs squish on them
and checks sizes, formats, resume, target size and that originals are untouched. CI runs it on Ubuntu
and macOS for every pull request.

Things the CI cannot check, to try by hand when you touch them: the arrow-key menus in Terminal.app and
iTerm2, drag-and-drop of a folder into the window, the Finder folder picker (`osascript`), iPhone
photos (HEIC and rotated JPEG), and the `compressed` folder opening at the end.

## How the script is organised

`squish` reads top to bottom:

| Section | What it does |
|---|---|
| look & feel | colours (256 / 16 / none, `NO_COLOR` respected), the rail (`r_*`), logo, progress bars |
| questions | `menu` (arrow keys, or numbers when there is no terminal), `confirm`, `ask_number` |
| dependencies | `need_ffmpeg` (Homebrew, or a standalone FFmpeg checked by SHA-256), `need_gs` |
| files | `clean_path` (paths dragged from Finder), `kind_of`, `add_folder`, `dest_for` (output name, no collisions) |
| video / images / PDF / audio | for each kind: `*_settings` (questions), `*_summary` (one line), `compress_*` (the work) |
| main | options, file discovery, questions, the plan, the loop, the final score |

A `compress_*` function gets `in out` and returns **0** (done), **3** (nothing useful to do: keep the
original) or anything else (failure, logged to `.squish-errors.log`).

### Adding a format

1. Add the extension to `VIDEO_EXT`, `IMAGE_EXT`, `PDF_EXT` or `AUDIO_EXT`.
2. If it needs special handling, add a case in `image_target_ext` / `compress_image` (or the matching
   function).
3. Add a sample to `tests/smoke.sh`.

## Releasing

1. Bump `VERSION="…"` at the top of `squish` (the website shows the version too; it is updated
   separately).
2. Add an entry to `CHANGELOG.md`.
3. Push to `main`, then create a GitHub release `vX.Y.Z`.

Users get it with `squish --update` (it downloads `squish` from `main`), so **`main` must always work**.

## Pull requests

Small and focused is best. Describe what you tested (OS, bash version, file types). For a bigger change
(a new kind of file, a new menu), open an issue first so we can agree on the defaults.
