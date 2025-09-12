## 1.0.0

* Fixed `loadingChild` rendering in `AsyncElevatedButton` when using `TransitionAnimationType.stack`
* Ensured loading indicators display correctly across all button variants
* Prevented multiple taps while an async operation is running in `AsyncIconButton`
* Verified and adjusted loading indicator color and opacity for `AsyncIconButton`
* Added assertions for `customBuilder` and `splashRadius` in `AsyncIconButton`
* Refactored `AsyncOutlinedButton` and `AsyncTextButton` tests for consistency
* Added comprehensive tests for `AsyncFloatingActionButton` (various states and transitions)
* Docs: Clarified `loadingChild` behavior with `TransitionAnimationType.stack` in README and added an 

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