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
flutter pub add loadable_buttons material_ui
```

### Importing
```dart
import 'package:material_ui/material_ui.dart';
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

## Compatibility and migration

Requires Flutter **3.47.0+**, Dart **3.13.0+**, and `material_ui` **1.4.0+**
(within the compatible 1.x range). The buttons use the standalone
[Material UI library](https://pub.dev/packages/material_ui).

When migrating from loadable_buttons 1.0.0:

1. Upgrade Flutter to a supported version and add `material_ui` as a direct
   dependency in your application.
2. Replace `import 'package:flutter/material.dart';` with
   `import 'package:material_ui/material_ui.dart';` in code that uses these buttons.
3. Use `MaterialApp`, themes, `ButtonStyle`, and other Material types from
   `material_ui` alongside loadable_buttons. The async button constructor names
   and loading options are unchanged, but Material-specific types now come from
   the standalone package. This is a breaking migration for consumers using the
   legacy Flutter Material types.

For applications that still contain legacy Material dependencies, follow the
[official migration guide](https://pub.dev/packages/material_ui#migrating-existing-code-to-this-package)
for `MaterialUiCompatibilityBridge` and localization migration. The bridge does
not make legacy and standalone Material types interchangeable in public APIs.
