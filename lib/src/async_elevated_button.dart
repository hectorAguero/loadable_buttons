import 'dart:async';
import 'dart:ui';

import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/async_material_button_helpers.dart';
import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

part 'async_elevated_button_with_icon.dart';

/// A Material [ElevatedButton] with external and async loading states.
///
/// Effective loading is [loading] or a pending [onPressed] or [onError].
/// Loading disables outer button activation; built-in transitions exclude
/// inactive content from pointer input, focus, and semantics. Internal loading
/// clears when both callbacks finish. [onError] explicitly consumes errors when
/// it succeeds. Unhandled errors propagate with their original stack trace.
/// Return or await all work to be tracked.
/// Disposing the widget does not cancel that work.
///
/// Larger [loadingChild] content can affect layout within Material and parent
/// constraints. Custom content owns its accessible labels; [customBuilder] also
/// owns sizing and inactive content's interaction, focus, and semantics.
class AsyncElevatedButton extends StatefulWidget {
  /// Creates a button with a synchronous or asynchronous callback.
  ///
  /// With both [onPressed] and [onLongPress] null, the button is disabled.
  const AsyncElevatedButton({
    required this.child,
    required this.onPressed,
    this.onError,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.style,
    this.padding,
    this.minimumSize,
    this.alignment,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.mouseCursor,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.splashFactory,
    this.loadingSemanticsLabel,
    super.key,
  }) : assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       ),
       assert(
         splashFactory == null || style == null,
         'splashFactory and style cannot be used together, use style',
       );

  /// AsyncElevatedButton.icon is a custom widget that allows to load a child
  /// and an icon.
  factory AsyncElevatedButton.icon({
    required FutureOr<void> Function()? onPressed,
    required Widget label,
    AsyncButtonErrorHandler? onError,
    Key? key,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    AlignmentGeometry? alignment,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? disabledBackgroundColor,
    Color? disabledForegroundColor,
    MouseCursor? mouseCursor,
    FocusNode? focusNode,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    Widget? icon,
    IconAlignment? iconAlignment,
    Widget? loadingChild,
    bool loading = false,
    bool autofocus = false,
    Duration animationDuration = Durations.medium1,
    double minimumChildOpacity = 0.0,
    TransitionAnimationType transitionType = TransitionAnimationType.stack,
    Widget Function(bool loading, Widget child, Widget? loadingChild)?
    customBuilder,
    InteractiveInkFeatureFactory? splashFactory,
    String? loadingSemanticsLabel,
  }) {
    if (icon == null) {
      return AsyncElevatedButton(
        child: label,
        onPressed: onPressed,
        onError: onError,
        loadingChild: loadingChild,
        loading: loading,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        style: style,
        padding: padding,
        minimumSize: minimumSize,
        alignment: alignment,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        disabledForegroundColor: disabledForegroundColor,
        mouseCursor: mouseCursor,
        focusNode: focusNode,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        animationDuration: animationDuration,
        minimumChildOpacity: minimumChildOpacity,
        transitionType: transitionType,
        customBuilder: customBuilder,
        splashFactory: splashFactory,
        loadingSemanticsLabel: loadingSemanticsLabel,
        key: key,
      );
    }

    return _AsyncElevatedButtonWithIcon(
      label: label,
      icon: icon,
      onPressed: onPressed,
      onError: onError,
      loading: loading,
      loadingChild: loadingChild,
      key: key,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      style: style,
      padding: padding,
      minimumSize: minimumSize,
      alignment: alignment,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      mouseCursor: mouseCursor,
      iconAlignment: iconAlignment,
      autofocus: autofocus,
      clipBehavior: clipBehavior ?? Clip.none,
      statesController: statesController,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      transitionType: transitionType,
      customBuilder: customBuilder,
      splashFactory: splashFactory,
      loadingSemanticsLabel: loadingSemanticsLabel,
    );
  }

  /// The child of the button, same a the [ElevatedButton.child].
  final Widget child;

  /// The content shown while either loading source is active.
  ///
  /// Built-in transitions use a default spinner when null. Supply appropriate
  /// semantics for custom content; larger content can change the button's size.
  /// A custom builder receives this value unchanged, including null.
  final Widget? loadingChild;

  /// The synchronous or asynchronous activation callback.
  ///
  /// Return or await async work to keep the button loading until it completes.
  /// Internal loading clears after this callback and any [onError] finish.
  /// Errors propagate with their original stack trace unless [onError] consumes
  /// them. Unreturned or unawaited Futures cannot be tracked.
  ///
  /// Null disables the button unless [onLongPress] is supplied.
  final FutureOr<void> Function()? onPressed;

  /// The optional handler that explicitly consumes errors from [onPressed].
  ///
  /// Called once with the original error and stack trace. Loading stays active
  /// until the handler finishes. Handler failures propagate without invoking
  /// it again. Null preserves the original error propagation.
  ///
  /// Captured when activation starts and still called after disposal; check
  /// your own lifecycle before using captured state or context. See
  /// [AsyncButtonErrorHandler] for the shared policy across all constructors.
  final AsyncButtonErrorHandler? onError;

  /// Whether the application requests external loading.
  ///
  /// Defaults to false. Effective loading combines this flag with a pending
  /// [onPressed] or [onError]. Setting it to false neither cancels nor unlocks
  /// that work; completing either callback does not clear this flag.
  final bool loading;

  /// The synchronous long-press callback, blocked while loading.
  ///
  /// Does not start internal loading. When idle, a non-null callback keeps the
  /// button enabled even if [onPressed] is null.
  final void Function()? onLongPress;

  /// The onHover callback of the button, ElevatedButton property.
  final ValueChanged<bool>? onHover;

  /// The onFocusChange callback of the button, ElevatedButton property.
  final ValueChanged<bool>? onFocusChange;

  /// The style of the button, ElevatedButton property.
  final ButtonStyle? style;

  /// Overrides [ButtonStyle.padding] in every state when non-null.
  ///
  /// Shortcuts take precedence over [style], then [ElevatedButtonTheme] and
  /// native defaults. Null keeps the existing resolution, including icon
  /// padding.
  final EdgeInsetsGeometry? padding;

  /// Overrides [ButtonStyle.minimumSize] in every state when non-null.
  ///
  /// Visual density, constraints, and tap-target sizing still apply natively.
  final Size? minimumSize;

  /// Overrides [ButtonStyle.alignment] when non-null.
  final AlignmentGeometry? alignment;

  /// Overrides the enabled [ButtonStyle.backgroundColor] when non-null.
  ///
  /// Disabled and loading states keep resolving through [style], the theme,
  /// and native defaults unless [disabledBackgroundColor] is also supplied.
  final Color? backgroundColor;

  /// Overrides the enabled [ButtonStyle.foregroundColor] when non-null.
  ///
  /// Text, icons without an explicit icon color, and the default loading
  /// indicator use it. Disabled states keep their existing colors unless
  /// [disabledForegroundColor] is also supplied.
  final Color? foregroundColor;

  /// Overrides the disabled and loading [ButtonStyle.backgroundColor].
  ///
  /// Enabled states keep resolving through [style], the theme, and defaults.
  final Color? disabledBackgroundColor;

  /// Overrides the disabled and loading [ButtonStyle.foregroundColor].
  ///
  /// Enabled states keep resolving through [style], the theme, and defaults.
  final Color? disabledForegroundColor;

  /// Overrides [ButtonStyle.mouseCursor] when non-null.
  ///
  /// A plain cursor applies in every state, including disabled and loading.
  /// A [WidgetStateMouseCursor] resolves for each state.
  final MouseCursor? mouseCursor;

  /// The focusNode of the button, ElevatedButton property.
  final FocusNode? focusNode;

  /// The autofocus of the button, ElevatedButton property.
  final bool autofocus;

  /// The clipBehavior of the button, ElevatedButton property.
  final Clip? clipBehavior;

  /// The statesController of the button, ElevatedButton property.
  final WidgetStatesController? statesController;

  /// The animationDuration of the transition.
  final Duration animationDuration;

  /// The idle content's opacity during a stack loading transition.
  ///
  /// Defaults to 0.0. Partially visible idle content remains excluded from
  /// pointer input, focus, and semantics in built-in transitions.
  final double minimumChildOpacity;

  /// The loading transition, defaulting to [TransitionAnimationType.stack].
  final TransitionAnimationType transitionType;

  /// The presentation builder for [TransitionAnimationType.customBuilder].
  ///
  /// Required in custom-builder mode. Receives effective loading, idle content,
  /// and the supplied nullable [loadingChild], without a default spinner.
  /// Owns sizing and all content interaction, focus, and semantics, including
  /// inactive or outgoing subtrees. The outer button still locks activation.
  final Widget Function(bool loading, Widget child, Widget? loadingChild)?
  customBuilder;

  /// Optional SplashFactory to customize the splash effect.
  /// Use NoSplash.splashFactory to disable flutter default splash effect.
  /// It won't be used if the style property is set.
  final InteractiveInkFeatureFactory? splashFactory;

  /// The accessible label for the default loading spinner.
  ///
  /// Defaults to `null`; supply a localized description of the operation.
  /// Ignored with [loadingChild] or [TransitionAnimationType.customBuilder],
  /// whose content owns its semantics and any live announcements.
  final String? loadingSemanticsLabel;

  @override
  State<AsyncElevatedButton> createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton>
    with AsyncButtonState<AsyncElevatedButton> {
  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  @override
  AsyncButtonErrorHandler? get asyncOnError => widget.onError;

  void _handleLongPress() {
    if (isLoading) return;
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = applyButtonStyleShortcuts(
      widget.style ??
          ElevatedButton.styleFrom(splashFactory: widget.splashFactory),
      padding: widget.padding,
      minimumSize: widget.minimumSize,
      alignment: widget.alignment,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      disabledBackgroundColor: widget.disabledBackgroundColor,
      disabledForegroundColor: widget.disabledForegroundColor,
      mouseCursor: widget.mouseCursor,
    );

    return _LoadingElevatedButton(
      hasIcon: widget is _AsyncElevatedButtonWithIcon,
      onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
      onLongPress: isLoading || widget.onLongPress == null
          ? null
          : _handleLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: resolveButtonClipBehavior(
        clipBehavior: widget.clipBehavior,
        style: style,
        themeStyle: ElevatedButtonTheme.of(context).style,
      ),
      statesController: widget.statesController,
      child: widget.transitionType == TransitionAnimationType.customBuilder
          ? widget.customBuilder?.call(
                  isLoading,
                  widget.child,
                  widget.loadingChild,
                ) ??
                widget.child
          : LoadingTransition(
              child: widget.child,
              loadingChild:
                  widget.loadingChild ??
                  DefaultLoadingIndicator(
                    style: style,
                    themeStyleOf: (context) =>
                        ElevatedButtonTheme.of(context).style,
                    loadingSemanticsLabel: widget.loadingSemanticsLabel,
                  ),
              isLoading: isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
            ),
    );
  }
}

// Share full-button stack loading between regular and icon variants.
// Native icon padding is private to the `.icon` constructor; delegate to it so
// defaults track Material while widget and theme styles keep precedence.
class _LoadingElevatedButton extends ElevatedButton with StackLoadingButton {
  const _LoadingElevatedButton({
    required this._hasIcon,
    required super.onPressed,
    required super.child,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
  });

  final bool _hasIcon;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    if (!_hasIcon) return super.defaultStyleOf(context);

    return ElevatedButton.icon(
      onPressed: null,
      icon: const SizedBox.shrink(),
      label: const SizedBox.shrink(),
    ).defaultStyleOf(context);
  }
}
