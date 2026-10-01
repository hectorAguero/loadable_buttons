import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/async_outlined_button.dart'
    show AsyncOutlinedButton;
import 'package:loadable_buttons/src/loading_transition.dart';

part 'async_filled_button_with_icon.dart';

enum _AsyncFilledButtonVariant { filled, tonal }

/// AsyncFilledButton is a custom widget that allows to load a child.
class AsyncFilledButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// At least one callback must be non-null.
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
  })  : _variant = _AsyncFilledButtonVariant.filled,
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
    // Retain the v1 public Material typedef until the v2 API migration.
    // ignore: deprecated_member_use
    MaterialStatesController? statesController,
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
          key: key);
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
        splashFactory: splashFactory);
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
  })  : _variant = _AsyncFilledButtonVariant.tonal,
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
    // Retain the v1 public Material typedef until the v2 API migration.
    // ignore: deprecated_member_use
    MaterialStatesController? statesController,
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
          key: key);
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
        splashFactory: splashFactory);
  }

  /// The child of the button, same a the [FilledButton.child].
  final Widget child;

  /// The child that be show when the button is loading.
  final Widget? loadingChild;

  /// The onPressed callback of the button, but being async.
  final FutureOr<void> Function()? onPressed;

  /// The loading state of the button, by default is false.
  final bool loading;

  /// The onLongPress callback of the button.
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
  // Retain the v1 public Material typedef until the v2 API migration.
  // ignore: deprecated_member_use
  final MaterialStatesController? statesController;

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
        style: widget.style ??
            FilledButton.styleFrom(splashFactory: widget.splashFactory),
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _ChildContent(
            customBuilder: widget.customBuilder
                ?.call(isLoading, widget.child, widget.loadingChild),
            child: widget.child,
            loadingChild: widget.loadingChild,
            isLoading: isLoading,
            transitionType: widget.transitionType,
            animationDuration: widget.animationDuration,
            minimumChildOpacity: widget.minimumChildOpacity,
            style: widget.style),
      );
    }

    return FilledButton(
      onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
      onLongPress:
          isLoading || widget.onLongPress == null ? null : _handleLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style ??
          FilledButton.styleFrom(splashFactory: widget.splashFactory),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: _ChildContent(
          customBuilder: widget.customBuilder
              ?.call(isLoading, widget.child, widget.loadingChild),
          child: widget.child,
          loadingChild: widget.loadingChild,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          style: widget.style),
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
      loadingChild: loadingChild ??
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
