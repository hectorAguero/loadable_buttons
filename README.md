# loadable_buttons

Flutter Material buttons with automatic loading states, external loading control,
and customizable indicators and transitions.

![Async Material button examples](https://raw.githubusercontent.com/hectorAguero/loadable_buttons/main/screenshots/preview.gif)

## Installation

```sh
flutter pub add loadable_buttons
```

Requires Flutter **3.29.0+** and Dart **3.7.0+ (below 4.0.0)**.
Version 1.x uses Flutter's Material library.
The planned SDK and Material UI migrations are described in the
[compatibility roadmap](docs/compatibility-roadmap.md); they are future release
targets, not features of 1.1.

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

Choose the error policy in your application, for example:

```dart
AsyncElevatedButton(
  onPressed: () async {
    try {
      await saveChanges();
    } catch (error) {
      // Replace this with your application's feedback or retry policy.
      debugPrint('Saving failed: $error');
    }
  },
  child: const Text('Save'),
);
```

Launching work without returning or awaiting its Future ends the tracked callback
early. The button cannot track that work or handle its later errors.

Set `onPressed: null` to disable a button. Elevated, Filled, Outlined, and Text
buttons remain enabled if `onLongPress` is provided; loading blocks both
callbacks. `onLongPress` is synchronous and does not start a loading state.
IconButton forwards its long-press callback to Flutter's native IconButton;
floating action buttons have no long-press parameter. Native Material styling,
focus, and semantics determine the disabled appearance for each family.

Enabled buttons retain native keyboard activation. Loading disables the outer
button's activation and reports it as disabled to accessibility services. For
built-in transitions, inactive idle content and outgoing switcher content cannot
receive pointer input, keyboard focus, or accessibility actions, even when
`minimumChildOpacity` makes idle content partially visible. Current loading
content may still contain an intentional action, such as Cancel.

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
defaults to `0.0` for stack transitions.

### Sizing and text scaling

Stack retains the idle content's layout, so a smaller indicator normally fits
within the idle size. A larger `loadingChild` can expand the button within its
parent and Material constraints. Stack does not guarantee a fixed size.
Animated switcher keeps both sizes in the layout while outgoing content fades;
the shared layout animates its resize, including the shrink after that content
is removed.

Text follows the ambient text scale, which can increase button size. Icon-and-label
buttons also scale their spacing. Extended FAB stack transitions retain the icon
area; padding and text styling follow Material. Fixed-size FAB variants retain
Material's constraints.
Oversized content or narrow parents can still overflow or clip, as with native
Material buttons. Use short labels, test large text and narrow layouts, and
constrain both idle and loading content when a stable size is required.

### Accessible loading content

Supply a localized label for your operation. `AsyncElevatedButton` supports
`loadingSemanticsLabel` on its default spinner, including `.icon`. Other families
can use a labeled custom indicator:

```dart
AsyncFilledButton(
  onPressed: saveChanges,
  loadingChild: const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(semanticsLabel: 'Saving changes'),
  ),
  child: const Text('Save'),
);
```

`loadingSemanticsLabel` is ignored when you supply `loadingChild` or use a custom
builder. Consumers own custom content labels, progress values, and any live
announcements; the package adds no default localized announcement. Built-in
transitions exclude inactive content from semantics, so a hidden idle label is
not a substitute for labeling the loading content.

### Custom builders

Select `customBuilder` and provide the builder together. It receives effective
loading, idle content, and the supplied nullable `loadingChild`; the package does
not substitute its default spinner in this mode. A builder that replaces content
immediately can avoid retaining an inactive subtree:

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  transitionType: TransitionAnimationType.customBuilder,
  customBuilder: (loading, child, loadingChild) => loading
      ? loadingChild ??
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(semanticsLabel: 'Saving changes'),
          )
      : child,
  child: const Text('Save'),
);
```

If your builder retains or animates both states, it owns sizing and must isolate
inactive and outgoing content with `IgnorePointer`, `ExcludeFocus`, and
`ExcludeSemantics`. Opacity alone does not disable interaction. The outer button
still manages loading and its callback lock. Extended FABs can invoke the builder
separately for their icon and label; account for both slots.

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

Include any companion `part` files, `async_button_helpers.dart` for shared loading
state and indicators, and `loading_transition.dart` for the transition enum
and widgets. Update package imports to match your project.

For a single-file copy, inline the shared loading helper declarations, move the
enum into your button file, and inline the transition bodies. This outline shows the ternary and switch structure:

```dart
child: widget.transitionType == TransitionAnimationType.customBuilder
    ? widget.customBuilder
            ?.call(_isLoading, widget.child, widget.loadingChild) ??
        widget.child
    : switch (widget.transitionType) {
        TransitionAnimationType.stack => Stack(
            // Inline the guarded stack transition here.
          ),
        TransitionAnimationType.animatedSwitcher => AnimatedSwitcher(
            duration: widget.animationDuration,
            // Inline the guarded switcher transition here.
          ),
        TransitionAnimationType.customBuilder => widget.child,
      },
```

Copy the transition bodies from [loading_transition.dart](lib/src/loading_transition.dart),
including the pointer, focus, and semantics guards for inactive and outgoing content.

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
