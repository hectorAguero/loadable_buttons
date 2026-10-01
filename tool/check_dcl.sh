#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir/tool/dcl"

dart run dart_code_linter:metrics analyze \
  "$project_dir/lib" "$project_dir/test" "$project_dir/example/lib" \
  --fatal-style --fatal-performance
