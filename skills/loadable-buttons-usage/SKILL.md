---
name: loadable-buttons-usage
description: Use when writing, reviewing, or migrating Flutter code that uses the loadable_buttons package (AsyncElevatedButton, AsyncFilledButton, AsyncOutlinedButton, AsyncTextButton, AsyncIconButton, AsyncFloatingActionButton, AsyncCupertinoButton, or AsyncAdaptiveButton). Covers imports, choosing constructors, returning Futures from onPressed, external loading, AsyncButtonController, AsyncButtonGroup, onError, disabled and long-press behavior, localized loading semantics, theming, sizing, and custom loading content.
---

# Using loadable_buttons

This skill describes the loadable_buttons 2.0 API. Each button wraps the native
standalone Material UI or Cupertino UI button, shows loading content while
work is pending, and blocks repeated activation. Only use the APIs listed here
or in the package API reference; do not invent controllers, adaptive buttons,
or retry/cancel parameters.

For Material style shortcuts, custom loading content, transitions, custom
builders, IconButton selection, and detailed sizing, read
[references/customization.md](references/customization.md).

## Setup and imports

Version 2 requires Flutter 3.44+ and Dart 3.12+, plus the standalone design
library that the application uses as a direct dependency:

```sh
flutter pub add loadable_buttons material_ui
# Cupertino applications:
flutter pub add loadable_buttons cupertino_ui
```

| Import | Exports |
| --- | --- |
| `package:loadable_buttons/material.dart` | Material buttons, `AsyncButtonController`, `AsyncButtonErrorHandler`, `AsyncButtonGroup`, `TransitionAnimationType` |
| `package:loadable_buttons/cupertino.dart` | `AsyncCupertinoButton`, `AsyncButtonController`, `AsyncButtonErrorHandler`, `AsyncButtonGroup`, `TransitionAnimationType` |
| `package:loadable_buttons/loadable_buttons.dart` | Both families and `AsyncAdaptiveButton` |

- Import `package:material_ui/material_ui.dart` (not
  `package:flutter/material.dart`) for `MaterialApp`, `ThemeData`,
  `ButtonStyle`, `Icons`, `IconAlignment`, and ink factories. Legacy Flutter
  Material types are distinct and are rejected by v2 constructors.
- For legacy third-party subtrees under a standalone `MaterialApp`, the official
  `MaterialUiCompatibilityBridge` temporarily supplies legacy themes and
  localizations. It is deprecated migration infrastructure, does not convert
  public style types, and should be removed when dependencies migrate.
- Import `package:cupertino_ui/cupertino_ui.dart` for Cupertino apps and types.
  `AsyncCupertinoButton` needs no Material ancestor.
- Projects still on built-in Flutter Material (Flutter below 3.44) must use
  loadable_buttons 1.x, which has no `onError`, `loadingSemanticsLabel`, or
  Cupertino buttons.

## Choose a constructor

| Widget | Constructors | Content parameters |
| --- | --- | --- |
| `AsyncElevatedButton` | default, `.icon` | `child`; `.icon`: `icon`, `label` |
| `AsyncFilledButton` | default, `.icon`, `.tonal`, `.tonalIcon` | `child`; icon variants: `icon`, `label` |
| `AsyncOutlinedButton` | default, `.icon` | `child`; `.icon`: `icon`, `label` |
| `AsyncTextButton` | default, `.icon` | `child`; `.icon`: `icon`, `label` |
| `AsyncIconButton` | default, `.filled`, `.filledTonal`, `.outlined` | `icon`, optional `selectedIcon` |
| `AsyncFloatingActionButton` | default, `.small`, `.large`, `.extended` | `child`; `.extended`: `label`, optional `icon` |
| `AsyncCupertinoButton` | default, `.filled`, `.tinted` | `child` |
| `AsyncAdaptiveButton` | default, `.filled`, `.tinted` | `child`; renders Material or Cupertino per platform |

