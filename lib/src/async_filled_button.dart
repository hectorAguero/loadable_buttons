// To support lower versions than 3.22.0 for MaterialState.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart'
    show AsyncOutlinedButton;
import 'package:loadable_buttons/src/async_outlined_button.dart'
    show AsyncOutlinedButton;

import 'package:loadable_buttons/src/transition_animation_type.dart';

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
        key: key,
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
        child: label,
      );
    }

    return _AsyncFilledButtonWithIcon(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      loading: loading,
      loadingChild: loadingChild,
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
        key: key,
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
        child: label,
      );
    }

    return _AsyncFilledButtonWithIcon.tonal(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      icon: icon,
      label: label,
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

class _AsyncFilledButtonState extends State<AsyncFilledButton> {
  late bool _isLoading = widget.loading;

  Future<void> _handlePressed() async {
    // If the async callback is provided, use it.
    if (widget.onPressed != null) {
      // Prevent multiple presses.
      if (_isLoading) return;
      setState(() => _isLoading = true);

      try {
        await widget.onPressed?.call();
      } finally {
        // Ensure that state is updated even if an exception occurs.
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void didUpdateWidget(covariant AsyncFilledButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the loading state changes, update the state.
    if (oldWidget.loading != widget.loading) {
      _isLoading = widget.loading;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget._variant == _AsyncFilledButtonVariant.tonal) {
      return FilledButton.tonal(
        key: widget.key,
        onPressed: _isLoading ? null : _handlePressed,
        onLongPress: widget.onLongPress,
        onHover: widget.onHover,
        onFocusChange: widget.onFocusChange,
        style: widget.style ??
            FilledButton.styleFrom(splashFactory: widget.splashFactory),
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        clipBehavior: widget.clipBehavior,
        statesController: widget.statesController,
        child: _ChildContent(
          customBuilder: widget.customBuilder?.call(
            _isLoading,
            widget.child,
            widget.loadingChild,
          ),
          loadingChild: widget.loadingChild,
          isLoading: _isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          style: widget.style,
          child: widget.child,
        ),
      );
    }

    return FilledButton(
      key: widget.key,
      onPressed: _isLoading ? null : _handlePressed,
      onLongPress: widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style ??
          FilledButton.styleFrom(splashFactory: widget.splashFactory),
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
      child: _ChildContent(
        customBuilder: widget.customBuilder?.call(
          _isLoading,
          widget.child,
          widget.loadingChild,
        ),
        loadingChild: widget.loadingChild,
        isLoading: _isLoading,
        transitionType: widget.transitionType,
        animationDuration: widget.animationDuration,
        minimumChildOpacity: widget.minimumChildOpacity,
        style: widget.style,
        child: widget.child,
      ),
    );
  }
}

class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator({required ButtonStyle? style})
      : _style = style;

  static const double _defaultStrokeWidth = 3.0;

  final ButtonStyle? _style;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: _style?.foregroundColor?.resolve({MaterialState.selected}),
      strokeWidth: _defaultStrokeWidth,
      strokeCap: StrokeCap.round,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
    return switch (transitionType) {
      TransitionAnimationType.stack => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: isLoading ? minimumChildOpacity : 1.0,
              duration: animationDuration,
              child: AnimatedSize(duration: animationDuration, child: child),
            ),
            AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: animationDuration,
              child: Visibility(
                visible: isLoading,
                child: _DefaultLoadingIndicator(style: style),
              ),
            ),
          ],
        ),
      TransitionAnimationType.animatedSwitcher => AnimatedSwitcher(
          duration: animationDuration,
          transitionBuilder: (child, animation) => FadeTransition(
            key: ValueKey<Key?>(child.key),
            opacity: animation,
            child: AnimatedSize(
              duration: animationDuration,
              child: child,
            ),
          ),
          child: !isLoading
              ? IgnorePointer(ignoring: isLoading, child: child)
              : loadingChild ?? _DefaultLoadingIndicator(style: style),
        ),
      TransitionAnimationType.customBuilder =>
        customBuilder != null ? customBuilder ?? child : child,
    };
  }
}
