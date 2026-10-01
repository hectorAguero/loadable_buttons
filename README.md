# loadable_buttons

A Flutter package that provides enhanced buttons with built-in loading states and async functionality.

![](https://raw.githubusercontent.com/hectorAguero/loadable_buttons/main/screenshots/preview.gif 'loadable_buttons')

## Features

- 🔄 Built-in loading states for:
  - ElevatedButton -> AsyncElevatedButton
  - FilledButton -> AsyncFilledButton
  - TextButton -> AsyncTextButton
  - OutlinedButton -> AsyncOutlinedButton
  - IconButton -> AsyncIconButton
  - FloatingActionButton -> AsyncFloatingActionButton
- ⚡ Async callback support
- 🎨 Multiple transition animations
- 🎯 Icon support with customizable alignment
- 📱 Maintains all standard properties
- ✨ Customizable loading indicators

## Usage

### Installation
Add the following to your `pubspec.yaml` or run:
```bash
flutter pub add loadable_buttons
```

### Importing
```dart
import 'package:loadable_buttons/loadable_buttons.dart';
```

### Basic Usage
```dart
AsyncElevatedButton(
  onPressed: () async {
    // Your async operation here
    await Future.delayed(const Duration(seconds: 2));
  },
  child: const Text('Click Me'),
);
```

### Custom Loading Child
```dart
AsyncElevatedButton(
  onPressed: () async {
    await Future.delayed(const Duration(seconds: 2));
  },
  child: const Text('Submit'),
  loadingChild: const Text('Loading...'),
);
```

### External Loading

The `loading` property controls an external loading source independently of the
button's own async callback. The button stays in its loading state while either
`loading` is `true` or its `onPressed` operation is pending. Setting `loading` to
`false` does not cancel or finish that operation, and completing the operation
does not clear external loading.

```dart
AsyncElevatedButton(
  loading: isSaving,
  onPressed: saveChanges,
  child: const Text('Save'),
);
```

This applies to all async button families and their constructor variants.
Elevated, Filled (including tonal), Outlined, and Text buttons disable both taps
and long presses while loading. Their disabled state also applies to keyboard
activation and accessibility semantics. Long-press-only buttons remain usable
when idle.

The internal loading state is restored even when the callback throws; error
handling remains the consumer's responsibility.

The `key` passed to any async button belongs to the async wrapper. You can use a
`GlobalKey` to access that wrapper, and rebuilding the same button variant with
the same key preserves its state, including a pending `onPressed` operation.

### Transition Types

The package supports three types of transitions:

1. Stack (Default) : Maintains the size of the button while loading
```dart
AsyncElevatedButton(
  // transitionType: TransitionAnimationType.stack,
  onPressed: () async => await yourAsyncFunction(),
  child: const Text('Stack Transition'),
);
```

Note: When using `TransitionAnimationType.stack`, providing a `loadingChild` will show it during the loading state while preserving the button size. This is useful for keeping layout stable while showing a loader or message.

Example with `loadingChild` and Stack transition:
```dart
AsyncElevatedButton(
  transitionType: TransitionAnimationType.stack,
  onPressed: () async {
    await Future.delayed(const Duration(seconds: 2));
  },
  child: const Text('Submit'),
  loadingChild: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      SizedBox(width: 8),
      Text('Submitting...'),
    ],
  ),
);
```

2. AnimatedSwitcher : Animates the size of the button while loading
```dart
AsyncElevatedButton(
  transitionType: TransitionAnimationType.animatedSwitcher,
  onPressed: () async => await yourAsyncFunction(),
  child: const Text('AnimatedSwitcher Transition'),
);
```

3. CustomBuilder : Allows you to define your own custom transition
```dart
AsyncElevatedButton(
  transitionType: TransitionAnimationType.customBuilder,
  onPressed: () async => await yourAsyncFunction(),
  child: const Text('Custom Transition'),
  loadingChild: const Text('Loading...'),
  customBuilder: (bool loading, Widget child, Widget? loadingChild) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: loading
          ? loadingChild!
          : child,
    );
  },
);
```

## Additional Features
- Customize animation duration
- Control minimum opacity during loading state
- Full access to ElevatedButton styling
- Manual loading state control
- Icon alignment customization

### Properties
| Property | Type | Description |
|----------|------|-------------|
| `onPressed` | `FutureOr<void> Function()?` | The callback that is called when the button is tapped |
| `child` | `Widget` | The primary content of the button |
| `loadingChild` | `Widget?` | Widget to show during loading state |
| `loading` | `bool` | Manual control of loading state |
| `transitionType` | `TransitionAnimationType` | Type of loading animation |
| `animationDuration` | `Duration` | Duration of the loading animation |
| `minimumChildOpacity` | `double` | Minimum opacity of child during loading |

## Compatibility Note

This package is designed and tested for the latest Flutter stable version. Due to limitations in older Flutter versions regarding parameter handling, using this package with older versions might lead to unexpected behavior or limitations. Alternatively, since the package is MIT licensed, you can copy the relevant code into your project and adapt it for older versions.