Every constructor requires `onPressed` (nullable) and accepts `loading`,
`controller`, `excludeFromGroup`, `onError`, `loadingChild`, `loadingSemanticsLabel`, `transitionType`,
`customBuilder`, `animationDuration`, and `minimumChildOpacity`. Other
parameters mirror the native widget, such as `style`, `focusNode`,
`statesController`, `tooltip`, `heroTag`, `sizeStyle`, or `minimumSize`.

```dart
import 'package:loadable_buttons/material.dart';
import 'package:material_ui/material_ui.dart';

AsyncFilledButton.icon(
  onPressed: saveChanges,
  loadingSemanticsLabel: l10n.savingChanges,
  icon: const Icon(Icons.save_outlined),
  label: Text(l10n.save),
);
```

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:loadable_buttons/cupertino.dart';

AsyncCupertinoButton.filled(
  onPressed: saveChanges,
  loadingSemanticsLabel: l10n.savingChanges,
  child: Text(l10n.save),
);
```

`l10n`, `saveChanges`, and similar names stand for the application's own
localizations and operations.

### Adaptive buttons

Requires loadable_buttons 2.1.0 or newer. Use `AsyncAdaptiveButton` only when
one call site must render natively on both design systems; otherwise prefer
the concrete widget.

```dart
import 'package:loadable_buttons/loadable_buttons.dart';

AsyncAdaptiveButton.filled(
  onPressed: saveChanges,
  child: Text(l10n.save),
);
```

- Default → `AsyncTextButton` / `AsyncCupertinoButton`; `.filled` →
  `AsyncFilledButton` / `.filled`; `.tinted` → `AsyncFilledButton.tonal` /
  `.tinted`.
- iOS and macOS render Cupertino; other platforms render Material. The
  platform follows `Theme.of(context).platform` or the `platform` parameter.
- Material output needs a Material ancestor such as `Scaffold`.
- Use shared parameters (`padding`, `minimumSize`, `alignment`,
  `backgroundColor`, `foregroundColor`). Platform-only options are
  `materialStyle` and `cupertinoSizeStyle`; there is no `style` or `sizeStyle`.
- A platform or theme change mid-operation keeps the new button locked until
  the original operation finishes.

## Return or await the work

`onPressed` has type `FutureOr<void> Function()?`. The button stays loading
and locked until the returned Future completes.

```dart
// Correct: the button tracks the whole operation.
onPressed: saveChanges,
onPressed: () => repository.save(form),
onPressed: () async {
  await repository.save(form);
  if (!mounted) return;
  setState(() => saved = true);
},

// Wrong: the Future is dropped, so loading ends immediately and later
// errors bypass onError.
onPressed: () {
  repository.save(form);
},
onPressed: () => unawaited(repository.save(form)),
```

Synchronous callbacks are allowed; they finish in the same activation.
No controller or state management package is needed for the loading state.

## Loading ownership

Effective loading is `loading || pendingCallback`, where a pending callback
includes any pending `onError` handler. The two sources are independent:

- Setting `loading: false` does not cancel or unlock a pending `onPressed`.
- Completing `onPressed` does not clear `loading: true`; its owner must.
- While loading, the button cannot activate, long presses are blocked, and
  accessibility services see a disabled button.

```dart
// isSaving is owned by the application, e.g. a form or upload in progress.
AsyncElevatedButton(
  loading: isSaving,
  onPressed: saveChanges,
  child: const Text('Save'),
);
```

Do not duplicate the package's lock with extra `isLoading` flags just to
prevent double taps. Use `loading` only for state that the application already
owns, such as work started elsewhere.

### Observing with a controller

Requires loadable_buttons 2.1.0 or newer. When other widgets must react to a
button's work, pass an `AsyncButtonController` instead of mirroring the
operation in application state:

```dart
// In a State: create once, dispose in dispose().
final saveController = AsyncButtonController();

