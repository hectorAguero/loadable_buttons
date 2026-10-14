import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/async_cupertino_button.dart';
import 'package:loadable_buttons/src/async_filled_button.dart';
import 'package:loadable_buttons/src/async_text_button.dart';
import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

enum _AsyncAdaptiveButtonVariant { plain, filled, tinted }

/// An async button that renders a native Material or Cupertino button for the
/// current platform.
///
/// | Constructor | Material | Cupertino |
/// | --- | --- | --- |
/// | default | `AsyncTextButton` | `AsyncCupertinoButton` |
/// | `.filled` | `AsyncFilledButton` | `AsyncCupertinoButton.filled` |
/// | `.tinted` | `AsyncFilledButton.tonal` | `AsyncCupertinoButton.tinted` |
///
/// Like Flutter's `.adaptive` constructors, iOS and macOS render Cupertino and
/// Android, Fuchsia, Linux, and Windows render Material. The platform is
/// [platform] when supplied, otherwise `Theme.of(context).platform`, which
/// follows `ThemeData.platform` and, without a theme, the default target
/// platform (on the web, the browser's reported platform). Elevated, outlined,
/// icon, and floating action buttons have no Cupertino equivalent; use their
/// concrete widgets.
///
/// Material output needs a Material ancestor, such as a `Scaffold`, like any
/// Material button. Cupertino output needs no Material ancestor.
///
/// Loading, error, semantics, [controller], and [AsyncButtonGroup] behavior
/// are those of the rendered button. A pending operation keeps the button
/// loading and locked when the platform or theme changes mid-operation: this
/// widget tracks the `onPressed` and `onError` work it starts, independent of
/// [controller], so a newly rendered button stays locked until that work
/// finishes. The work is neither repeated nor cancelled. A focused button
/// keeps keyboard focus across the change.
///
/// Shared properties apply on both platforms. Properties without an
/// equivalent are scoped by name: [materialStyle] and [cupertinoSizeStyle].
class AsyncAdaptiveButton extends StatefulWidget {
  /// Creates a text-style button: [AsyncTextButton] or [AsyncCupertinoButton].
  const AsyncAdaptiveButton({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.mouseCursor,
    this.padding,
    this.minimumSize,
    this.alignment,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.animationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.platform,
    this.materialStyle,
    this.cupertinoSizeStyle = CupertinoButtonSize.large,
    super.key,
  }) : _variant = _AsyncAdaptiveButtonVariant.plain;

  /// Creates a filled button: [AsyncFilledButton] or
  /// [AsyncCupertinoButton.filled].
  const AsyncAdaptiveButton.filled({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.mouseCursor,
    this.padding,
    this.minimumSize,
    this.alignment,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.animationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.platform,
    this.materialStyle,
    this.cupertinoSizeStyle = CupertinoButtonSize.large,
    super.key,
  }) : _variant = _AsyncAdaptiveButtonVariant.filled;

  /// Creates a tinted button: [AsyncFilledButton.tonal] or
  /// [AsyncCupertinoButton.tinted].
  const AsyncAdaptiveButton.tinted({
    required this.child,
    required this.onPressed,
    this.onError,
    this.controller,
    this.excludeFromGroup = false,
    this.loading = false,
    this.loadingChild,
    this.loadingSemanticsLabel,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.mouseCursor,
    this.padding,
    this.minimumSize,
    this.alignment,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.animationDuration,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.platform,
    this.materialStyle,
    this.cupertinoSizeStyle = CupertinoButtonSize.large,
    super.key,
  }) : _variant = _AsyncAdaptiveButtonVariant.tinted;

  /// The idle button content.
  final Widget child;

  /// The synchronous or asynchronous activation callback.
  ///
  /// Return or await async work to keep the button loading until it completes.
  /// Null disables the button unless [onLongPress] is supplied.
  final FutureOr<void> Function()? onPressed;

  /// The optional handler that explicitly consumes errors from [onPressed].
  ///
  /// See [AsyncButtonErrorHandler] for the shared policy.
  final AsyncButtonErrorHandler? onError;

  /// An optional controller that observes and requests loading.
  ///
  /// Passed to the rendered button. The caller owns and disposes it. Pending
  /// work stays locked across platform changes with or without a controller,
  /// including when it is replaced mid-operation.
  final AsyncButtonController? controller;

  /// Whether this button ignores the nearest [AsyncButtonGroup].
  final bool excludeFromGroup;

  /// Whether the application requests external loading.
  ///
  /// Defaults to false. Setting it to false neither cancels nor unlocks a
  /// pending [onPressed] or [onError].
  final bool loading;

  /// Optional loading content, replacing the platform's default indicator.
  final Widget? loadingChild;

  /// The optional localized accessibility label for the default indicator.
  final String? loadingSemanticsLabel;

