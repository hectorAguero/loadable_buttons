#!/usr/bin/env bash
# Regenerates the README animations in screenshots/ from tool/screenshots.
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$project_dir"

frames_dir="build/screenshots"
mkdir -p "$frames_dir"
find "$frames_dir" -name '*.png' -delete
flutter test --no-pub tool/screenshots/screenshots_test.dart

for scene in material cupertino adaptive group; do
  ffmpeg -loglevel error -y -framerate 25 -i "$frames_dir/$scene/%03d.png" \
    -vf "split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
    -loop 0 "screenshots/$scene.gif"
  printf 'screenshots/%s.gif\n' "$scene"
done
