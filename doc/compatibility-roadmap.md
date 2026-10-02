# Compatibility roadmap

| Version line | Flutter minimum | Dart minimum | Material API |
| --- | --- | --- | --- |
| 1.0.x | 3.29.0 | 3.6.0 | `package:flutter/material.dart`, with FAB settings from `ThemeData.floatingActionButtonTheme` or explicit constructor arguments. |
| 1.1.x | 3.29.0 | 3.7.0 | `package:flutter/material.dart`, with Widget state types and FAB settings from `ThemeData.floatingActionButtonTheme` or explicit constructor arguments. |
| 2.x | 3.44.0 | 3.12.0 | Standalone `material_ui >=1.0.0 <2.0.0`, including inherited `FloatingActionButtonTheme` support. |

The 1.1 release retains Flutter 3.29 support and aligns the Dart minimum with
the bundled Dart 3.7 SDK. The existing extended-FAB padding and icon-spacing
lookups used `FloatingActionButtonTheme`,
which first appears in stable Flutter 3.41.0 and prevents compilation on 3.29.
The compatibility line instead reads `ThemeData.floatingActionButtonTheme` and
honors explicit `extendedPadding` and `extendedIconLabelSpacing` values.
Version 2 uses standalone `FloatingActionButtonTheme.of` for inherited padding
and icon spacing, matching native Material UI precedence. This supersedes the
previously proposed 1.2 migration.

