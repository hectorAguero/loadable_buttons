#!/usr/bin/env bash
# Backward-compatible entry point; both design libraries share the SDK matrix.
set -euo pipefail
exec bash "$(dirname "${BASH_SOURCE[0]}")/resolve_design_ui.sh" "$@"
