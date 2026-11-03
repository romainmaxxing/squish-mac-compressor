# Changelog

All notable changes to squish. Versions follow [semantic versioning](https://semver.org).

## Unreleased

- Install line moved to `curl -fsSL https://get.squish-compressor.com | bash` (the GitHub raw URL still works).
- The installer sends one anonymous ping when an install succeeds (OS, CPU type, version; no IP stored) to count
  installs. Opt out with `SQUISH_NO_PING=1`. squish itself never phones home.

## [1.0.0] - 2026-11-02

First public release.

- Videos (H.264 / H.265, quality presets, target size with two-pass encoding, max resolution, sound on/off),
  images (keep format / JPEG / WebP, max size, EXIF orientation, transparency), PDFs (Ghostscript presets)
  and audio (MP3 / AAC / Opus).
- Interactive arrow-key menus, `-y` for no questions, recursive mode, custom output folder.
- Originals never modified, results never bigger than the source, resumable after Ctrl-C.
- One-line installer without admin rights, `--update` and `--uninstall`.
- The standalone FFmpeg downloaded on Macs without Homebrew is verified by SHA-256.
