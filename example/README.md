# loadable_buttons example

A Flutter application demonstrating the async button families, icon variants,
loading transitions, and theme colors. It uses the package from the parent
directory through a path dependency.

Requires Flutter 3.44.0 / Dart 3.12.0 or newer, standalone Material UI and
Cupertino UI >=1.0.0 <2.0.0, and uses the implemented, unreleased v2 API.
The parent path dependency deliberately runs repository source even while
pub.dev still provides 1.x. See the [migration guide](../doc/migration-v2.md)
and [release validation](../doc/release-validation.md).

From this directory, run:

```sh
flutter pub get
flutter run
```

Use the dropdowns to choose Stack or Animated switcher and a theme color. Enter
a loading duration from 0 to 60 seconds; invalid input disables the timed demos.
The gallery and floating action buttons run the timed operation. Animated switcher
also alternates the idle button label after completion.

The **Loading contracts** card provides runnable examples:

- Click **Start operation**, turn **External loading** on and off, and observe
  that the button remains locked until **Finish operation** or **Fail operation**.
  Finish with external loading still on to see that callback completion does not
  clear the external source. Turn external loading off to unlock the button.
- **Fail operation** simulates an error consumed by the supplied `onError`
  handler. The result text shows the chosen feedback; the button restores its
  internal state. Omitting `onError` lets callback errors propagate. Applications
  still own reporting, user feedback, and cancellation policy.
- Turn **Disable demo buttons** on to supply null callbacks. Long-press
  **Start operation** while idle to increment its counter without starting a
  Future. Loading and disabled states block that callback. Use Tab and keyboard
  activation to try the native Material focus and activation behavior.
- Click the heart to update application-owned IconButton selection after the
  timed Future completes. Try it with either built-in transition.
- Click **Custom builder** to replace idle content immediately with a labeled
  indicator. This builder retains no inactive subtree; a builder that animates
  outgoing content must also guard pointer input, focus, and semantics.
- Enable **Larger loading content** and **Large demo text (2×)**, then resize the
  window and try both transitions. Larger content can change button size within
  the parent and Material constraints; small layouts scroll and button rows wrap.

External loading and disabled switches affect the contract card, while the gallery
keeps its original timed behavior. The demo supplies English accessibility labels
and a live result region as an example of application-owned semantics. Localize
these labels and announcements in your application.

See the [package README](../README.md) for installation, external loading,
selection, custom content, and error handling guidance.

For a migration smoke check, activate a plain and icon button, repeat the loading
ownership sequence above, and try the custom builder and handled failure. Inspect
the disabled outer button and the loading label with platform accessibility tools.
Custom content supplies its own labels; the package adds no live announcement.

The standalone Cupertino example uses no Material ancestor:

```sh
flutter run -t lib/cupertino_main.dart
```

Try default, filled, and tinted buttons, the external loading and disabled
switches, idle long presses, custom loading content, and a handled failure.
It imports `package:loadable_buttons/cupertino.dart` and
`package:cupertino_ui/cupertino_ui.dart`.
