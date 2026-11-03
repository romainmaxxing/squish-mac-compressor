#!/bin/bash
#
#  squish installer
#    curl -fsSL https://get.squish-compressor.com | bash
#
#  Installs the `squish` command for the current user (no sudo needed).
#

REPO="romainmaxxing/squish-mac-compressor"
NAME="squish"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/$NAME"

if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; R=$'\033[31m'; D=$'\033[2m'; N=$'\033[0m'; else B=; G=; R=; D=; N=; fi

echo ""
echo "  ${B}Installing $NAME…${N}"
mkdir -p "$BIN_DIR" || exit 1

# Use the local copy when run from a cloned/downloaded folder, otherwise download it.
# (Only when this file was run from disk: with `curl … | bash` there is no script path.)
HERE=""
[ -f "${BASH_SOURCE[0]:-}" ] && HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
if [ -n "$HERE" ] && [ -f "$HERE/$NAME" ] && head -1 "$HERE/$NAME" | grep -q bash; then
  cp "$HERE/$NAME" "$DEST"
else
  if ! curl -fsSL "https://raw.githubusercontent.com/$REPO/main/$NAME" -o "$DEST.tmp" || ! head -1 "$DEST.tmp" | grep -q bash; then
    rm -f "$DEST.tmp"; echo "  ${R}✖ Download failed.${N} Check your connection and try again."; exit 1
  fi
  mv "$DEST.tmp" "$DEST"
fi
chmod 755 "$DEST"
xattr -c "$DEST" 2>/dev/null

# Make sure ~/.local/bin is on the PATH (zsh is the default shell on macOS).
RELOAD=""
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    LINE='export PATH="$HOME/.local/bin:$PATH"'
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
      case "$rc" in
        */.zshrc) [ "$(basename "${SHELL:-}")" = zsh ] || [ -f "$rc" ] || [ "$(uname)" = Darwin ] || continue ;;
        *) [ -f "$rc" ] || continue ;;
      esac
      grep -qsF "$LINE" "$rc" || printf '\n# Added by the %s installer\n%s\n' "$NAME" "$LINE" >> "$rc"
    done
    RELOAD=1
    ;;
esac

VER="$("$DEST" --version | awk '{print $2}')"
echo "  ${G}✔ $NAME $VER installed${N} ${D}→ $DEST${N}"

# Anonymous install counter: OS, CPU and version only (no IP stored, nothing else sent).
# Opt out with SQUISH_NO_PING=1.
if [ -z "${SQUISH_NO_PING:-}" ] && [ -z "${CI:-}" ]; then
  curl -fsS -m 3 -o /dev/null "https://get.squish-compressor.com/ping?ev=install&os=$(uname -s)&arch=$(uname -m)&v=$VER" 2>/dev/null || true
fi
echo ""
if [ -n "$RELOAD" ]; then
  echo "  Open a new Terminal window, then type:  ${B}$NAME${N}"
else
  echo "  Type ${B}$NAME${N} to start  ${D}(or $NAME --help)${N}"
fi
echo ""
