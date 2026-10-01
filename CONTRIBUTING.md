# Development and linting

Use Flutter stable with Dart **3.12 or newer** when working on this repository.
Solid Lints 1.0.0 requires Dart 3.12. These lint tools are development
dependencies; package consumers retain the SDK constraints in `pubspec.yaml`.

## Why both linters

| Tool | Role in this package |
| --- | --- |
| [Solid Lints 1.0.0](https://pub.dev/packages/solid_lints) | Shared Dart/Flutter analyzer rules, strict typing, public API documentation, null safety, context usage, and code complexity. |
| [Dart Code Linter 4.4.0](https://pub.dev/packages/dart_code_linter) | A small complementary set for listener cleanup, redundant `async`, `async`/`await` style, test assertions, and test filenames. |

These were the latest stable releases checked on September 30, 2026. Version
constraints appear in both `pubspec.yaml` and the root plugin configuration;
update both together when upgrading. We use the modern analysis server plugin
system, so the IDE and `dart analyze` can run both plugins. Restart the Dart
Analysis Server after changing plugin configuration.

DCL's `all` preset is intentionally replaced by an explicit rule list. Solid
owns overlapping rules; DCL adds only rules Solid does not supply. CI also runs
the DCL CLI to check its configuration directly. Test-rule include patterns are
relative to `test/analysis_options.yaml`, so the test policy uses `**/*.dart`
instead of the default `test/**` pattern.

## Package rules

`analysis_options.yaml` includes Solid's shared preset and enables strict casts,
strict inference, and strict raw types. Public API documentation and public type
annotations remain enabled because this is a reusable package.

The Solid preset supplies checks such as `unawaited_futures`,
`use_build_context_synchronously`, `cancel_subscriptions`, `close_sinks`,
`avoid_non_null_assertion`, `proper_super_calls`, and `use_nearest_context`.
Complexity is limited to 10 outside `build()` methods, and functions are limited
to 200 lines. Widget `build()` methods are exempt from complexity because the
metric counts nullable style fallbacks and declarative widget branches. Callback
and lifecycle logic retain the complexity check.

Magic-number checks remain enabled for library logic. Ordinary widget layout
parameters are allowed; icon-spacing calculations use named constants for their
font-size baseline, scale limit, and gap sizes. Tests allow literal expectations
and timings. Non-null assertions remain discouraged in both library and tests;
when a test needs a nullable callback, fail explicitly if it is missing.

The package overrides policies that conflict with its API or structure:

- Parameter-count limits: button constructors mirror Flutter's large named API.
- Duplicate-code detection: related button variants intentionally repeat wiring.
- Member ordering and matching a single class to a filename: related private
  widgets and state classes live beside their public owner.
- Feature-envy and similar-name heuristics: forwarding widgets and related button
  names produce little useful signal here.
- Positional boolean restrictions: changing the public custom-builder callback
  to named parameters would break consumers.
- Trailing-comma lints and child-argument ordering: formatting and
  existing argument order do not need a second style policy.

DCL enables `always-remove-listener`, `avoid-redundant-async`,
`prefer-async-await`, `missing-test-assertion`, and
`prefer-correct-test-file-name`. Test rules recognize `testWidgets` as well as
`test`. Plugin diagnostics are enabled at the package root; directory-specific
policies are set through the included options and Solid's configuration.

`avoid-passing-async-when-sync-expected` is deliberately not enabled: this
package intentionally passes its async handlers to Flutter's `VoidCallback`
button APIs. `unawaited_futures` still checks dropped futures inside async code.
Do not use unused-public-code or public-member privacy checks as release gates:
the analyzer cannot see downstream package consumers.

## Test rules

The analyzer automatically discovers `test/analysis_options.yaml`, which
includes the repository's `analysis_options_test.yaml`. That file inherits the
root configuration, so future package rule changes also reach tests.

Like Solid's supplied test preset, it relaxes function length, complexity, and
`late` restrictions; filename matching and duplicate detection are already
disabled by the package policy. It also permits widget-producing fixtures,
empty stub callbacks, literal expected values, diagnostic printing, and explicit
default arguments. Public API documentation is unnecessary for test helpers.
Strict types, async/lifecycle checks, test assertions, and test filename checks
remain active. Lints can detect missing assertions, but reviewing the behavior a
test protects is still necessary.

The example inherits the package policy, with a function-length exception only
for `_HomePageState.build`, which showcases all button variants.

## Local checks

Run the same checks as CI:

```sh
flutter pub get
bash tool/analyze.sh
dart run dart_code_linter:metrics analyze lib test example/lib --fatal-style --fatal-performance
flutter test --no-pub
```

The analysis script checks package-wide diagnostics, then explicitly targets
every Dart source file in `lib/`, `test/`, and `example/lib/`. This also collects
Solid plugin diagnostics that directory-wide analysis can miss on Dart 3.13.4.

The package root lockfile remains ignored, as appropriate for a published
library. The example app keeps its own lockfile.
