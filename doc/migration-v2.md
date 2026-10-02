# Migrating from 1.x to 2.0

This guide describes the implemented 2.0.0 API in this repository. It is
unreleased; a version in `pubspec.yaml` is not evidence of publication. Check
the [release status and validation procedure](release-validation.md) before
selecting a dependency. The runnable [Material](../example/lib/main.dart) and
[Cupertino](../example/lib/cupertino_main.dart) examples use this checkout.

## Choose the release line

| Line | SDK floor | Design libraries | Maintenance |
| --- | --- | --- | --- |
| 1.1.x | Flutter 3.29.0, Dart 3.7.0 | Built-in Flutter Material | Compatibility fixes for existing applications; no v2 APIs or SDK-floor increase in patch releases. |
| 2.0.x | Flutter 3.44.0, Dart 3.12.0 (below 4.0.0) | `material_ui >=1.0.0 <2.0.0`, `cupertino_ui >=1.0.0 <2.0.0` | Standalone design libraries, shared async contracts, and native Cupertino buttons. |

Stay on `loadable_buttons: ^1.1.1` if you need built-in Material or Flutter
below 3.44. Backport applicable correctness fixes to the 1.x release line,
validate them on Flutter 3.29 and stable, and release them separately. New v2
features belong on 2.x; there is no promised 1.x support end date. Historical
1.0.x constraints are listed in the [compatibility roadmap](compatibility-roadmap.md).

After 2.0.0 is published, use these constraints for a Material application:

```yaml
dependencies:
  flutter:
    sdk: flutter
  loadable_buttons: ^2.0.0
  material_ui: '>=1.0.0 <2.0.0'
```

For a Cupertino application, declare `cupertino_ui: '>=1.0.0 <2.0.0'`
directly instead of `material_ui`. The package itself depends on both libraries.
Let Pub select versions compatible with your SDK; pinning newer design-library
releases can raise your application's floor above the package's floor.

Before publication, use a local path dependency on this checkout instead of
the hosted `^2.0.0` constraint, adjusting the relative path for your application:

```yaml
  loadable_buttons:
    path: ../loadable_buttons
```

Run `flutter pub get` after changing SDKs or
dependencies, then analyze and test your application.

## Imports and public types

| 1.x source | 2.0 source |
| --- | --- |
| `package:flutter/material.dart` | `package:material_ui/material_ui.dart` |
| `package:loadable_buttons/loadable_buttons.dart` | Still supported; `package:loadable_buttons/material.dart` is a narrower alternative. |
| No package Cupertino entry point | `package:loadable_buttons/cupertino.dart` with `package:cupertino_ui/cupertino_ui.dart` |
| Legacy Material `ThemeData`, `ButtonStyle`, button themes, `IconAlignment`, ink factories, and Material enums | Standalone Material UI definitions of those types. Recreate values using the new import. |
| Flutter `WidgetState`, `WidgetStateProperty`, `WidgetStatesController`, widgets, geometry, and callbacks | Continue to use Flutter widgets types; these have no new package-specific replacements. |

The combined barrel exports both button families and the shared
`TransitionAnimationType` and `AsyncButtonErrorHandler`. It does not replace
your design-library imports. Update helpers that construct styles, themes,
and ink factories as well as the files that construct buttons. Legacy Material
objects are distinct types and cannot be passed to v2 constructors.

### Plain and icon buttons

Before (1.x):

```dart
import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

Widget saveButton(Future<void> Function() save) => AsyncElevatedButton(
  onPressed: save,
  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
  child: const Text('Save'),
);

Widget saveIconButton(Future<void> Function() save) => AsyncFilledButton.icon(
  onPressed: save,
  icon: const Icon(Icons.save_outlined),
  label: const Text('Save'),
);
```

After (2.0):

```dart
import 'package:loadable_buttons/material.dart';
import 'package:material_ui/material_ui.dart';

Widget saveButton(Future<void> Function() save) => AsyncElevatedButton(
  onPressed: save,
  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
  loadingSemanticsLabel: 'Saving changes',
  child: const Text('Save'),
);

Widget saveIconButton(Future<void> Function() save) => AsyncFilledButton.icon(
  onPressed: save,
  loadingSemanticsLabel: 'Saving changes',
  icon: const Icon(Icons.save_outlined),
  label: const Text('Save'),
);
```

