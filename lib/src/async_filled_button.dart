import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/async_outlined_button.dart'
    show AsyncOutlinedButton;
import 'package:loadable_buttons/src/loading_transition.dart';

part 'async_filled_button_with_icon.dart';

enum _AsyncFilledButtonVariant { filled, tonal }

/// A Material [FilledButton] with external and async loading states.
///
/// Effective loading is [loading] or a pending [onPressed] callback. Loading
/// disables outer button activation; built-in transitions exclude inactive
/// content from pointer input, focus, and semantics. Internal loading clears
/// when the callback completes or throws, but errors are not swallowed.
/// Handle errors in the callback and return or await all work to be tracked.
/// Disposing the widget does not cancel that work.
///
/// Larger [loadingChild] content can affect layout within Material and parent
/// constraints. Custom content owns its accessible labels; [customBuilder] also
/// owns sizing and inactive content's interaction, focus, and semantics.
class AsyncFilledButton extends StatefulWidget {
  /// Creates a button with a synchronous or asynchronous callback.
  ///
  /// With both [onPressed] and [onLongPress] null, the button is disabled.
  const AsyncFilledButton({
    required this.child,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.splashFactory,
    super.key,
  }) : _variant = _AsyncFilledButtonVariant.filled,
       assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       ),
       assert(
         splashFactory == null || style == null,
         'splashFactory and style cannot be used together, use style',
       );

  /// Create a filled button from [icon] and [label].
  ///
  /// The icon and label are arranged in a row with padding at the start and end
  /// and a gap between them.
  ///
  /// If [icon] is null, will create a [AsyncFilledButton] instead.
  ///
  /// {@macro flutter.material.ButtonStyleButton.iconAlignment}
  ///
  factory AsyncFilledButton.icon({
    required FutureOr<void> Function()? onPressed,
    required Widget label,
    Key? key,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
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
  }) {
    if (icon == null) {
      return AsyncFilledButton(
        child: label,
        onPressed: onPressed,
        loadingChild: loadingChild,
        loading: loading,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        statesController: statesController,
        style: style,
        focusNode: focusNode,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        animationDuration: animationDuration,
        minimumChildOpacity: minimumChildOpacity,
        transitionType: transitionType,
        customBuilder: customBuilder,
        splashFactory: splashFactory,
        key: key,
      );
    }

    return _AsyncFilledButtonWithIcon(
      label: label,
      icon: icon,
      onPressed: onPressed,
      loading: loading,
      loadingChild: loadingChild,
      key: key,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      focusNode: focusNode,
      style: style,
      iconAlignment: iconAlignment,
      autofocus: autofocus,
      clipBehavior: clipBehavior ?? Clip.none,
      statesController: statesController,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      transitionType: transitionType,
      customBuilder: customBuilder,
      splashFactory: splashFactory,
    );
  }

  /// Create a tonal variant of FilledButton.
  ///
  /// A filled tonal button is an alternative middle ground between
  /// [AsyncFilledButton] and [AsyncOutlinedButton]. They’re useful in contexts
  /// where a lower-priority button requires slightly more emphasis than an
  /// outline would give, such as "Next" in an onboarding flow.
  const AsyncFilledButton.tonal({
    required this.child,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.splashFactory,
    super.key,
  }) : _variant = _AsyncFilledButtonVariant.tonal,
       assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       );

  /// Create a filled tonal button from [icon] and [label].
  ///
  /// The [icon] and [label] are arranged in a row with padding at the start and
  /// end and a gap between them.
  ///
  /// If [icon] is null, will create a [FilledButton.tonal] instead.
  factory AsyncFilledButton.tonalIcon({
    required FutureOr<void> Function()? onPressed,
    required Widget label,
    Key? key,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
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
  }) {
    if (icon == null) {
      return AsyncFilledButton.tonal(
        child: label,
        onPressed: onPressed,
        loadingChild: loadingChild,
        loading: loading,
        autofocus: autofocus,
        clipBehavior: clipBehavior ?? Clip.none,
        statesController: statesController,
        style: style,
        focusNode: focusNode,
        onLongPress: onLongPress,
        onHover: onHover,
        onFocusChange: onFocusChange,
        animationDuration: animationDuration,
        minimumChildOpacity: minimumChildOpacity,
        transitionType: transitionType,
        customBuilder: customBuilder,
        splashFactory: splashFactory,
        key: key,
      );
    }

    return _AsyncFilledButtonWithIcon.tonal(
      onPressed: onPressed,
      icon: icon,
      label: label,
      key: key,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      iconAlignment: iconAlignment,
      loading: loading,
      loadingChild: loadingChild,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      transitionType: transitionType,
      customBuilder: customBuilder,
      splashFactory: splashFactory,
    );
  }

  /// The child of the button, same a the [FilledButton.child].
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
  /// Internal loading clears on completion or error; exceptions propagate.
  /// Handle errors here according to the application's policy.
  ///
  /// Null disables the button unless [onLongPress] is supplied.
  final FutureOr<void> Function()? onPressed;

  /// Whether the application requests external loading.
  ///
  /// Defaults to false. Effective loading combines this flag with a pending
  /// [onPressed] callback. Setting it to false neither cancels nor unlocks that
  /// callback; callback completion does not clear this flag.
  final bool loading;

  /// The synchronous long-press callback, blocked while loading.
  ///
  /// Does not start internal loading. When idle, a non-null callback keeps the
  /// button enabled even if [onPressed] is null.
  final void Function()? onLongPress;

  /// The onHover callback of the button, FilledButton property.
  final ValueChanged<bool>? onHover;

  /// The onFocusChange callback of the button, FilledButton property.
  final ValueChanged<bool>? onFocusChange;

  /// The style of the button, FilledButton property.
  final ButtonStyle? style;

  /// The focusNode of the button, FilledButton property.
  final FocusNode? focusNode;

  /// The autofocus of the button, FilledButton property.
  final bool autofocus;

  /// The clipBehavior of the button, FilledButton property.
  final Clip? clipBehavior;

  /// The statesController of the button, FilledButton property.
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

  final _AsyncFilledButtonVariant _variant;

  @override
  State<AsyncFilledButton> createState() => _AsyncFilledButtonState();
}

