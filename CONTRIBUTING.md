# Development and linting

Version 2 supports Flutter **3.44.0+**, Dart **3.12.0+**, and standalone
**material_ui >=1.0.0 <2.0.0**. CI tests the exact Flutter minimum declared in
`pubspec.yaml` and the moving stable channel, each with exact Material UI 1.0.0
and the newest compatible Material UI release. See
[the compatibility roadmap](doc/compatibility-roadmap.md).

Both the minimum Flutter 3.44 / Dart 3.12 SDK and current stable run the full
analyzer-plugin checks with strict casts, inference, and raw types. Infos and
warnings fail validation. CI also runs the isolated DCL CLI on both SDKs in
the latest-compatible Material UI jobs; plugin checks run in all four jobs.

## Why these three lint packages

| Tool | Role in this package |
| --- | --- |
| [Very Good Analysis](https://pub.dev/packages/very_good_analysis) | The versioned 10.3.0 preset provides the same built-in rules on both SDKs, including public API documentation and strict types. |
| [Solid Lints 1.0.0](https://pub.dev/packages/solid_lints) | Custom checks for null safety, context usage, code complexity, and widget/lifecycle conventions. |
| [Dart Code Linter 4.4.0](https://pub.dev/packages/dart_code_linter) | Complementary checks for listener cleanup, redundant `async`, `async`/`await` style, test assertions, and test filenames. |

The package and example allow VGA >=10.3.0 <12.0.0 so Pub can select a release
compatible with each SDK, while the included preset stays fixed at 10.3.0.
VGA 10.3.0 supports the consumer Dart 3.12 floor; VGA 11.0.0 requires Dart
3.13 and resolves on stable. Solid Lints 1.0.0 and DCL 4.4.0 are already current.
The root analyzer configuration enables the modern plugins directly by version;
they resolve their own dependencies and do not need root development dependencies.
The DCL CLI has a separate dependency graph in `tool/dcl/pubspec.yaml` so it cannot
raise the package's test SDK floor. Update its constraint and the plugin entry
together when upgrading DCL. No legacy `analyzer.plugins` block is used. Restart
the Dart Analysis Server after changing plugin configuration.

DCL's `all` preset is intentionally replaced by an explicit rule list. VGA owns
built-in rules, Solid owns its custom checks, and DCL adds selected complementary
checks. We include VGA's preset and explicitly configure Solid's diagnostics,
so switching the base preset preserves Solid's rule settings. CI also runs
the DCL CLI to check its configuration directly. Test-rule include patterns are
relative to `test/analysis_options.yaml`, so the test policy uses `**/*.dart`
instead of the default `test/**` pattern.

## Package rules

`analysis_options.yaml` includes VGA's versioned 10.3.0 preset and enables strict
casts, strict inference, and strict raw types. Public API documentation and public type
annotations remain enabled because this is a reusable package.

VGA supplies checks such as `unawaited_futures`, `discarded_futures`,
`use_build_context_synchronously`, `cancel_subscriptions`,
`library_private_types_in_public_api`, `document_ignores`, and
`unnecessary_ignore`. Solid supplies `avoid_non_null_assertion`,
`proper_super_calls`, and `use_nearest_context`.
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
- Cascades, `forEach`, quote selection, constructor placement, and field
  initialization placement: preserve existing readable source conventions.
- Omitting local and closure-parameter types: explicit types can clarify
  fixtures and callback contracts.
- Integer literal preferences: Solid already checks double literal formatting,
  and explicit `0.0` values are useful in Flutter layout code.
- Mandatory assertion messages: Flutter-style named parameter assertions can
  omit the optional message.
- Redundant `async` and preferences for uninitialized `late` fields: DCL owns
  the async check, while Solid discourages `late` outside test fixtures.
- Newer syntax lints: the versioned baseline avoids requiring language features
  above the package's consumer Dart 3.12 floor. Unsupported newer lint overrides
  are omitted rather than suppressing analyzer warnings.

All CI jobs check formatting using the package's declared Dart 3.12 language
version, so the minimum and stable formatters share the same baseline.

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
Strict types and built-in async/lifecycle checks remain active on both SDKs.
Plugin test-assertion and filename checks run on both SDKs. Named callback typedefs
remain allowed to keep parameterized fixtures readable. Lints can detect missing
assertions, but reviewing the behavior a test protects is still necessary.

The example inherits the package policy, with a function-length exception only
for `_HomePageState.build`, which showcases all button variants.

## Local checks

Run these checks with either supported SDK selected on `PATH`:

```sh
flutter --version
bash tool/resolve_material_ui.sh latest
dart format --output=none --set-exit-if-changed lib test example/lib
bash tool/analyze.sh
(cd tool/dcl && dart pub get)
bash tool/check_dcl.sh
flutter test --no-pub
git diff --check
```

Flutter 3.44.0 runs the same plugin and CLI checks as stable; no minimum-SDK
plugin bypass is needed. Do not claim minimum compatibility from a stable-only
run.

Run `bash tool/resolve_material_ui.sh oldest` in an isolated checkout to pin
exact Material UI 1.0.0 for both the package and example. The script refuses to
replace existing overrides, removes its temporary overrides on exit, and checks
the resolved versions. Then run the same analysis and `flutter test --no-pub`
checks; keep `--no-pub` so the verified resolution stays in use. Run this on the
exact minimum and stable SDKs. The latest mode unlocks Material UI and all its
transitive dependencies to resolve their newest compatible versions. Finish the
primary checkout with latest resolution on stable.

After changing SDKs or moving a checkout, run the dependency-resolution script
again. Do not reuse `.dart_tool/package_config.json` from a different SDK: it
contains absolute paths. The analysis script checks package-wide diagnostics,
then explicitly targets every Dart source file in `lib/`, `test/`, and
`example/lib/`. This collects plugin diagnostics that directory-wide analysis
can miss on Dart 3.13.4.

The package and CLI-tool lockfiles remain ignored. The example app keeps its
tracked lockfile; different Flutter SDKs may resolve different SDK-pinned package
versions. CI permits those expected resolutions without overwriting the committed
lockfile. Review any local lockfile diff before committing it, and finish with the
stable example resolution when updating its baseline.

## Optional structural audits

For a maintainability review, run the pinned
[Analytica cognitive complexity CLI](https://github.com/kevmoo/analytica.dart/tree/main/packages/cognitive_complexity)
from the repository root:

```sh
dart run cognitive_complexity@0.2.5 --git-diff=origin/main --format=json lib/
```

This reports function complexity changes against `origin/main`. It is an optional
review aid, with no failure threshold or CI gate. Dart resolves the tool in its
own dependency graph; the command does not add package dependencies or install
agent skills. Version 0.2.5 was verified on Dart 3.12.0 and 3.13.4. Fetch the PR's
actual base branch and use that ref instead of `origin/main` when appropriate.

Review findings in context. Keep cohesive loading/error logic together and
preserve native Material constructor forwarding. A score increase alone does not
justify splitting helpers or changing public APIs. Declarative widget builds and
parameterized contract tests need different treatment from callback logic.

The remaining tools were evaluated on October 2, 2026:

| Tool | Adoption notes |
| --- | --- |
| [dedupe](https://github.com/kevmoo/analytica.dart/tree/main/packages/dedupe) | Revisit for targeted audits. Repeated button wiring is intentional, so a package-wide duplication percentage should not become a release gate. |
| [undead](https://github.com/kevmoo/analytica.dart/tree/main/packages/undead) | Revisit after the published CLI compiles cleanly. Version 0.1.1 failed to compile with resolved `analytica 0.1.2` because both libraries define `ElementReferenceExtractor`. Use library mode for future audits so exported APIs remain roots. |
| [lower_bound](https://github.com/kevmoo/analytica.dart/tree/main/packages/lower_bound) | Currently in development. Evaluate separately; retain the existing exact Flutter minimum and Material UI dependency matrix with full tests. |
| [scripts.dart](https://github.com/kevmoo/scripts.dart) | Evaluate as developer tooling with its own SDK. Its current constraint is `^3.13.0-100`, above this package's Dart 3.12 floor. Adapt personal repository/skill conventions before applying them to this repository. |