These English labels keep the snippets self-contained; use your application's
localized strings in production. Constructor names and `child` versus `label`
stay the same. 2.0 also ships nullable Material style shortcuts on Elevated,
Filled, Outlined, and Text buttons, including icon and tonal variants. They
override only the supplied property and state, falling back through `style`,
family theme, and native defaults. See [style shortcuts](../README.md#material-style-shortcuts).

### Localizations and legacy subtrees

Use standalone `GlobalMaterialLocalizations.delegates` for Material apps that
need localization delegates. Follow the
[official Material UI migration guide](https://pub.dev/packages/material_ui#migrating-existing-code-to-this-package)
for Flutter and Cupertino localization migration as well.

If a third-party dependency still uses built-in Material, the official
`MaterialUiCompatibilityBridge` can supply legacy themes and localizations to
that subtree under a standalone `MaterialApp`. Wrap only the subtree, or use
`MaterialApp.builder` as in the [README](../README.md#migrating-from-1x).
The bridge is a temporary migration utility and is marked deprecated by the
design library; remove it when those dependencies migrate. It does not make
legacy `ButtonStyle`, `ThemeData`, or other public types interchangeable with
standalone types, and it does not lower v2's SDK floor.

## Loading ownership and semantics

Both versions track only work returned or awaited by `onPressed`. Effective
loading remains external `loading` OR a pending callback. Setting external
loading to false cannot unlock pending work, and callback completion cannot
clear external loading. There is no cancellation API.

Before, label custom content yourself:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  loadingChild: const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(semanticsLabel: 'Saving changes'),
  ),
  child: const Text('Save'),
);
```

After, label the default spinner directly:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  loadingSemanticsLabel: 'Saving changes',
  child: const Text('Save'),
);
```

Here and below, `saveChanges` is your application's `Future<void>` operation.
Every v2 constructor accepts `loadingSemanticsLabel`, with a null default and
no English fallback. It is exposed only during loading. Custom `loadingChild`
and custom builders still own their labels; they ignore this parameter.
Loading disables the outer button, while built-in transitions exclude inactive
and outgoing content from input, focus, and semantics. Live announcements remain
application-owned. See the [semantics policy](loading-semantics-policy.md).

## Callback errors

Before, catch errors inside the callback if you want to consume them:

```dart
AsyncElevatedButton(
  onPressed: () async {
    try {
      await saveChanges();
    } on Object catch (error, stackTrace) {
      debugPrint('Saving failed: $error\n$stackTrace');
    }
  },
  child: const Text('Save'),
);
```

After, the equivalent explicit consumption can use `onError`:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  onError: (error, stackTrace) {
    debugPrint('Saving failed: $error\n$stackTrace');
  },
  child: const Text('Save'),
);
```

Omitting `onError` preserves error propagation with the original stack trace.
A successful handler consumes the error; the package does not also report it.
An async handler retains the loading lock until it completes. A handler failure
propagates and is not passed to the handler again. Internal loading clears in
all cases, while external loading remains independent. Avoid consuming the same
error inside `onPressed` if you expect `onError` to receive it.

Disposal does not cancel callbacks or captured handlers. Check `mounted` or
`context.mounted` before using state or context. The hook covers only tracked
`onPressed` failures, not long presses, builders, or detached Futures. See the
[error policy](callback-error-policy.md).

## Custom transitions

Existing `stack`, `animatedSwitcher`, and `customBuilder` enum values remain.
With custom builders, the nullable `loadingChild` is passed unchanged; there
is no injected spinner or semantics label.

Before (still valid after migrating imports):

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.customBuilder,
  loadingChild: const Text('Saving changes'),
  customBuilder: (loading, child, loadingChild) => loading
      ? loadingChild ?? const Text('Saving changes')
      : child,
  child: const Text('Save'),
);
```

After, an explicit progress label makes the loading presentation accessible:

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.customBuilder,
  loadingChild: const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(semanticsLabel: 'Saving changes'),
  ),
  customBuilder: (loading, child, loadingChild) => loading
      ? loadingChild ?? const Text('Saving changes')
      : child,
  child: const Text('Save'),
);
```

This immediate replacement retains no inactive content. Builders that retain or
animate both states must guard inactive/outgoing content with `IgnorePointer`,
`ExcludeFocus`, and `ExcludeSemantics`. Opacity alone is insufficient. Extended
FABs can invoke builders separately for icon and label. See the
[custom builder responsibilities](../README.md#custom-builders).

## Native Cupertino

1.x has no async Cupertino family. Before, applications managed the spinner,
lock, and errors around a native `CupertinoButton` themselves:

```dart
import 'package:flutter/cupertino.dart';

Widget saveButton({required bool saving, required VoidCallback save}) =>
    CupertinoButton.filled(
      onPressed: saving ? null : save,
      child: saving
          ? const CupertinoActivityIndicator()
          : const Text('Save'),
    );
```

The application's `save` callback must set and clear `saving`, await work, and
choose how to report errors. After migration, use the standalone library and
native async variants:

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:loadable_buttons/cupertino.dart';

Widget saveButton(Future<void> Function() save) => AsyncCupertinoButton.filled(
  onPressed: save,
  loadingSemanticsLabel: 'Saving changes',
  child: const Text('Save'),
);
```

Place this under `CupertinoApp`; no Material ancestor is needed. Default,
`.filled`, and `.tinted` preserve native Cupertino behavior and use
`CupertinoActivityIndicator`. Use `minimumSize`; deprecated native `minSize`
is omitted. The same loading, error, and transition contracts apply.
See the [runnable Cupertino example](../example/README.md).

## Implemented scope and follow-ups

2.0 ships standalone Material migration, error hooks, loading labels, native
Cupertino, design-specific barrels, Material style shortcuts, and the consumer
agent skill. The combined barrel and existing Material variants remain available.

Controllers, debounce policies, adaptive constructors, and additional custom-style
abstractions remain proposals. They are not v2.0 APIs and must not appear in
migration code or release promises. Native `style`, shipped shortcuts,
`loadingChild`, and `customBuilder` remain the customization APIs.

Run the examples using [these commands and manual checks](../example/README.md),
then analyze and test your migrated application on its minimum and stable SDKs.
