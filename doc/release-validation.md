# Version 2 release validation

Issue [#48](https://github.com/hectorAguero/loadable_buttons/issues/48) prepares
release readiness. Neither this procedure nor a readiness PR authorizes uploading
the package, creating a release tag, or publishing a GitHub release.

## Candidate checks

Freeze the candidate commit after the chosen v2 scope is merged. Record its SHA,
SDK versions, resolved Material UI/Cupertino UI versions, test totals, and logs
in the readiness PR. Rerun checks when source, constraints, skills, or examples
change. Earlier results in the compatibility roadmap are historical evidence,
not proof for a later candidate.

The existing [CI workflow](https://github.com/hectorAguero/loadable_buttons/blob/main/.github/workflows/dart.yml)
checks four graphs:

| Flutter SDK | Design dependency resolution |
| --- | --- |
| Exact 3.44.0 | Material UI and Cupertino UI exactly 1.0.0 |
| Exact 3.44.0 | Latest compatible with Dart 3.12 |
| Current stable | Material UI and Cupertino UI exactly 1.0.0 |
| Current stable | Latest compatible with stable's Dart SDK |

For each graph, use an isolated checkout and select the SDK on `PATH`. Do not
reuse `.dart_tool` from another path or SDK. From the checkout root run:

```sh
flutter --version
# Choose oldest or latest for this graph.
bash tool/resolve_design_ui.sh oldest
dart format --output=none --set-exit-if-changed lib test example/lib
bash tool/analyze.sh
(cd tool/dcl && dart pub get)
bash tool/check_dcl.sh
flutter test --no-pub
git diff --check
bash tool/check_pubignore.sh
```

The resolver verifies both package and example graphs, and removes temporary
lower-bound overrides on exit. Keep `--no-pub` on tests so that exact resolution
is preserved. CI runs analyzer plugins in all four jobs and DCL CLI once per
SDK in latest jobs; release validation can also run the CLI in oldest graphs.
Finish the primary checkout on stable with latest resolution. Review the
tracked example lockfile diff rather than committing SDK-dependent churn.
See [CONTRIBUTING.md](../CONTRIBUTING.md#local-checks).

## Examples and documentation

- Run the [Material and Cupertino entry points](../example/README.md) from the
  candidate, checking plain/icon/tonal variants, both built-in transitions,
  custom builders, external loading, handled errors, disabled/long-press
  behavior, keyboard activation, and accessible loading labels.
- Confirm API examples use standalone design-library types. Validate changed
  consumer skill snippets in an isolated application using the candidate.
- Check README/API/migration links and changelog against the actual constructors.
  Keep controller/debounce/adaptive/custom-style proposals out of release notes.
- Refresh `screenshots/preview.gif` when the presentation changes; label it as
  the Material gallery because it does not demonstrate Cupertino. Documentation
  edits alone do not require new screenshots.

## Archive and consumer skill

On stable/latest, inspect the complete file listing and warnings:

```sh
dart pub publish --dry-run
```

This command does not upload anything. CI repeats it in stable/latest and keeps
its output as an artifact for review. Require zero warnings. Confirm that
`lib/`, the companion parts, `README.md`, `CHANGELOG.md`, `LICENSE`, migration
documentation, examples, and the configured screenshot are present. Confirm
`skills/loadable-buttons-usage/SKILL.md` and `references/customization.md` are
present. Check for credentials, editor state, build output, local overrides,
coverage, and maintainer resources. `.pubignore` excludes `AGENTS.md`,
`CONTRIBUTING.md`, structural audits, this release procedure, and `tool/`.
Consumer-facing documentation links to those resources in the repository.
Because Pub uses `.pubignore` in preference to the root `.gitignore`, run
`bash tool/check_pubignore.sh` to catch missing Git exclusion patterns.

Before release, install the skill from an isolated Flutter consumer project with
a path dependency on the candidate and a direct design-library dependency:

```sh
flutter pub get
dart run skills@ get --package loadable_buttons --agent generic --all
```

Inspect the installed skill and relative reference links, then analyze the
consumer application's examples. The package never installs agent configuration
itself. The skill's contract tests run with the full suite.

## Authorized publication and follow-up

After the maintainer authorizes publication, follow these steps:

1. On the validated commit, finalize the 2.0.0 changelog and release notes.
   Recheck the package version and hosted availability,
   and rerun the dry run after any final edits. Ensure all four CI jobs pass.
2. Upload 2.0.0 using the normal maintainer Pub authentication flow. Verify the
   hosted version and archive before recording publication as successful.
3. Tag that same source commit `v2.0.0` and create its GitHub release with the
   breaking SDK/import changes, migration link, and implemented feature list.
   Record the actual version, tag, source SHA, archive URL, and publication date
   in the release issue. A tag alone does not prove a hosted archive exists.
4. Resolve `loadable_buttons: 2.0.0` from pub.dev in a fresh Flutter application
   with no path override. Analyze/run Material and Cupertino examples against
   that hosted package; install the consumer skill from that resolution.
5. Verify the hosted README, changelog, example tab, screenshot, repository and
   issue links, dependency constraints, archive contents, and generated
   [2.0.0 API reference](https://pub.dev/documentation/loadable_buttons/2.0.0/).
   Record results and any follow-up fixes in the release issue.

Do not check off publication or post-release verification in #48 based on the
readiness PR. They require the actual hosted release.
