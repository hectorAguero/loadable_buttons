# loadable_buttons

Flutter Material buttons that show a loading indicator while your `onPressed`
callback runs. Use synchronous or asynchronous callbacks, control loading
externally, and customize the indicator and its transition.

![Async Material button examples](https://raw.githubusercontent.com/hectorAguero/loadable_buttons/main/screenshots/preview.gif)

## Installation

```sh
flutter pub add loadable_buttons
```

Or add the package to your `pubspec.yaml`:

```yaml
dependencies:
  loadable_buttons: ^1.0.1
```

The declared consumer requirements are Flutter **3.29.0 or later** and Dart
**3.6.0 or later, below 4.0.0**. The 1.x API uses Flutter's Material library:

```dart
import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
```

## Quick start

Paste this example into `lib/main.dart` in a Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: AsyncElevatedButton(
            onPressed: saveChanges,
            loadingSemanticsLabel: 'Saving',
            child: const Text('Save'),
          ),
        ),
      ),
    ),
  );
}

Future<void> saveChanges() async {
  // Replace this delay with your application's async operation.
  await Future<void>.delayed(const Duration(seconds: 2));
}
```

The button manages its own loading state. A pending `onPressed` operation
prevents another activation, including another press before the next frame.
Loading ends when the returned Future completes.

The snippets below reuse `saveChanges` from this example.

## Button families

| Material button | Async wrapper | Constructors |
| --- | --- | --- |
| `ElevatedButton` | `AsyncElevatedButton` | Default, `.icon` |
| `FilledButton` | `AsyncFilledButton` | Default, `.icon`, `.tonal`, `.tonalIcon` |
| `OutlinedButton` | `AsyncOutlinedButton` | Default, `.icon` |
| `TextButton` | `AsyncTextButton` | Default, `.icon` |
| `IconButton` | `AsyncIconButton` | Default, `.filled`, `.filledTonal`, `.outlined` |
| `FloatingActionButton` | `AsyncFloatingActionButton` | Default, `.small`, `.large`, `.extended` |

Use Material options such as `style`, `focusNode`, and `autofocus` on the
corresponding wrapper. Available options depend on the button family; see the
[API reference](https://pub.dev/documentation/loadable_buttons/latest/).

```dart
AsyncFilledButton.tonalIcon(
  onPressed: saveChanges,
  icon: const Icon(Icons.save_outlined),
  label: const Text('Save changes'),
  iconAlignment: IconAlignment.start,
);
```

The `.icon` constructors for Elevated, Filled, Outlined, and Text buttons, and
Filled's `.tonalIcon`, forward `onLongPress`, `onHover`, `onFocusChange`, and
`focusNode` whether an icon is supplied or null.

## Loading behavior

`onPressed` accepts a nullable `FutureOr<void> Function()`. Return the Future
for the work the button should wait for. Starting work without returning or
awaiting it does not keep the button loading until that work finishes.

External `loading` and the button's pending callback are independent sources.
The button is loading while **either source is active**:

```dart
// isSaving is a bool managed by your application.
AsyncElevatedButton(
  loading: isSaving,
  onPressed: saveChanges,
  child: const Text('Save'),
);
```

Setting `loading: false` does not finish or cancel a pending operation.
Completing that operation does not clear `loading: true`.

The button clears its internal loading state in `finally`, even if the callback
throws. It does not swallow exceptions or choose an error policy. Handle
application errors in your callback, including any error message or retry UI.
Disposing the button does not cancel the operation; callbacks that update
application state after an `await` should check their own lifecycle.

### Disabled buttons and long press

A null `onPressed` preserves the underlying Material button's disabled
styling, focus, and semantics. Elevated, Filled, Outlined, and Text buttons can
remain enabled with only an `onLongPress` callback while idle. IconButton and
floating action buttons require `onPressed` to be enabled.

```dart
const AsyncOutlinedButton(
  onPressed: null,
  child: Text('Unavailable'),
);
```

While loading, Elevated, Filled, Outlined, and Text buttons block both tap and
long-press callbacks, keyboard activation, and the button's semantic actions.
An async operation is managed through `onPressed`; `onLongPress` remains a
synchronous callback.

### Keys and rebuilds

The public `key` belongs to the async wrapper. A `GlobalKey` can identify that
wrapper without being duplicated on the underlying Material widget. Rebuilding
the same button variant with the same key preserves its state and pending work.

## Custom loading content

Supply `loadingChild` to replace the default circular indicator:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  loadingChild: const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      semanticsLabel: 'Saving',
    ),
  ),
  child: const Text('Save'),
);
```