AsyncFilledButton(
  controller: saveController,
  onPressed: saveChanges,
  child: const Text('Save'),
);

ListenableBuilder(
  listenable: saveController,
  builder: (context, _) => TextButton(
    onPressed: saveController.isPending ? null : cancel,
    child: const Text('Cancel'),
  ),
);
```

- `isPending`: an `onPressed`/`onError` started with this controller is
  running, possibly from an earlier button. Read-only; only that operation
  clears it. Work stays on its starting controller: after a mid-operation
  controller swap, the new controller reports idle while the button is locked.
- `loading`: a manual request equivalent to the `loading` parameter. Setting it
  to false never unlocks pending work.
- `isLoading`: `loading || isPending`, excluding the widget's `loading` parameter.
- The caller owns and disposes the controller; buttons never dispose it.
- Use one controller per logical button. It may move between widgets, such as
  in an `AnimatedSwitcher` or across a route transition. It is not a group or
  mutual-exclusion mechanism for separate buttons; use `AsyncButtonGroup`.

### One operation at a time with a group

Requires loadable_buttons 2.1.0 or newer. To let only one of several related
buttons run, wrap them in `AsyncButtonGroup` instead of hand-written
`isSaving`/`isDeleting` flags:

```dart
AsyncButtonGroup(
  child: Row(
    children: [
      AsyncFilledButton(onPressed: save, child: const Text('Save')),
      AsyncOutlinedButton(onPressed: delete, child: const Text('Delete')),
      AsyncTextButton(
        excludeFromGroup: true, // escape action stays available
        onPressed: cancel,
        child: const Text('Cancel'),
      ),
    ],
  ),
);
```

- The active button shows loading; peers are disabled natively (pointer,
  keyboard, accessibility) without spinners, and recover after success or error.
- Activation claims the group synchronously; same-frame double taps cannot race.
- The nearest group applies; nested groups are independent.
- Only activations claim the group. `loading` and controller requests affect
  only their own button.
- Disposing the active button keeps peers blocked until its work finishes.
  The group never cancels work; the application owns cancellation. Give real
  work a timeout, since a Future that never completes blocks the group (a new
  group `Key` resets it).
- A claim stays with the group where activation started; moving a busy button
  into another group does not block that group's members.
- Plain Flutter widgets in the group, including non-async buttons, are not
  blocked; gate them with `AsyncButtonGroup.isActiveOf(context)` when needed.

## Errors

Without `onError`, a synchronous throw or failed Future from `onPressed`
propagates with its original stack trace to the zone's error handling. Internal
loading clears so the user can retry.

`onError` has type `AsyncButtonErrorHandler`:
`FutureOr<void> Function(Object error, StackTrace stackTrace)`.

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  onError: (error, stackTrace) async {
    await crashReporter.record(error, stackTrace); // Application's reporter.
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.saveFailed)),
    );
  },
  child: Text(l10n.save),
);
```

- A handler that completes successfully consumes the error; the package does
  not log or report it. Report or rethrow it in the handler if needed.
- The handler runs exactly once per failed activation. The button stays loading
  until an async handler finishes. A handler failure propagates with its own
  stack trace and is not passed back to `onError`.
- Callbacks are captured when activation starts; rebuilding with a new handler
  affects only the next activation. Disposal does not cancel the operation or
  its handler, and no `BuildContext` is supplied, so check `mounted` or
  `context.mounted` before touching state or context.
- `onError` covers only `onPressed`. It does not cover `onLongPress`, builders,
  or Futures that were not returned or awaited.
- The package shows no Snackbar or dialog and has no retry or cancellation API.

## Disabled and long-press behavior

- `onPressed: null` disables the button. Use it for unavailable actions;
  `loading` only blocks activation temporarily while work is in progress.
- Elevated, Filled, Outlined, Text, and Cupertino buttons stay enabled when
  `onLongPress` is supplied, even with `onPressed: null`.
