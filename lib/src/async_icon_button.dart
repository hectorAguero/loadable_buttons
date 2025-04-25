// To support lower versions than 3.22.0 for MaterialState.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

import 'transition_animation_type.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

/// AsyncIconButton is a custom widget that allows to load a child.
class AsyncIconButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// At least one callback must be non-null.
  const AsyncIconButton({
    required this.icon,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.isSelected,
    this.selectedIcon,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        _variant = _IconButtonVariant.standard;

  const AsyncIconButton.filled({
    required this.icon,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.isSelected,
    this.selectedIcon,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        _variant = _IconButtonVariant.filled;

  const AsyncIconButton.filledTonal({
    required this.icon,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.isSelected,
    this.selectedIcon,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(splashRadius == null || splashRadius > 0),
        _variant = _IconButtonVariant.filledTonal;

  const AsyncIconButton.outlined({
    required this.icon,
    required this.onPressed,
    this.loadingChild,
    this.loading = false,
    this.autofocus = false,
    this.style,
    this.focusNode,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.iconSize,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.mouseCursor,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.isSelected,
    this.selectedIcon,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(splashRadius == null || splashRadius > 0),
        _variant = _IconButtonVariant.outlined;

  /// The icon of the button, same as the [IconButton.icon].
  final Widget icon;

  /// The child that be show when the button is loading.
  final Widget? loadingChild;

  /// The onPressed callback of the button, but being async.
  final FutureOr<void> Function()? onPressed;

  /// The loading state of the button, by default is false.
  final bool loading;

  /// The onLongPress callback of the button.
  final void Function()? onLongPress;

  /// The onHover callback of the button.
  final ValueChanged<bool>? onHover;

  /// The onFocusChange callback of the button.
  final ValueChanged<bool>? onFocusChange;

  /// The style of the button.
  final ButtonStyle? style;

  /// The focusNode of the button.
  final FocusNode? focusNode;

  /// The autofocus of the button.
  final bool autofocus;

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

  /// The onPressed callback of the button, but being async.
  final double? iconSize;

  /// The visualDensity of the button.
  final VisualDensity? visualDensity;

  /// The padding of the button.
  final EdgeInsetsGeometry? padding;

  /// The alignment of the button.
  final AlignmentGeometry? alignment;

  /// The splashRadius of the button.
  final double? splashRadius;

  /// The color of the button.
  final Color? color;

  /// The focusColor of the button.
  final Color? focusColor;

  /// The hoverColor of the button.
  final Color? hoverColor;

  /// The primary color of the button when it is pressed.
  final Color? highlightColor;

  /// The splash color of the button.
  final Color? splashColor;

  /// The disabled color of the button.
  final Color? disabledColor;

  /// The mouse cursor of the button.
  final MouseCursor? mouseCursor;

  /// The tooltip of the button.
  final String? tooltip;

  /// The visual density of the button.
  final bool? enableFeedback;

  /// The constraints of the button.
  final BoxConstraints? constraints;

  /// The visual density of the button.
  final MaterialStateProperty<bool>? isSelected;

  /// The selected icon of the button.
  final Widget? selectedIcon;

  /// The visual density of the button.
  final _IconButtonVariant _variant;

  @override
  State<AsyncIconButton> createState() => _AsyncIconButtonState();
}

class _AsyncIconButtonState extends State<AsyncIconButton> {
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
  void didUpdateWidget(covariant AsyncIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the loading state changes, update the state.
    if (oldWidget.loading != widget.loading) {
      _isLoading = widget.loading;
    }
  }

  @override
  Widget build(BuildContext context) => switch (widget._variant) {
        _IconButtonVariant.standard => IconButton(
            key: widget.key,
            iconSize: widget.iconSize,
            visualDensity: widget.visualDensity,
            padding: widget.padding,
            alignment: widget.alignment,
            splashRadius: widget.splashRadius,
            color: widget.color,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            disabledColor: widget.disabledColor,
            onPressed: _isLoading ? null : () => _handlePressed(),
            onHover: widget.onHover,
            onLongPress: widget.onLongPress,
            mouseCursor: widget.mouseCursor,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            tooltip: widget.tooltip,
            enableFeedback: widget.enableFeedback,
            constraints: widget.constraints,
            style: widget.style,
            icon: _AsyncIconButtonChild(
              icon: widget.icon,
              loadingChild: widget.loadingChild,
              style: widget.style,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
            ),
          ),
        _IconButtonVariant.filled => IconButton.filled(
            key: widget.key,
            iconSize: widget.iconSize,
            visualDensity: widget.visualDensity,
            padding: widget.padding,
            alignment: widget.alignment,
            splashRadius: widget.splashRadius,
            color: widget.color,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            disabledColor: widget.disabledColor,
            onPressed: _isLoading ? null : () => _handlePressed(),
            onHover: widget.onHover,
            onLongPress: widget.onLongPress,
            mouseCursor: widget.mouseCursor,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            tooltip: widget.tooltip,
            enableFeedback: widget.enableFeedback,
            constraints: widget.constraints,
            style: widget.style,
            icon: _AsyncIconButtonChild(
              icon: widget.icon,
              loadingChild: widget.loadingChild,
              style: widget.style,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
            ),
          ),
        _IconButtonVariant.filledTonal => IconButton.filledTonal(
            key: widget.key,
            iconSize: widget.iconSize,
            visualDensity: widget.visualDensity,
            padding: widget.padding,
            alignment: widget.alignment,
            splashRadius: widget.splashRadius,
            color: widget.color,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            disabledColor: widget.disabledColor,
            onPressed: _isLoading ? null : () => _handlePressed(),
            onHover: widget.onHover,
            onLongPress: widget.onLongPress,
            mouseCursor: widget.mouseCursor,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            tooltip: widget.tooltip,
            enableFeedback: widget.enableFeedback,
            constraints: widget.constraints,
            style: widget.style,
            icon: _AsyncIconButtonChild(
              icon: widget.icon,
              loadingChild: widget.loadingChild,
              style: widget.style,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
            ),
          ),
        _IconButtonVariant.outlined => IconButton.outlined(
            key: widget.key,
            iconSize: widget.iconSize,
            visualDensity: widget.visualDensity,
            padding: widget.padding,
            alignment: widget.alignment,
            splashRadius: widget.splashRadius,
            color: widget.color,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            highlightColor: widget.highlightColor,
            splashColor: widget.splashColor,
            disabledColor: widget.disabledColor,
            onPressed: _isLoading ? null : () => _handlePressed(),
            onHover: widget.onHover,
            onLongPress: widget.onLongPress,
            mouseCursor: widget.mouseCursor,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            tooltip: widget.tooltip,
            enableFeedback: widget.enableFeedback,
            constraints: widget.constraints,
            style: widget.style,
            icon: _AsyncIconButtonChild(
              icon: widget.icon,
              loadingChild: widget.loadingChild,
              style: widget.style,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
            ),
          ),
      };
}

class _AsyncIconButtonChild extends StatelessWidget {
  const _AsyncIconButtonChild({
    required this.icon,
    this.loadingChild,
    this.style,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    this.customBuilder,
  });

  final Widget icon;
  final Widget? loadingChild;
  final ButtonStyle? style;
  final TransitionAnimationType transitionType;
  final bool isLoading;
  final Duration animationDuration;
  final double minimumChildOpacity;
  final Widget Function(bool loading, Widget icon, Widget? loadingChild)?
      customBuilder;

  @override
  Widget build(BuildContext context) {
    return switch (transitionType) {
      TransitionAnimationType.stack => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              child: icon,
              opacity: isLoading ? minimumChildOpacity : 1.0,
              duration: animationDuration,
            ),
            AnimatedOpacity(
              child: Visibility(
                child: _DefaultLoadingIndicator(style: style),
                visible: isLoading,
              ),
              opacity: isLoading ? 1.0 : 0.0,
              duration: animationDuration,
            ),
          ],
        ),
      TransitionAnimationType.animatedSwitcher => AnimatedSwitcher(
          child: !isLoading
              ? IgnorePointer(ignoring: isLoading, child: icon)
              : loadingChild ?? _DefaultLoadingIndicator(style: style),
          duration: animationDuration,
        ),
      TransitionAnimationType.customBuilder => customBuilder != null
          ? customBuilder?.call(isLoading, icon, loadingChild) ?? icon
          : icon
    };
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