  /// The synchronous long-press callback, blocked while loading.
  final VoidCallback? onLongPress;

  /// An optional focus node for the rendered button.
  final FocusNode? focusNode;

  /// Whether the rendered button requests focus when first built.
  final bool autofocus;

  /// Called when the rendered button gains or loses focus.
  final ValueChanged<bool>? onFocusChange;

  /// The mouse cursor over the enabled button.
  final MouseCursor? mouseCursor;

  /// The padding inside the button, replacing each platform's default.
  final EdgeInsetsGeometry? padding;

  /// The minimum button size, replacing each platform's default.
  final Size? minimumSize;

  /// The alignment of the content within the button.
  final AlignmentGeometry? alignment;

  /// The enabled background color: Material `backgroundColor` or Cupertino
  /// `color`.
  final Color? backgroundColor;

  /// The disabled background color: Material `disabledBackgroundColor` or
  /// Cupertino `disabledColor`, defaulting to each platform's value.
  ///
  /// Applies while the button is disabled, loading, or blocked by a group peer.
  final Color? disabledBackgroundColor;

  /// The enabled foreground color for text and icons.
  final Color? foregroundColor;

  /// The loading transition duration, defaulting to each platform's value.
  final Duration? animationDuration;

  /// The idle content opacity while stack loading is active.
  final double minimumChildOpacity;

  /// The transition between idle and loading content.
  final TransitionAnimationType transitionType;

  /// Builds loading content for [TransitionAnimationType.customBuilder].
  final Widget Function(bool loading, Widget child, Widget? loadingChild)?
  customBuilder;

  /// The platform to render for, overriding `Theme.of(context).platform`.
  final TargetPlatform? platform;

  /// The Material [ButtonStyle], ignored when rendering Cupertino.
  ///
  /// Shared properties such as [padding] and [foregroundColor] take precedence
  /// over this style, per property and state.
  final ButtonStyle? materialStyle;

  /// The Cupertino button size, ignored when rendering Material.
  final CupertinoButtonSize cupertinoSizeStyle;

  final _AsyncAdaptiveButtonVariant _variant;

  @override
  State<AsyncAdaptiveButton> createState() => _AsyncAdaptiveButtonState();
}

class _AsyncAdaptiveButtonState extends State<AsyncAdaptiveButton> {
  // Operations started by any rendered button, including onError. A button
  // rendered after a platform change shows loading until they finish,
  // independent of which controller, if any, is supplied.
  int _pendingOperations = 0;
  FocusNode? _ownedFocusNode;

  // A stable node keeps primary focus when a platform change swaps the
  // rendered button, since the new Focus adopts it in the same frame.
  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownedFocusNode ??= FocusNode(debugLabel: 'AsyncAdaptiveButton'));

  FutureOr<void> Function()? get _onPressed {
    final FutureOr<void> Function()? onPressed = widget.onPressed;

    return onPressed == null ? null : () => _track(onPressed);
  }

  AsyncButtonErrorHandler? get _onError {
    final AsyncButtonErrorHandler? onError = widget.onError;

    return onError == null
        ? null
        : (error, stackTrace) => _track(() => onError(error, stackTrace));
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  FutureOr<void> _track(FutureOr<void> Function() work) {
    _pendingOperations++;
    final FutureOr<void> result;
    try {
      result = work();
    } on Object {
      _finish();
      rethrow;
    }
    if (result is Future<void>) {
      unawaited(_finishAfter(result));
    } else {
      _finish();
    }

    return result;
  }

  // Observes completion on a side chain; the rendered button still receives
  // the original Future and owns its error handling.
  Future<void> _finishAfter(Future<void> work) async {
    try {
      await work;
    } on Object {
      // The rendered button handles or propagates this error.
    } finally {
      _finish();
    }
  }

  void _finish() {
    if (!mounted) {
      _pendingOperations--;

      return;
    }
    setState(() => _pendingOperations--);
  }

  @override
  Widget build(BuildContext context) {
    final TargetPlatform platform =
        widget.platform ?? Theme.of(context).platform;
    final bool cupertino =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final bool loading = widget.loading || _pendingOperations > 0;

    return cupertino
        ? _AdaptiveCupertinoButton(
            button: widget,
            onPressed: _onPressed,
            onError: _onError,
            loading: loading,
            focusNode: _focusNode,
          )
        : _AdaptiveMaterialButton(
            button: widget,
            onPressed: _onPressed,
            onError: _onError,
            loading: loading,
            focusNode: _focusNode,
          );
  }
}

/// Renders the native Cupertino variant for an [AsyncAdaptiveButton].
class _AdaptiveCupertinoButton extends StatelessWidget {
  const _AdaptiveCupertinoButton({
    required this.button,
    required this.onPressed,
    required this.onError,
    required this.loading,
    required this.focusNode,
  });

