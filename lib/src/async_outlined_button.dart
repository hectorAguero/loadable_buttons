import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/loading_transition.dart';

part 'async_outlined_button_with_icon.dart';

/// AsyncOutlinedButton is a custom widget that allows to load a child.
class AsyncOutlinedButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// At least one callback must be non-null.
  const AsyncOutlinedButton({
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
  }) : assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       ),
       assert(
         splashFactory == null || style == null,
         'splashFactory and style cannot be used together, use style',
       );

  /// AsyncOutlinedButton.icon is a custom widget that allows to load a child
  /// and an icon.
  factory AsyncOutlinedButton.icon({
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
      return AsyncOutlinedButton(
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

    return _AsyncOutlinedButtonWithIcon(
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

  /// The child of the button, same a the [OutlinedButton.child].
  final Widget child;

  /// The child that be show when the button is loading.
  final Widget? loadingChild;

  /// The onPressed callback of the button, but being async.
  final FutureOr<void> Function()? onPressed;

  /// The loading state of the button, by default is false.
  final bool loading;

  /// The onLongPress callback of the button.
  final void Function()? onLongPress;

  /// The onHover callback of the button, OutlinedButton property.
  final ValueChanged<bool>? onHover;

  /// The onFocusChange callback of the button, OutlinedButton property.
  final ValueChanged<bool>? onFocusChange;

  /// The style of the button, OutlinedButton property.
  final ButtonStyle? style;

  /// The focusNode of the button, OutlinedButton property.
  final FocusNode? focusNode;

  /// The autofocus of the button, OutlinedButton property.
  final bool autofocus;

  /// The clipBehavior of the button, OutlinedButton property.
  final Clip? clipBehavior;

  /// The statesController of the button, OutlinedButton property.
  final WidgetStatesController? statesController;

  /// The animationDuration of the transition.
  final Duration animationDuration;

  /// The minimunOpacity of the child, when the button is loading
  /// by default is 0.0, so the child is not visible when the button is loading.
  final double minimumChildOpacity;

  /// The type of the loading animation, by default is LoadingSwitchType.stack.
  final TransitionAnimationType transitionType;

  /// The custom builder of the loading animation,
  /// when TransitionAnimationType.customBuilder is selected.
  final Widget Function(bool loading, Widget child, Widget? loadingChild)?
  customBuilder;

  /// Optional SplashFactory to customize the splash effect.
  /// Use NoSplash.splashFactory to disable flutter default splash effect.
  /// It won't be used if the style property is set.
  final InteractiveInkFeatureFactory? splashFactory;

  @override
  State<AsyncOutlinedButton> createState() => _AsyncOutlinedButtonState();
}

class _AsyncOutlinedButtonState extends State<AsyncOutlinedButton>
    with AsyncButtonState<AsyncOutlinedButton> {
  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  void _handleLongPress() {
    if (isLoading) return;
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
    onLongPress:
        isLoading || widget.onLongPress == null ? null : _handleLongPress,
    onHover: widget.onHover,
    onFocusChange: widget.onFocusChange,
    style:
        widget.style ??
        OutlinedButton.styleFrom(splashFactory: widget.splashFactory),
    focusNode: widget.focusNode,
    autofocus: widget.autofocus,
    clipBehavior: widget.clipBehavior,
    statesController: widget.statesController,
    child:
        widget.transitionType == TransitionAnimationType.customBuilder
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
                    style: widget.style,
                    themeStyleOf:
                        (context) => OutlinedButtonTheme.of(context).style,
                  ),
              isLoading: isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
            ),
  );
}
