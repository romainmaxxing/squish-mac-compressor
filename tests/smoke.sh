#!/bin/bash
#
#  Smoke test: builds a folder of sample files, runs squish on it and checks the results.
#    bash tests/smoke.sh            (needs ffmpeg and ghostscript; uses the bash it is run with)
#
SQUISH="$(cd "$(dirname "$0")/.." && pwd)/squish"
SH="${BASH:-bash}"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
FAILS=0
ok()   { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; FAILS=$((FAILS + 1)); }
check() { if eval "$2"; then ok "$1"; else fail "$1"; fi; }
ff() { ffmpeg -nostdin -v error -y "$@"; }
size() { wc -c < "$1" | tr -d ' '; }

echo "squish smoke test — $("$SH" --version | head -1)"
mkdir -p "$T/in/sub"
ff -f lavfi -i testsrc2=s=1280x720:r=30:d=4 -f lavfi -i sine=d=4 -c:v libx264 -crf 8 -c:a pcm_s16le "$T/in/clip.mov"
ff -f lavfi -i mandelbrot=s=2400x1600 -frames:v 1 -q:v 1 "$T/in/photo.jpg"
ff -f lavfi -i "testsrc2=s=640x480,format=rgba,geq=r='X':g='Y':b=128:a='if(gt(X,320),255,0)'" -frames:v 1 "$T/in/alpha.png"
ff -f lavfi -i mandelbrot=s=1200x900 -frames:v 1 "$T/in/scan.tiff"
ff -f lavfi -i sine=f=300:d=10 -ac 2 "$T/in/voice.wav"
cp "$T/in/photo.jpg" "$T/in/sub/"
gs -q -sDEVICE=pdfwrite -o "$T/in/doc.pdf" -c "/Helvetica findfont 30 scalefont setfont 72 700 moveto (squish) show showpage"
( cd "$T/in" && find . -type f -exec cksum {} + | sort ) > "$T/before"

# 1. everything, recursive, recommended settings
"$SH" "$SQUISH" -y -r "$T/in" > "$T/run1.log" 2>&1
check "exit code 0"                  '[ $? -eq 0 ]'
O="$T/in/compressed"
check "video → mp4, smaller"         '[ -s "$O/clip.mp4" ] && [ $(size "$O/clip.mp4") -lt $(size "$T/in/clip.mov") ]'
check "jpeg smaller"                 '[ $(size "$O/photo.jpg") -lt $(size "$T/in/photo.jpg") ]'
check "tiff → jpg"                   '[ -s "$O/scan.jpg" ]'
check "png stays png"                '[ -s "$O/alpha.png" ]'
check "wav → mp3"                    '[ -s "$O/voice.mp3" ]'
check "pdf present"                  '[ -s "$O/doc.pdf" ]'
check "subfolder kept"               '[ -s "$O/sub/photo.jpg" ]'
check "originals untouched"          '( cd "$T/in" && find . -path ./compressed -prune -o -type f -exec cksum {} + | sort ) | cmp -s - "$T/before"'

# 2. resume: nothing is redone
"$SH" "$SQUISH" -y -r "$T/in" > "$T/run2.log" 2>&1
check "second run skips everything"  'grep -q "already done earlier, skipped" "$T/run2.log" && ! grep -q "✓" "$T/run2.log"'

# 3. target size
"$SH" "$SQUISH" -y -s 1 -o "$T/target" "$T/in/clip.mov" > /dev/null 2>&1
check "target size ≤ 1 MB"           '[ -s "$T/target/clip.mp4" ] && [ $(size "$T/target/clip.mp4") -le 1048576 ]'

# 4. output into the source folder never overwrites an original
mkdir "$T/same" && cp "$T/in/photo.jpg" "$T/same/" && a=$(cksum < "$T/same/photo.jpg")
"$SH" "$SQUISH" -y -o "$T/same" "$T/same" > /dev/null 2>&1
check "-o = source folder is safe"   '[ "$(cksum < "$T/same/photo.jpg")" = "$a" ] && [ -s "$T/same/photo-2.jpg" ]'

# 5. background mode and the Mac's video chip (falls back to the normal encoder when there is none)
"$SH" "$SQUISH" -y -b -o "$T/bg" "$T/in/clip.mov" > /dev/null 2>&1
check "-b (background) video"        '[ -s "$T/bg/clip.mp4" ] && [ $(size "$T/bg/clip.mp4") -lt $(size "$T/in/clip.mov") ]'
"$SH" "$SQUISH" -y --hardware -o "$T/hw" "$T/in/clip.mov" > /dev/null 2>&1
check "--hardware video"             '[ -s "$T/hw/clip.mp4" ] && [ $(size "$T/hw/clip.mp4") -lt $(size "$T/in/clip.mov") ]'

# 6. time estimate (only for more than a minute of video)
ff -f lavfi -i testsrc2=s=320x180:r=25:d=70 -c:v libx264 -crf 10 "$T/long.mov"
"$SH" "$SQUISH" -y -o "$T/est" "$T/long.mov" > "$T/est.log" 2>&1
check "time estimate in the plan"    'grep -q "time .*about .* for the videos" "$T/est.log" && [ -s "$T/est/long.mp4" ]'

# 7. command line
check "--version"                    '"$SH" "$SQUISH" --version | grep -q "^squish [0-9]"'
check "--help"                       '"$SH" "$SQUISH" --help | grep -q Usage'
"$SH" "$SQUISH" --bogus > /dev/null 2>&1
check "unknown option → exit 2"      '[ $? -eq 2 ]'

echo ""
[ $FAILS -eq 0 ] && { echo "all good"; exit 0; }
echo "$FAILS check(s) failed — log of the first run:"; tail -40 "$T/run1.log"; exit 1