  final AsyncAdaptiveButton button;
  final FutureOr<void> Function()? onPressed;
  final AsyncButtonErrorHandler? onError;
  final bool loading;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    // A constructor tear-off type would spell out every Cupertino parameter.
    // ignore: specify_nonobvious_local_variable_types
    final (buttonBuilder, defaultDisabledColor) = switch (button._variant) {
      _AsyncAdaptiveButtonVariant.plain => (
        AsyncCupertinoButton.new,
        asyncCupertinoPlainDisabledColor,
      ),
      _AsyncAdaptiveButtonVariant.filled => (
        AsyncCupertinoButton.filled,
        asyncCupertinoFilledDisabledColor,
      ),
      _AsyncAdaptiveButtonVariant.tinted => (
        AsyncCupertinoButton.tinted,
        asyncCupertinoFilledDisabledColor,
      ),
    };

    return buttonBuilder(
      onPressed: onPressed,
      onError: onError,
      controller: button.controller,
      excludeFromGroup: button.excludeFromGroup,
      loading: loading,
      loadingChild: button.loadingChild,
      loadingSemanticsLabel: button.loadingSemanticsLabel,
      sizeStyle: button.cupertinoSizeStyle,
      padding: button.padding,
      color: button.backgroundColor,
      foregroundColor: button.foregroundColor,
      disabledColor: button.disabledBackgroundColor ?? defaultDisabledColor,
      minimumSize: button.minimumSize,
      alignment: button.alignment ?? Alignment.center,
      focusNode: focusNode,
      onFocusChange: button.onFocusChange,
      autofocus: button.autofocus,
      mouseCursor: button.mouseCursor,
      onLongPress: button.onLongPress,
      animationDuration:
          button.animationDuration ?? asyncCupertinoAnimationDuration,
      minimumChildOpacity: button.minimumChildOpacity,
      transitionType: button.transitionType,
      customBuilder: button.customBuilder,
      child: button.child,
    );
  }
}

/// Renders the native Material variant for an [AsyncAdaptiveButton].
class _AdaptiveMaterialButton extends StatelessWidget {
  const _AdaptiveMaterialButton({
    required this.button,
    required this.onPressed,
    required this.onError,
    required this.loading,
    required this.focusNode,
  });

  final AsyncAdaptiveButton button;
  final FutureOr<void> Function()? onPressed;
  final AsyncButtonErrorHandler? onError;
  final bool loading;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    // The shared parameters of AsyncTextButton, AsyncFilledButton, and
    // AsyncFilledButton.tonal, so one call forwards them to any of the three.
    final Widget Function({
      required Widget child,
      required FutureOr<void> Function()? onPressed,
      AsyncButtonErrorHandler? onError,
      AsyncButtonController? controller,
      bool excludeFromGroup,
      bool loading,
      Widget? loadingChild,
      String? loadingSemanticsLabel,
      ButtonStyle? style,
      EdgeInsetsGeometry? padding,
      Size? minimumSize,
      AlignmentGeometry? alignment,
      Color? backgroundColor,
      Color? foregroundColor,
      Color? disabledBackgroundColor,
      MouseCursor? mouseCursor,
      FocusNode? focusNode,
      ValueChanged<bool>? onFocusChange,
      bool autofocus,
      VoidCallback? onLongPress,
      Duration animationDuration,
      double minimumChildOpacity,
      TransitionAnimationType transitionType,
      Widget Function(bool loading, Widget child, Widget? loadingChild)?
      customBuilder,
    })
    buttonBuilder = switch (button._variant) {
      _AsyncAdaptiveButtonVariant.plain => AsyncTextButton.new,
      _AsyncAdaptiveButtonVariant.filled => AsyncFilledButton.new,
      _AsyncAdaptiveButtonVariant.tinted => AsyncFilledButton.tonal,
    };

    return buttonBuilder(
      onPressed: onPressed,
      onError: onError,
      controller: button.controller,
      excludeFromGroup: button.excludeFromGroup,
      loading: loading,
      loadingChild: button.loadingChild,
      loadingSemanticsLabel: button.loadingSemanticsLabel,
      style: button.materialStyle,
      padding: button.padding,
      minimumSize: button.minimumSize,
      alignment: button.alignment,
      backgroundColor: button.backgroundColor,
      foregroundColor: button.foregroundColor,
      disabledBackgroundColor: button.disabledBackgroundColor,
      mouseCursor: button.mouseCursor,
      focusNode: focusNode,
      onFocusChange: button.onFocusChange,
      autofocus: button.autofocus,
      onLongPress: button.onLongPress,
      animationDuration: button.animationDuration ?? Durations.medium1,
      minimumChildOpacity: button.minimumChildOpacity,
      transitionType: button.transitionType,
      customBuilder: button.customBuilder,
      child: button.child,
    );
  }
}
