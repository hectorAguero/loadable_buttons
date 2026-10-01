# loadable_buttons

Flutter Material buttons with automatic loading states, external loading control,
and customizable indicators and transitions.

![Async Material button examples](https://raw.githubusercontent.com/hectorAguero/loadable_buttons/main/screenshots/preview.gif)

## Installation

```sh
flutter pub add loadable_buttons
```

Requires Flutter **3.29.0+** and Dart **3.6.0+ (below 4.0.0)**.
Version 1.x uses Flutter's Material library.

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

The button shows a spinner and prevents repeated activation until the returned
Future completes. The following examples reuse `saveChanges`.

## Button families

| Widget | Constructors |
| --- | --- |
| `AsyncElevatedButton` | Default, `.icon` |
| `AsyncFilledButton` | Default, `.icon`, `.tonal`, `.tonalIcon` |
| `AsyncOutlinedButton` | Default, `.icon` |
| `AsyncTextButton` | Default, `.icon` |
| `AsyncIconButton` | Default, `.filled`, `.filledTonal`, `.outlined` |
| `AsyncFloatingActionButton` | Default, `.small`, `.large`, `.extended` |

Use the corresponding Material options, such as `style` and `focusNode`.
For each widget's supported properties, see the
[API reference](https://pub.dev/documentation/loadable_buttons/latest/).

For a button with an icon, use `label` instead of `child`:

```dart
AsyncFilledButton.icon(
  onPressed: saveChanges,
  icon: const Icon(Icons.save_outlined),
  label: const Text('Save changes'),
);
```

## Loading behavior

`onPressed` accepts synchronous or asynchronous callbacks. Return or await your
async work so the button can track its completion.

External `loading` and a pending callback are independent: the button stays
loading while **either is active**.

```dart
// isSaving is a bool managed by your application.
AsyncElevatedButton(
  loading: isSaving,
  onPressed: saveChanges,
  child: const Text('Save'),
);
```

Setting `loading: false` does not cancel or unlock a pending callback. Likewise,
finishing the callback does not clear external `loading: true`.

Internal loading clears even if the callback throws. Exceptions are not swallowed;
handle errors in your callback. Disposing the widget does not cancel the operation.
Check `mounted` before updating your widget's state after an `await`.

Set `onPressed: null` to disable a button. Elevated, Filled, Outlined, and Text
buttons remain enabled if `onLongPress` is provided; loading blocks both
callbacks. `onLongPress` is synchronous and does not start a loading state.

## Customization

Replace the spinner with `loadingChild` and choose a transition:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  loadingChild: const Text('Saving...'),
  transitionType: TransitionAnimationType.animatedSwitcher,
  animationDuration: const Duration(milliseconds: 250),
  child: const Text('Save'),
);
```

| `TransitionAnimationType` | Behavior |
| --- | --- |
| `stack` (default) | Keeps idle content in the layout and fades loading content over it. |
| `animatedSwitcher` | Fades between content; outgoing content stays in the layout until its fade ends. |
| `customBuilder` | Uses your required `customBuilder(loading, child, loadingChild)`. |

`animationDuration` defaults to `Durations.medium1`; `minimumChildOpacity`
defaults to `0.0` for stack transitions. Custom builders must handle a nullable
`loadingChild` and manage outgoing content, interaction, and semantics.

Built-in transitions immediately block pointer input, keyboard focus, and
semantics on inactive content, including outgoing switcher content. A nonzero
`minimumChildOpacity` only changes appearance; idle content remains inactive
while loading. Current custom loading content may still provide actions such as
canceling an operation.

A stack keeps idle content in the layout. Loading content that is larger can
expand the button within its Material and parent constraints. Constrain both
states if you need a stable size. Extended FABs keep their icon area with stack
transitions and honor `extendedPadding`, `extendedIconLabelSpacing`, and
`extendedTextStyle`. The default spinner uses an explicit foreground color when
provided, then the foreground inherited from the Material button theme.

Loading labels remain opt-in: the default is `null`, with no built-in localized
announcement. `AsyncElevatedButton` supports `loadingSemanticsLabel` for its
default spinner. Every family accepts a `loadingChild` with its own semantics:

```dart
loadingChild: const SizedBox.square(
  dimension: 16,
  child: CircularProgressIndicator(semanticsLabel: 'Saving'),
),
```

Supply localized labels appropriate to your operation. When using `loadingChild`
or `customBuilder`, your application owns the indicator's semantics and any
announcements. See the [loading transition audit](docs/loading-transition-audit.md)
for the confirmed failures and layout findings.

## IconButton selection

With a Material 3 theme, use `isSelected` and `selectedIcon` on any
`AsyncIconButton` variant. Wrap a bool in `WidgetStatePropertyAll`:

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

Your application owns the selection state. If `selectedIcon` is omitted,
`icon` is used for both states.

## FAQ

<details>
<summary>Can I copy a button into my project?</summary>

Yes! The code is [MIT licensed](LICENSE). Feel free to browse the
[button implementations](https://github.com/hectorAguero/loadable_buttons/tree/main/lib/src),
copy a button into your project, and adapt it, including for commercial use.
Keep the copyright and MIT license notice with the copied code.

Include any companion `part` files, the shared `loading_transition.dart` helper,
and referenced types, and update package
imports to match your project.

</details>

<details>
<summary>Do I need a controller or state management package?</summary>

No. Return your operation's Future from `onPressed` and the button manages its
loading state. Use `loading` when your application already manages that state.

</details>

## More

- [Example application](https://github.com/hectorAguero/loadable_buttons/tree/main/example)
- [Contributing and development checks](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Issues and feature requests](https://github.com/hectorAguero/loadable_buttons/issues)
- [MIT license](LICENSE)