class _AsyncFilledButtonState extends State<AsyncFilledButton>
    with AsyncButtonState<AsyncFilledButton> {
  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  void _handleLongPress() {
    if (isLoading) return;
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._variant == _AsyncFilledButtonVariant.tonal) {
      return FilledButton.tonal(
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
        onLongPress:
            isLoading || widget.onLongPress == null ? null : _handleLongPress,
        onHover: widget.onHover,
        onFocusChange: widget.onFocusChange,
        style:
            widget.style ??
            FilledButton.styleFrom(splashFactory: widget.splashFactory),
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _ChildContent(
          customBuilder: widget.customBuilder?.call(
            isLoading,
            widget.child,
            widget.loadingChild,
          ),
          child: widget.child,
          loadingChild: widget.loadingChild,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          style: widget.style,
        ),
      );
    }

    return FilledButton(
      onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
      onLongPress:
          isLoading || widget.onLongPress == null ? null : _handleLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style:
          widget.style ??
          FilledButton.styleFrom(splashFactory: widget.splashFactory),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: _ChildContent(
        customBuilder: widget.customBuilder?.call(
          isLoading,
          widget.child,
          widget.loadingChild,
        ),
        child: widget.child,
        loadingChild: widget.loadingChild,
        isLoading: isLoading,
        transitionType: widget.transitionType,
        animationDuration: widget.animationDuration,
        minimumChildOpacity: widget.minimumChildOpacity,
        style: widget.style,
      ),
    );
  }
}

class _ChildContent extends StatelessWidget {
  final Widget? customBuilder;
  final Widget child;
  final Widget? loadingChild;
  final bool isLoading;
  final TransitionAnimationType transitionType;
  final Duration animationDuration;
  final double minimumChildOpacity;
  final ButtonStyle? style;

  const _ChildContent({
    required this.customBuilder,
    required this.child,
    required this.loadingChild,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (transitionType == TransitionAnimationType.customBuilder) {
      return customBuilder ?? child;
    }

    return LoadingTransition(
      child: child,
      loadingChild:
          loadingChild ??
          DefaultLoadingIndicator(
            style: style,
            themeStyleOf: (context) => FilledButtonTheme.of(context).style,
          ),
      isLoading: isLoading,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
    );
  }
}
