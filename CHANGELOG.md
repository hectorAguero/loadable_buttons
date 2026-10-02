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
