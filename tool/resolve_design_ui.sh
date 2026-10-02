#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

case "${1:-}" in
  oldest|latest) design_target="$1" ;;
  *) printf 'Usage: bash tool/resolve_design_ui.sh oldest|latest\n' >&2; exit 1 ;;
esac

# Overrides in dependencies are ignored by Pub, so pin both package roots.
# Never replace a developer's existing overrides.
for package_dir in . example; do
  if [[ -e "$package_dir/pubspec_overrides.yaml" ]]; then
    printf 'Remove existing %s/pubspec_overrides.yaml before validation.\n' "$package_dir" >&2
    exit 1
  fi
done

if [[ "$design_target" == oldest ]]; then
  trap 'rm -f pubspec_overrides.yaml example/pubspec_overrides.yaml' EXIT
  for package_dir in . example; do
    cat > "$package_dir/pubspec_overrides.yaml" <<'YAML'
dependency_overrides:
  material_ui: 1.0.0
  cupertino_ui: 1.0.0
YAML
  done
  flutter pub get --no-example
  (cd example && flutter pub get)
else
  flutter pub upgrade --unlock-transitive material_ui cupertino_ui --no-example
  (cd example && flutter pub upgrade --unlock-transitive material_ui cupertino_ui)
fi

# Verify the actual resolved version, including the example's independent graph.
python3 - "$design_target" <<'PYTHON'
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse

for package_dir in (Path('.'), Path('example')):
    config = (package_dir / '.dart_tool/package_config.json').resolve()
    packages = json.loads(config.read_text())['packages']
    for name in ('material_ui', 'cupertino_ui'):
        package = next(package for package in packages if package['name'] == name)
        uri = urljoin(config.as_uri(), package['rootUri'])
        pubspec = Path(unquote(urlparse(uri).path)) / 'pubspec.yaml'
        version = re.search(r'^version: (\S+)$', pubspec.read_text(), re.MULTILINE).group(1)
        if sys.argv[1] == 'oldest' and version != '1.0.0':
            raise SystemExit(f'{package_dir}: expected {name} 1.0.0, resolved {version}')
        print(f'{package_dir}: {name} {version} ({sys.argv[1]})')
PYTHON