Version 2 deliberately keeps the Flutter 3.44 / Dart 3.12 baseline declared by
Material UI 1.0.0. As of October 2, 2026, Pub selects Material UI 1.2.0 on that
SDK: [1.3.0 is retracted](https://pub.dev/packages/material_ui/versions/1.3.0),
and releases 1.4.0 and newer require Flutter 3.47 / Dart 3.13.
The inclusive lower bound preserves
the first stable release, and the implementation uses no newer expressive APIs.
Solid Lints 1.0.0 and DCL 4.4.0 plugins and the isolated DCL CLI are validated
on Dart 3.12 and stable. Their independent dependency graphs keep analyzer
requirements separate from Flutter's SDK-pinned consumer and test dependencies.

CI runs four SDK/dependency combinations: exact Flutter 3.44.0 and current
stable, each with exact Material UI 1.0.0 and the latest compatible resolution.
`tool/resolve_material_ui.sh` uses temporary overrides in both package roots for
the exact lower-bound check and verifies the resolved versions. Analysis,
formatting, and the full contract suite run against each resolved graph. See
[the migration guide](../README.md#migrating-from-1x) for downstream import/type
changes and the compatibility bridge for legacy dependencies.

Development dependencies use Very Good Analysis >=10.3.0 <12.0.0, resolving
10.3.0 on the minimum SDK and 11.0.0 on stable. Both use the versioned 10.3.0
preset so lint rules remain compatible with Dart 3.12. Solid Lints 1.0.0 and
DCL 4.4.0 remain at their current versions and run on both SDKs.

Version 2 preserves native icon-and-label button padding for Elevated,
Filled (including tonal), Outlined, and Text buttons. Keep widget padding ahead
of inherited family theme padding, then native defaults, resolving fallbacks per
widget state. Retain native-reference regression coverage for text scaling,
LTR/RTL, and null icons, and keep stack loading content centered within the full
button, including asymmetric padding. Cover both axes during the transition and
retain interaction with custom loading content.

## Version 2 validation

Validated locally on October 2, 2026 in isolated dependency graphs:

| Flutter | Dart | Material UI | Full contract suite |
| --- | --- | --- | --- |
| 3.44.0 | 3.12.0 | 1.0.0 (exact lower bound) | 642 passed |
| 3.44.0 | 3.12.0 | 1.2.0 (latest compatible) | 642 passed |
| 3.47.5 (stable) | 3.13.4 | 1.0.0 (exact lower bound) | 642 passed |
| 3.47.5 (stable) | 3.13.4 | 1.5.0 (latest) | 642 passed |

Package, test, and example analysis and formatting passed in all four graphs.
Both SDKs also passed the full analyzer-plugin and DCL CLI checks. Temporary
negative probes confirmed that Solid and DCL emit their configured diagnostics
on Dart 3.12. The running
macOS example restarted with the migrated package and reported no runtime errors.
The inherited-FAB native-reference matrix failed eight cases before the lookup
fix and passed afterward. It checks inherited and empty inherited themes,
explicit overrides, typography, icon spacing, LTR/RTL, and centered loading
content without fixing expectations to a particular Material release.

## Flutter 3.22 compatibility check

Checked PR #30 (`5cb6c44`) on October 1, 2026 with the exact Flutter **3.22.0**
SDK (`5dcb86f68f`) and Dart **3.4.0**, in an isolated checkout. The package does
not currently support this baseline: dependency resolution rejects the declared
Dart `^3.6.0` constraint before the code can compile.

A diagnostic probe lowered only the temporary package/example constraints to
Flutter >=3.22.0 and Dart ^3.4.0, allowed Very Good Analysis 6.0.0, and omitted
newer lint configuration. Dependencies then resolved, but library analysis found
17 compile errors from these unavailable Flutter APIs:

- `CircularProgressIndicator.constraints`.
- `ButtonStyle.iconAlignment`, used by the four icon-and-label button families.
- `IconButton.onHover` and `IconButton.onLongPress`, used by all four variants.

The same probe against pre-refactor main (`978304a`) found the same missing APIs
in 22 compile errors; duplicate indicators accounted for the larger count.
These incompatibilities predate PR #30. No runtime tests could validate 3.22
while the library failed analysis.

Supporting 3.22 requires a compatibility backport for these behaviors, compatible
development tooling, and validation of the public contract suite and example on
3.22 and stable. Restoring comments or suppressing deprecations cannot make these
missing APIs available. The 1.x constraints and CI minimum at the time remained 3.29.

[Flutter 3.22 already provides `WidgetState`](https://github.com/flutter/flutter/blob/3.22.0/packages/flutter/lib/src/material/material_state.dart),
with `MaterialState` and the related Material names declared as deprecated
aliases. Internal `WidgetState` uses therefore do not exclude 3.22. Constructor
declarations use `WidgetStatesController` and `WidgetStateProperty`, which are
available in 3.29 and represent exactly the same types as the former Material
aliases. Existing callers using the Material aliases remain source compatible.
Version 2 changes Material types to the standalone Material UI definitions.

The 1.x accessibility tests retained `SemanticsData.hasFlag` with line-specific ignores:
its `flagsCollection` replacement is unavailable in Flutter 3.29. The partial
`containsSemantics` matcher is also deprecated on current stable Flutter, and
its `isSemantics` replacement is unavailable in 3.29. Those focused suppressions
preserved the existing enabled and selected state checks while allowing analysis
to catch other deprecated calls in the test files.

## Flutter 3.27 compatibility check

Checked the exact Flutter **3.27.0** SDK (`8495dee1fd`) and Dart **3.6.0** on
October 1, 2026 in an isolated checkout with only the Flutter constraint lowered
for the probe. Dependency resolution failed because Very Good Analysis >=8.0.0
requires Dart >=3.7.0.

With Very Good Analysis 7.0.0 and compatible lint configuration only in the
probe, dependencies resolved but library analysis found 17 compile errors:
`CircularProgressIndicator.constraints` and `ButtonStyle.iconAlignment` are
unavailable, as are the public `IconButton.onHover` and `IconButton.onLongPress`
constructor arguments used by all four variants. Supporting 3.27 would require
backporting these behaviors and changing development tooling. Version 1.1 instead keeps Flutter >=3.29.0
and declares Dart ^3.7.0, matching the SDK combination validated by CI.
