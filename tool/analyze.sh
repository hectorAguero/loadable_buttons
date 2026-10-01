#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

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
