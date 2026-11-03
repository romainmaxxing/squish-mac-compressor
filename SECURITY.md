# Security

squish runs locally and sends nothing anywhere. It only connects to the internet when you ask it to:

- `install.sh` and `squish --update` download `squish` from this repository (`main` branch);
- on a Mac without Homebrew, it can download a standalone FFmpeg from the npm registry
  (`@ffmpeg-installer/darwin-*`), checked against a pinned SHA-256 before use;
- Homebrew installs (`brew install ffmpeg` / `ghostscript`) only after you say yes.

You can always read the installer before running it:

```bash
curl -fsSL https://get.squish-compressor.com | less
```

## Reporting a vulnerability

Please do not open a public issue. Use **Security → Report a vulnerability** on GitHub
(private advisory). You will get an answer within a few days.