`AsyncElevatedButton` also accepts `loadingSemanticsLabel` for its default
indicator. When supplying custom loading content, provide its own appropriate
semantics. Keep loading content presentational; nested interactive widgets
need their own interaction, focus, and accessibility handling.

## Transitions and sizing

| `TransitionAnimationType` | Behavior |
| --- | --- |
| `stack` (default) | Retains idle content in the layout and fades the loading content over it. |
| `animatedSwitcher` | Switches between idle and loading content with a fade and animated size. |
| `customBuilder` | Delegates content and transition rendering to your builder. |

The default stack helps keep the idle footprint, but a larger `loadingChild`
can increase the size of the content. Button constraints and text scaling also
affect layout. Constrain custom loading content when a stable footprint matters.

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.animatedSwitcher,
  animationDuration: const Duration(milliseconds: 250),
  loadingChild: const Text('Saving...'),
  child: const Text('Save'),
);
```

For a custom transition, `customBuilder` receives the effective loading state,
idle content, and nullable `loadingChild`. It must be supplied when selecting
`TransitionAnimationType.customBuilder`. Supply a fallback if you leave
`loadingChild` null:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.customBuilder,
  loadingChild: const Text('Saving...'),
  customBuilder: (loading, child, loadingChild) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(loading),
        child: loading
            ? (loadingChild ?? const CircularProgressIndicator())
            : child,
      ),
    );
  },
  child: const Text('Save'),
);
```

The builder owns its layout, outgoing content, semantics, and any nested
interaction. Fading content alone does not remove its interaction or semantic
actions. Check both directions of custom transitions with your application's
text scale, theme, and available space.

## IconButton selection

All `AsyncIconButton` variants honor `isSelected` and `selectedIcon` with a
Material 3 theme. This wrapper's `isSelected` takes a state property, so wrap a
simple bool in `WidgetStatePropertyAll`.

```dart
// In a State object's build method; isFavorite is a bool field.
AsyncIconButton.filled(
  tooltip: 'Toggle favorite',
  isSelected: WidgetStatePropertyAll(isFavorite),
  icon: const Icon(Icons.favorite_border),
  selectedIcon: const Icon(Icons.favorite),
  onPressed: () async {
    await saveChanges();
    if (!mounted) return;
    setState(() => isFavorite = !isFavorite);
  },
);
```

Selection uses the current value supplied by your application. If
`selectedIcon` is omitted, `icon` is used for both states. Both icons use the
configured loading transition, and the current selection is shown after loading
ends. A null `isSelected` keeps normal push-button behavior.

The selection property is resolved with the disabled state while loading or
when `onPressed` is null, and an empty state set otherwise.

## Common loading options

| Option | Default | Purpose |
| --- | --- | --- |
| `loading` | `false` | External loading source, combined with internal loading. |
| `loadingChild` | Default indicator | Custom loading content. |
| `transitionType` | `TransitionAnimationType.stack` | Content transition. |
| `animationDuration` | `Durations.medium1` | Built-in transition duration. |
| `minimumChildOpacity` | `0.0` | Idle content opacity during a stack transition. |
| `customBuilder` | `null` | Required for `TransitionAnimationType.customBuilder`. |

## Example and development

The [example application](https://github.com/hectorAguero/loadable_buttons/tree/main/example)
demonstrates the button families, icon variants, transitions, and themes:

```sh
cd example
flutter pub get
flutter run
```

For contributing, use a Flutter SDK with Dart **3.13 or later** for the current
development lint tooling. This is separate from the consumer requirements above.
From the repository root, run:

```sh
flutter pub get
bash tool/analyze.sh
dart run dart_code_linter:metrics analyze lib test example/lib --fatal-style --fatal-performance
flutter test --no-pub
dart format --output=none --set-exit-if-changed lib test example/lib
```

Report bugs or propose improvements in the
[issue tracker](https://github.com/hectorAguero/loadable_buttons/issues).
See the [changelog](CHANGELOG.md) for release notes and the [MIT license](LICENSE)
for licensing.
