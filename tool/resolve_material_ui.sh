#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

case "${1:-}" in
  oldest|latest) material_target="$1" ;;
  *) printf 'Usage: bash tool/resolve_material_ui.sh oldest|latest\n' >&2; exit 1 ;;
esac

# Overrides in dependencies are ignored by Pub, so pin both package roots.
# Never replace a developer's existing overrides.
for package_dir in . example; do
  if [[ -e "$package_dir/pubspec_overrides.yaml" ]]; then
    printf 'Remove existing %s/pubspec_overrides.yaml before validation.\n' "$package_dir" >&2
    exit 1
  fi
done

if [[ "$material_target" == oldest ]]; then
  trap 'rm -f pubspec_overrides.yaml example/pubspec_overrides.yaml' EXIT
  for package_dir in . example; do
    cat > "$package_dir/pubspec_overrides.yaml" <<'YAML'
dependency_overrides:
  material_ui: 1.0.0
YAML
  done
  flutter pub get --no-example
  (cd example && flutter pub get)
else
  flutter pub upgrade --unlock-transitive material_ui --no-example
  (cd example && flutter pub upgrade --unlock-transitive material_ui)
fi

# Verify the actual resolved version, including the example's independent graph.
python3 - "$material_target" <<'PYTHON'
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse

for package_dir in (Path('.'), Path('example')):
    config = (package_dir / '.dart_tool/package_config.json').resolve()
    packages = json.loads(config.read_text())['packages']
    material = next(package for package in packages if package['name'] == 'material_ui')
    uri = urljoin(config.as_uri(), material['rootUri'])
    pubspec = Path(unquote(urlparse(uri).path)) / 'pubspec.yaml'
    version = re.search(r'^version: (\S+)$', pubspec.read_text(), re.MULTILINE).group(1)
    if sys.argv[1] == 'oldest' and version != '1.0.0':
        raise SystemExit(f'{package_dir}: expected material_ui 1.0.0, resolved {version}')
    print(f'{package_dir}: material_ui {version} ({sys.argv[1]})')
PYTHON