- `onLongPress` is a synchronous `VoidCallback`. It never starts loading and is
  blocked while the button is loading.
- `AsyncIconButton` forwards `onLongPress` to the native IconButton.
  `AsyncFloatingActionButton` has no `onLongPress` parameter.
- Disabled appearance, focus, and semantics come from the native button.

## Accessible loading labels

Every constructor accepts `String? loadingSemanticsLabel` for the default
spinner. It defaults to `null`; the package provides no English fallback.

- Pass a localized string describing the operation, such as "Saving changes".
- The label is exposed only while loading and updates on rebuild.
- It is ignored when `loadingChild` or `TransitionAnimationType.customBuilder`
  is used. Custom content must label itself; see the reference file.
- The package makes no live announcements. If an app needs one, use a separate
  status widget such as `Semantics(liveRegion: true)` whose text changes when
  the operation starts or finishes, never from `build` or animation frames.
- Icon-only buttons still need an idle label, such as `tooltip` on
  `AsyncIconButton` and `AsyncFloatingActionButton`, or `Semantics` around an
  icon-only Cupertino button.

## Theming

- Material buttons accept native `style`, and the matching theme (for example
  `ElevatedButtonThemeData`) applies as usual. Use the native `styleFrom`
  helpers, such as `FilledButton.styleFrom`, from `material_ui`.
- Elevated, Filled, Outlined, and Text buttons also accept nullable `padding`,
  `minimumSize`, `alignment`, `backgroundColor`, `foregroundColor`,
  `disabledBackgroundColor`, `disabledForegroundColor`, and `mouseCursor`,
  including icon, tonal, and null-icon variants. For each property and state,
  precedence is non-null shortcut, supplied `style`, family theme, then native
  defaults. Omit them to preserve native resolution. Enabled and disabled
  color overrides preserve the other state; loading uses disabled styling.
- The default Material spinner uses the effective style's enabled
  `foregroundColor`, then the family theme, then the ambient icon or text color.
  Set the shortcut or foreground color in `style` to change it; FABs use
  `foregroundColor`. Disabled-only shortcuts do not change the spinner color.
- Cupertino buttons accept native `sizeStyle`, `padding`, `color`,
  `foregroundColor`, `disabledColor`, `minimumSize`, `pressedOpacity`,
  `borderRadius`, `alignment`, and focus options. Use `minimumSize`; `minSize`
  is not available.
- The default `CupertinoActivityIndicator` uses `foregroundColor` or the theme
  primary color. Loading disables the native button, so filled and tinted
  buttons show `disabledColor` while loading; keep the foreground readable
  on it.

## Sizing

- The default `stack` transition keeps the idle content in the layout, so the
  default spinner normally fits within the idle size. A larger `loadingChild`
  can grow the button within its parent's and native constraints.
- `animatedSwitcher` keeps both sizes in layout while content fades and then
  animates the size change.
- Text scaling can enlarge buttons, and narrow parents can overflow or clip,
  as with native buttons. Keep labels short and test large text and narrow
  widths. When a fixed size matters, use `fixedSize` in a Material `style` or
  a `SizedBox` around the button, and size loading content to fit.
  `minimumSize` is only a lower bound.

## Review checklist

- Uses `material_ui` or `cupertino_ui` imports with v2, never
  `package:flutter/material.dart` types in button arguments.
- Every async `onPressed` returns or awaits its Future.
- `loading` is used only for application-owned state and is cleared by its owner.
- Any `AsyncButtonController` is created once, disposed by its owner, and
  used for one logical button.
- Mutually exclusive async buttons share an `AsyncButtonGroup`, and only
  deliberate escape actions use `excludeFromGroup: true`.
- `onError` is either omitted, letting errors propagate, or deliberately
  consumes errors and checks `mounted` before using state or context.
- Default spinners have a localized `loadingSemanticsLabel`; custom loading
  content carries its own labels.
- Custom builders follow the responsibilities in
  [references/customization.md](references/customization.md).
