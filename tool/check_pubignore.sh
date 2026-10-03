#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

if (( $# != 0 )); then
  printf 'Usage: bash tool/check_pubignore.sh\n' >&2
  exit 1
fi

awk '
  FILENAME == ARGV[1] {patterns[$0] = 1; next}
  NF && $0 !~ /^[[:space:]]*#/ && !($0 in patterns) {
    print "Missing .pubignore pattern: " $0 > "/dev/stderr"
    missing_patterns = 1
  }
  END {exit missing_patterns}
' .pubignore .gitignore

printf 'All root .gitignore patterns are present in .pubignore.\n'
