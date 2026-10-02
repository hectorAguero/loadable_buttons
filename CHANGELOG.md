## 2.0.0 (unreleased)

* Add native `AsyncCupertinoButton`, `.filled`, and `.tinted` with Cupertino
  indicators, loading/error/accessibility contracts, and a standalone example.
  Add design-specific `cupertino.dart` and `material.dart` entry points while
  preserving the combined barrel. Depend directly on `cupertino_ui >=1.0.0 <2.0.0`
  and validate both design libraries at exact lower bounds and latest compatible
  versions on the minimum SDK and stable. Shared async/transition helpers use
  Flutter widgets; Material presentation helpers stay in a separate source file.

* Add optional localized `loadingSemanticsLabel` to every Material constructor,
  including tonal, selected-icon, and extended FAB loading paths. Labels apply
  only to default spinners; custom loading content owns its semantics and live
  announcements. Preserve null defaults and disabled outer button semantics.

* Add optional `onError` to every constructor with a shared
  `AsyncButtonErrorHandler` typedef. Successful handlers explicitly consume
  activation errors; absent handlers preserve the original error and stack trace.
  Async handlers retain the loading lock, handler failures propagate, and captured
  handlers still run after disposal without changing disposed widget state.

* **Breaking:** use standalone `material_ui >=1.0.0 <2.0.0` for all Material
  widgets and public types. Applications must import
  `package:material_ui/material_ui.dart` for themes and `ButtonStyle` values.
* **Breaking:** require Flutter >=3.44.0 and Dart >=3.12.0 <4.0.0.
* Honor inherited `FloatingActionButtonTheme` padding and icon spacing for
  extended FAB stack transitions, matching the native standalone button.
* Preserve native icon padding, loading ownership, selection, keyboard,
  semantics, and custom loading-content behavior across the migration.
* Validate exact Material UI 1.0.0 and the newest compatible resolution on
  both the minimum Flutter SDK and current stable. Run Solid Lints 1.0.0 and
  DCL 4.4.0 plugin checks on both SDKs, with an isolated DCL CLI graph that
  also supports Dart 3.12.
* Raise the Very Good Analysis development dependency minimum to 10.3.0 and
  use its Dart 3.12-compatible preset on both SDKs; allow 11.x on stable.

## 1.1.1

* Invoke Filled button custom builders only for custom transitions.
* Match native Material padding in Elevated, Filled (including tonal), Outlined,
  and Text icon-and-label buttons, including text scaling and RTL layouts.
* Preserve explicit and inherited theme padding, including state-dependent
  fallbacks.
* Center stack loading indicators within the whole button, including padding,
  for Material text buttons and extended floating action buttons. Preserve idle
  layout and custom loading-content interaction.

## 1.1.0

* Clarify the Dart requirement as >=3.7.0 <4.0.0, matching the existing Flutter 3.29.0 minimum.
* Preserve requested mouse cursors in all icon-button variants.
* Fix extended floating action button padding, icon spacing, and text styling on Flutter 3.29.
* Improve loading transitions with smooth resizing, centered extended FAB indicators, and correct layout when no icon is supplied.
* Prevent inactive loading-transition content from receiving pointer input, focus, or accessibility actions.
* Resolve default loading indicator colors from the button style or theme.
* Document loading ownership, consumer-owned errors, disabled and accessible
  behavior, custom builder responsibilities, sizing, and text scaling in the
  README and public API reference.
* Add runnable example controls for independent loading sources, completion and
  handled errors, disabled and long-press behavior, IconButton selection, and
  custom loading content and builders.

## 1.0.1

* Keep external `loading` and pending `onPressed` operations independent in all
  button families. Clearing external loading no longer unlocks a pending
  operation or allows duplicate execution.
* Keep public keys on the async wrapper, preventing duplicate `GlobalKey`
  errors. Rebuilding the same variant with the same key preserves its state
  and pending operation.
* Block long presses while Elevated, Filled (including tonal), Outlined, and
  Text buttons are loading, including callbacks captured before a rebuild.
  Their loading state also disables keyboard activation and reports disabled
  semantics; idle long-press-only buttons remain usable.
* Preserve native Material disabled behavior for null `onPressed` callbacks in
  IconButton and floating action button variants.
* Forward `onLongPress`, `onHover`, `onFocusChange`, and `focusNode` through the
  Elevated, Filled, Outlined, and Text `.icon` constructors when an icon is
  supplied, matching the null-icon fallback and Filled `.tonalIcon` behavior.
* Honor `isSelected`, `selectedIcon`, selection styling, and Material 3
  selection semantics in every `AsyncIconButton` variant. Selected icons keep
  their loading transitions and fall back to `icon` when omitted.

* Update analyzer and lint tooling, and add package, test, and example analysis
  to CI.

## 1.0.0

* Fixed `loadingChild` rendering in `AsyncElevatedButton` when using `TransitionAnimationType.stack`
* Ensured loading indicators display correctly across all button variants
* Prevented multiple taps while an async operation is running in `AsyncIconButton`
* Verified and adjusted loading indicator color and opacity for `AsyncIconButton`
* Added assertions for `customBuilder` and `splashRadius` in `AsyncIconButton`
* Refactored `AsyncOutlinedButton` and `AsyncTextButton` tests for consistency
* Added comprehensive tests for `AsyncFloatingActionButton` (various states and transitions)
* Docs: Clarified `loadingChild` behavior with `TransitionAnimationType.stack` in README.

## 0.2.0

* Add support for AsyncIconButton
* Add support for AsyncFloatingActionButton

## 0.1.0

* Add support for AsyncFilledButton and AsyncFilledButton.icon
* Add support for AsyncOutlinedButton and AsyncOutlinedButton.icon
* Add support for AsyncTextButton and AsyncTextButton.icon
* Add support for AsyncIconButton
* Improve Code Quality

## 0.0.1

* Add initial version of the package with AsyncElevatedButton and AsyncElevatedButton.icon implementations
