# Compatibility roadmap

| Version line | Flutter minimum | Dart minimum | Material API |
| --- | --- | --- | --- |
| 1.0.x / 1.1.x | 3.29.0 | 3.6.0 | `package:flutter/material.dart`, with FAB settings from `ThemeData.floatingActionButtonTheme` or explicit constructor arguments. |
| 1.2.x (planned) | 3.41.0 | 3.11.0 | `package:flutter/material.dart`, adding inherited `FloatingActionButtonTheme` support and newer Flutter APIs. |
| 2.x (planned) | 3.47.0 | 3.13.0 | Standalone `material_ui >=1.0.0 <2.0.0`. |

The current compatibility fix and CI changes keep the 1.0.x SDK constraints.
The next feature release, 1.1, also retains Flutter 3.29 support. The existing
extended-FAB padding and icon-spacing lookups used `FloatingActionButtonTheme`,
which first appears in stable Flutter 3.41.0 and prevents compilation on 3.29.
The compatibility line instead reads `ThemeData.floatingActionButtonTheme` and
honors explicit `extendedPadding` and `extendedIconLabelSpacing` values. Support
for inherited `FloatingActionButtonTheme` overrides belongs to the planned 1.2
line.

Keep each migration separate and validate the exact minimum and stable SDKs for
that release line before claiming compatibility. Future constraints in this table
are planned targets, not validation results for the current package.

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
missing APIs available. The supported constraints and CI minimum remain 3.29.

[Flutter 3.22 already provides `WidgetState`](https://github.com/flutter/flutter/blob/3.22.0/packages/flutter/lib/src/material/material_state.dart),
with `MaterialState` and the related Material names declared as deprecated
aliases. Internal `WidgetState` uses therefore do not exclude 3.22. Keep the
existing public `MaterialStatesController` and `MaterialStateProperty` declarations
and their focused deprecation suppressions throughout v1; reserve the public
Material API migration for v2.
