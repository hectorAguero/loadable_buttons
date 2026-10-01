#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

# Modern plugins are unsupported on Flutter 3.29 / Dart 3.7.
# Keep built-in rules active, and restore the IDE configuration on exit.
case "${1:-}" in
  --minimum)
    options_backup="$(mktemp)"
    cp analysis_options.yaml "$options_backup"
    trap 'cp "$options_backup" analysis_options.yaml; rm -f "$options_backup"' EXIT
    python3 - <<'PYTHON'
import re
from pathlib import Path

options = Path('analysis_options.yaml')
contents, count = re.subn(r'\nplugins:\n(?:[ \t].*\n|\n)*', '\n', options.read_text())
if count != 1:
    raise SystemExit('Expected exactly one modern plugin block')
options.write_text(contents)
PYTHON
    ;;
  '') ;;
  *) printf 'Usage: bash tool/analyze.sh [--minimum]\n' >&2; exit 1 ;;
esac

# Keep package-wide checks for pubspec and analysis-options diagnostics.
dart analyze --fatal-infos

# On Dart 3.13.4, directory analysis can miss plugin diagnostics. Explicit
# source-file targets reliably collect them in one analyzer invocation.
dart_files=()
while IFS= read -r -d '' dart_file; do
  dart_files+=("$dart_file")
done < <(find lib test example/lib -type f -name '*.dart' -print0)

if (( ${#dart_files[@]} == 0 )); then
  printf 'No Dart source files found.\n' >&2
  exit 1
fi

dart analyze --fatal-infos "${dart_files[@]}"
