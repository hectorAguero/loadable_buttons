# loadable_buttons

Flutter Material buttons with automatic loading states, external loading control,
and customizable indicators and transitions.

![Async Material button examples](https://raw.githubusercontent.com/hectorAguero/loadable_buttons/main/screenshots/preview.gif)

## Installation

```sh
flutter pub add loadable_buttons
flutter pub add material_ui
```

Version 2 requires Flutter **3.44.0+**, Dart **3.12.0+ (below 4.0.0)**,
and **material_ui >=1.0.0 <2.0.0**. Pub selects a compatible Material UI
release for your SDK; Material UI 1.4.0 and newer require Flutter 3.47 / Dart 3.13.
Version 1.x remains the compatibility line for Flutter 3.29 and the built-in
Material library. See the [compatibility roadmap](doc/compatibility-roadmap.md).

## Quick start

Paste this example into `lib/main.dart` in a Flutter application:

```dart
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

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

## Migrating from 1.x

Add `material_ui` as a direct dependency and replace
`package:flutter/material.dart` imports with `package:material_ui/material_ui.dart`.
Create `MaterialApp`, themes, styles, and ink factories from that package too.
Material types such as `ButtonStyle`, `ThemeData`, `IconAlignment`, and
`InteractiveInkFeatureFactory` are distinct from their legacy Flutter types;
legacy values cannot be passed to the v2 constructors. Widget state types
continue to come from Flutter's widgets library.

If your app uses Material localizations, use the standalone
`GlobalMaterialLocalizations.delegates`. Applications with dependencies that
still use Flutter's built-in Material widgets can wrap those subtrees in
`MaterialUiCompatibilityBridge` under a standalone `MaterialApp`:

```dart
MaterialApp(
  builder: (context, child) => MaterialUiCompatibilityBridge(
    child: child ?? const SizedBox.shrink(),
  ),
  home: const HomeScreen(), // Your application's screen.
);
```

The bridge supplies legacy themes and localizations; it does not convert legacy
style arguments to standalone types. See the
[official Material UI migration guide](https://pub.dev/packages/material_ui#migrating-existing-code-to-this-package).

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
loading while **either is active**, including any pending `onError` handler.

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

### Callback errors

All constructors accept an optional `onError` callback using the exported
`AsyncButtonErrorHandler` typedef:
`FutureOr<void> Function(Object error, StackTrace stackTrace)`.

Without `onError`, a synchronous throw or failed callback Future propagates
with its original stack trace. Material activation accepts a synchronous
callback, so unhandled errors reach the caller's zone through the package's
handler Future.

**Supplying `onError` explicitly consumes the callback error** when the handler
completes successfully. The package does not also log or report it. Choose your
application's feedback or reporting policy:

```dart
AsyncElevatedButton(
  onPressed: saveChanges,
  onError: (error, stackTrace) {
    debugPrint('Saving failed: $error\n$stackTrace');
  },
  child: const Text('Save'),
);
```

The handler receives the original error and stack trace exactly once. It may be
async; the button stays loading and locked until it finishes. Internal loading
then clears, including when the handler itself throws or returns a failed Future.
A handler failure propagates with its own stack trace and does not call `onError`
again. External `loading` remains independent throughout. This hook handles only
`onPressed` errors; synchronous `onLongPress` callbacks and presentation builders
retain their normal behavior.

Each activation captures its callback and handler before starting; rebuilding
with a different handler affects the next activation. Disposing the widget does
not cancel the operation or suppress the captured handler. No `BuildContext` is
supplied. Check your own `mounted` before accessing captured state or context,
including in `onError`.

Launching work without returning or awaiting its Future ends the tracked callback
early. The button cannot track that work or handle its later errors. See the
[shared callback error policy](doc/callback-error-policy.md) for future controller
and Cupertino/adaptive implementations.

Set `onPressed: null` to disable a button. Elevated, Filled, Outlined, and Text
buttons remain enabled if `onLongPress` is provided; loading blocks both
callbacks. `onLongPress` is synchronous and does not start a loading state.
IconButton forwards its long-press callback to Material UI's native IconButton;
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
Stack indicators are centered within the whole button, including padding, even
when icon-and-label variants use asymmetric padding or content alignment.
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

Every constructor accepts `loadingSemanticsLabel` for its default spinner,
including icon, tonal, selected IconButton, and extended FAB variants. The
default is `null`; the package supplies no English text. Use your application's
localized strings for both the idle action and the loading operation:

```dart
// l10n is your application's localization object for the current context.
AsyncFilledButton.icon(
  onPressed: saveChanges,
  loadingSemanticsLabel: l10n.savingChanges,
  icon: const Icon(Icons.save_outlined),
  label: Text(l10n.save),
);
```

The label follows the current locale when the widget rebuilds. It is exposed
only while loading, for either external `loading` or a pending callback.
The outer button keeps its disabled button semantics; the spinner adds no
button role or activation action.

Custom content owns its accessible labels and progress values. For example,
the following uses your application's localized strings and a progress value
between `0.0` and `1.0`:

```dart
AsyncFilledButton(
  onPressed: saveChanges,
  loadingChild: SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(
      value: progress,
      semanticsLabel: l10n.savingChanges,
      semanticsValue: l10n.percentComplete((progress * 100).round()),
    ),
  ),
  child: Text(l10n.save),
);
```

`loadingSemanticsLabel` is ignored when you supply `loadingChild` or use a custom
builder, so custom labels are never silently duplicated. This includes builders
that receive a null `loadingChild`; the package supplies neither a default
spinner nor a semantics wrapper in custom-builder mode. Built-in transitions
exclude inactive content from semantics, so a hidden idle label is not a
substitute for labeling the loading content.

The package does not request live announcements. If your application needs
them, opt in separately, such as a `Semantics(liveRegion: true)` status message
whose text changes when an operation starts or finishes. Trigger explicit
announcements from operation state changes, never from `build` or animation
frames. See the [shared loading semantics policy](doc/loading-semantics-policy.md)
for the contract future Cupertino/adaptive constructors must follow.

An intentional Cancel action may remain accessible inside current loading
content, while the outer button stays disabled:

```dart
AsyncOutlinedButton(
  onPressed: saveChanges,
  loadingChild: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(semanticsLabel: l10n.savingChanges),
      ),
      TextButton(
        onPressed: cancelSave,
        child: Text(l10n.cancel),
      ),
    ],
  ),
  child: Text(l10n.save),
);
```

`cancelSave` belongs to your operation's cancellation API. The callback Future
must finish before internal loading clears, and external loading must be cleared
by its owner. A Cancel label alone does not cancel work. The
[example application](example/lib/loading_contract_demo.dart) demonstrates this
with a controlled Future, accessible custom progress, and a Cancel action.

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
state, error handling, and indicators, and `loading_transition.dart` for the enum
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
