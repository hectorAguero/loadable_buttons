## Unreleased

* Smoothly resize buttons in AnimatedSwitcher transitions when idle and loading
  content have different sizes.
* Center extended FAB stack loaders across the full icon-and-label area while
  retaining idle sizing and native padding and spacing.
* Block pointer input, focus, and semantics on inactive content in built-in
  loading transitions, including outgoing AnimatedSwitcher content in both
  directions. Current custom loading content remains usable.
* Mount extended FAB icons only once, preserve the native layout without an
  icon, and forward extended padding, icon spacing, and text style.
* Use the normal foreground from an explicit style or button theme for default
  spinners, falling back to the inherited Material foreground.

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
