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
