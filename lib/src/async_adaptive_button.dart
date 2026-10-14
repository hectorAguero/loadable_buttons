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
/// loading and locked when the platform or theme changes mid-operation: the
/// operation stays on [controller], or on a controller this widget owns when
/// none is supplied, and the newly rendered button adopts it. The work is
/// neither repeated nor cancelled.
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
  /// Without one, this widget owns a controller so a pending operation survives
  /// a platform change. The caller owns and disposes a supplied controller.
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
  // Holds a pending operation while the rendered button type changes.
  AsyncButtonController? _ownedController;

  AsyncButtonController get _controller =>
      widget.controller ?? (_ownedController ??= AsyncButtonController());

  @override
  void dispose() {
    // A pending operation may still finish; the controller ignores it.
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform ?? Theme.of(context).platform;

    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? _AdaptiveCupertinoButton(button: widget, controller: _controller)
        : _AdaptiveMaterialButton(button: widget, controller: _controller);
  }
}

/// Renders the native Cupertino variant for an [AsyncAdaptiveButton].
class _AdaptiveCupertinoButton extends StatelessWidget {
  const _AdaptiveCupertinoButton({
    required this.button,
    required this.controller,
  });

  static const _animationDuration = Duration(milliseconds: 200);

  final AsyncAdaptiveButton button;
  final AsyncButtonController controller;

  @override
  Widget build(BuildContext context) {
    final buttonBuilder = switch (button._variant) {
      _AsyncAdaptiveButtonVariant.plain => AsyncCupertinoButton.new,
      _AsyncAdaptiveButtonVariant.filled => AsyncCupertinoButton.filled,
      _AsyncAdaptiveButtonVariant.tinted => AsyncCupertinoButton.tinted,
    };

    return buttonBuilder(
      onPressed: button.onPressed,
      onError: button.onError,
      controller: controller,
      excludeFromGroup: button.excludeFromGroup,
      loading: button.loading,
      loadingChild: button.loadingChild,
      loadingSemanticsLabel: button.loadingSemanticsLabel,
      sizeStyle: button.cupertinoSizeStyle,
      padding: button.padding,
      color: button.backgroundColor,
      foregroundColor: button.foregroundColor,
      minimumSize: button.minimumSize,
      alignment: button.alignment ?? Alignment.center,
      focusNode: button.focusNode,
      onFocusChange: button.onFocusChange,
      autofocus: button.autofocus,
      mouseCursor: button.mouseCursor,
      onLongPress: button.onLongPress,
      animationDuration: button.animationDuration ?? _animationDuration,
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
    required this.controller,
  });

  final AsyncAdaptiveButton button;
  final AsyncButtonController controller;

  @override
  Widget build(BuildContext context) {
    final animationDuration = button.animationDuration ?? Durations.medium1;
    if (button._variant == _AsyncAdaptiveButtonVariant.plain) {
      return AsyncTextButton(
        onPressed: button.onPressed,
        onError: button.onError,
        controller: controller,
        excludeFromGroup: button.excludeFromGroup,
        loading: button.loading,
        loadingChild: button.loadingChild,
        loadingSemanticsLabel: button.loadingSemanticsLabel,
        style: button.materialStyle,
        padding: button.padding,
        minimumSize: button.minimumSize,
        alignment: button.alignment,
        backgroundColor: button.backgroundColor,
        foregroundColor: button.foregroundColor,
        mouseCursor: button.mouseCursor,
        focusNode: button.focusNode,
        onFocusChange: button.onFocusChange,
        autofocus: button.autofocus,
        onLongPress: button.onLongPress,
        animationDuration: animationDuration,
        minimumChildOpacity: button.minimumChildOpacity,
        transitionType: button.transitionType,
        customBuilder: button.customBuilder,
        child: button.child,
      );
    }

    // Filled regular and tonal share one constructor signature.
    final buttonBuilder = button._variant == _AsyncAdaptiveButtonVariant.filled
        ? AsyncFilledButton.new
        : AsyncFilledButton.tonal;

    return buttonBuilder(
      onPressed: button.onPressed,
      onError: button.onError,
      controller: controller,
      excludeFromGroup: button.excludeFromGroup,
      loading: button.loading,
      loadingChild: button.loadingChild,
      loadingSemanticsLabel: button.loadingSemanticsLabel,
      style: button.materialStyle,
      padding: button.padding,
      minimumSize: button.minimumSize,
      alignment: button.alignment,
      backgroundColor: button.backgroundColor,
      foregroundColor: button.foregroundColor,
      mouseCursor: button.mouseCursor,
      focusNode: button.focusNode,
      onFocusChange: button.onFocusChange,
      autofocus: button.autofocus,
      onLongPress: button.onLongPress,
      animationDuration: animationDuration,
      minimumChildOpacity: button.minimumChildOpacity,
      transitionType: button.transitionType,
      customBuilder: button.customBuilder,
      child: button.child,
    );
  }
}
