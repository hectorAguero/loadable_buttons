import 'dart:ui';

import 'package:flutter/material.dart';

part 'async_elevated_button_with_icon.dart';

/// Simple Typedef to mimic the VoidCallback wich is used in Flutter
typedef AsyncVoidCallback = Future<void> Function();

/// Builder to allow a custom transition between the child and the loadingChild
typedef CustomTransitionBuilder =
    Widget Function({
      required bool loading,
      required Widget child,
      Widget? loadingChild,
    });

/// Enum to define the type of loading animation
enum TransitionAnimationType {
  /// Stack loading animation, it allow to mantain the size of the button
  /// based on the biggest child
  stack,

  /// AnimatedSwitcher loading animation, it uses AnimatedSwitcher to
  /// animate the loading animation, which replace the child and loadingChild
  animatedSwitcher,

  /// Custom builder loading animation, it uses a custom builder to
  /// animate the loading animation, which replace the child and loadingChild
  customBuilder,
}

/// AsyncElevatedButton is a custom widget that allows to load a child
class AsyncElevatedButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// At least one callback must be non-null.
  const AsyncElevatedButton({
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
    super.key,
  }) : assert(
         transitionType != TransitionAnimationType.customBuilder ||
             customBuilder != null,
         'customBuilder must be provided when transitionType is customBuilder',
       );

  /// AsyncElevatedButton.icon is a custom widget that allows to load a child
  /// and an icon
  factory AsyncElevatedButton.icon({
    required AsyncVoidCallback? onPressed,
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
    CustomTransitionBuilder? customBuilder,
  }) {
    if (icon == null) {
      return AsyncElevatedButton(
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
        key: key,
        animationDuration: animationDuration,
        minimumChildOpacity: minimumChildOpacity,
        transitionType: transitionType,
        customBuilder: customBuilder,
        child: label,
      );
    }

    return _AsyncElevatedButtonWithIcon(
      key: key,
      label: label,
      icon: icon,
      style: style,
      onPressed: onPressed,
      loading: loading,
      autofocus: autofocus,
      clipBehavior: clipBehavior ?? Clip.none,
      statesController: statesController,
      iconAlignment: iconAlignment,
      loadingChild: loadingChild,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      transitionType: transitionType,
      customBuilder: customBuilder,
    );
  }

  /// The child of the button, same a the [ElevatedButton.child]
  final Widget child;

  /// The child that be show when the button is loading
  final Widget? loadingChild;

  /// The onPressed callback of the button, but being async
  final Future<void> Function()? onPressed;

  /// The loading state of the button, by default is false
  final bool loading;

  /// The onLongPress callback of the button
  final void Function()? onLongPress;

  /// The onHover callback of the button, ElevatedButton property
  final ValueChanged<bool>? onHover;

  /// The onFocusChange callback of the button, ElevatedButton property
  final ValueChanged<bool>? onFocusChange;

  /// The style of the button, ElevatedButton property
  final ButtonStyle? style;

  /// The focusNode of the button, ElevatedButton property
  final FocusNode? focusNode;

  /// The autofocus of the button, ElevatedButton property
  final bool autofocus;

  /// The clipBehavior of the button, ElevatedButton property
  final Clip? clipBehavior;

  /// The statesController of the button, ElevatedButton property
  final WidgetStatesController? statesController;

  /// The animationDuration of the transition
  final Duration animationDuration;

  /// The minimunOpacity of the child, when the button is loading
  /// by default is 0.0, so the child is not visible when the button is loading
  final double minimumChildOpacity;

  /// The type of the loading animation, by default is LoadingSwitchType.stack
  final TransitionAnimationType transitionType;

  /// The custom builder of the loading animation,
  /// when TransitionAnimationType.customBuilder is selected
  final CustomTransitionBuilder? customBuilder;

  @override
  State<AsyncElevatedButton> createState() => _AsyncElevatedButtonState();
}

class _AsyncElevatedButtonState extends State<AsyncElevatedButton> {
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
  Widget build(BuildContext context) => ElevatedButton(
    onLongPress: widget.onLongPress,
    onHover: widget.onHover,
    onFocusChange: widget.onFocusChange,
    style: widget.style,
    focusNode: widget.focusNode,
    autofocus: widget.autofocus,
    clipBehavior: widget.clipBehavior,
    statesController: widget.statesController,
    onPressed: _isLoading ? null : _handlePressed,
    child: switch (widget.transitionType) {
      TransitionAnimationType.stack => Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? widget.minimumChildOpacity : 1.0,
            duration: widget.animationDuration,
            child: widget.child,
          ),
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: widget.animationDuration,
            child: Visibility(
              visible: _isLoading,
              child: _DefaultLoadingIndicator(style: widget.style),
            ),
          ),
        ],
      ),
      TransitionAnimationType.animatedSwitcher => AnimatedSwitcher(
        duration: widget.animationDuration,
        child:
            !_isLoading
                ? IgnorePointer(ignoring: _isLoading, child: widget.child)
                : widget.loadingChild ??
                    _DefaultLoadingIndicator(style: widget.style),
      ),
      TransitionAnimationType.customBuilder =>
        widget.customBuilder != null
            ? widget.customBuilder?.call(
              loading: _isLoading,
              child: widget.child,
              loadingChild: widget.loadingChild,
            )
            : widget.child,
    },
  );

  @override
  void didUpdateWidget(covariant AsyncElevatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the loading state changes, update the state.
    if (oldWidget.loading != widget.loading) {
      _isLoading = widget.loading;
    }
  }
}

class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator({required ButtonStyle? style})
    : _style = style;

  final ButtonStyle? _style;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 3,
      strokeCap: StrokeCap.round,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      color: _style?.foregroundColor?.resolve({WidgetState.selected}),
    );
  }
}
