// To support lower versions than 3.22.0 for MaterialState.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/loading_transition.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

/// AsyncIconButton is a custom widget that allows to load a child.
class AsyncIconButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// A null [onPressed] preserves the native Material disabled behavior.
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
    this.splashFactory,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(
          splashFactory == null || style == null,
          'splashFactory and style cannot be used together, use style',
        ),
        _variant = _IconButtonVariant.standard;

  /// Constructor for AsyncIconButton with filled variant.
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
    this.splashFactory,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(
          splashFactory == null || style == null,
          'splashFactory and style cannot be used together, use style',
        ),
        _variant = _IconButtonVariant.filled;

  /// Constructor for AsyncIconButton with filled tonal variant.
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
    this.splashFactory,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(
          splashFactory == null || style == null,
          'splashFactory and style cannot be used together, use style',
        ),
        assert(splashRadius == null || splashRadius > 0),
        _variant = _IconButtonVariant.filledTonal;

  /// Constructor for AsyncIconButton with outlined variant.
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
    this.splashFactory,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(
          splashFactory == null || style == null,
          'splashFactory and style cannot be used together, use style',
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

  /// Size of the icon button.
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

  /// The selection state of the Material 3 icon button.
  ///
  /// Resolved on each build with [MaterialState] disabled when loading or when
  /// [onPressed] is null, and an empty state set otherwise. A null property
  /// preserves normal push-button behavior.
  final MaterialStateProperty<bool>? isSelected;

  /// The icon shown when [isSelected] resolves to true in Material 3.
  ///
  /// Uses the same loading transition as [icon]. If null, [icon] is used in
  /// both selection states, matching [IconButton.selectedIcon].
  final Widget? selectedIcon;

  /// Optional SplashFactory to customize the splash effect.
  /// Use NoSplash.splashFactory to disable flutter default splash effect.
  /// It won't be used if the style property is set.
  final InteractiveInkFeatureFactory? splashFactory;

  /// The visual density of the button.
  final _IconButtonVariant _variant;

  @override
  State<AsyncIconButton> createState() => _AsyncIconButtonState();
}

class _AsyncIconButtonState extends State<AsyncIconButton> {
  bool _internalLoading = false;

  bool get _isLoading => _internalLoading || widget.loading;

  Future<void> _handlePressed() async {
    // If the async callback is provided, use it.
    if (widget.onPressed != null) {
      // Prevent multiple presses.
      if (_isLoading) return;
      setState(() => _internalLoading = true);

      try {
        await widget.onPressed?.call();
      } finally {
        // Ensure that state is updated even if an exception occurs.
        if (mounted) setState(() => _internalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected?.resolve({
      if (_isLoading || widget.onPressed == null) MaterialState.disabled,
    });
    final icon = _AsyncIconButtonChild(
      icon: widget.icon,
      isLoading: _isLoading,
      transitionType: widget.transitionType,
      animationDuration: widget.animationDuration,
      minimumChildOpacity: widget.minimumChildOpacity,
      loadingChild: widget.loadingChild,
      style: widget.style,
      customBuilder: widget.customBuilder,
    );
    final selectedIcon = widget.selectedIcon;
    final selectedChild = selectedIcon == null
        ? null
        : _AsyncIconButtonChild(
            icon: selectedIcon,
            isLoading: _isLoading,
            transitionType: widget.transitionType,
            animationDuration: widget.animationDuration,
            minimumChildOpacity: widget.minimumChildOpacity,
            loadingChild: widget.loadingChild,
            style: widget.style,
            customBuilder: widget.customBuilder,
          );

    // Flutter 3.29 styleFrom supplies a default cursor that would otherwise
    // override IconButton's forwarded mouseCursor when these styles merge.
    final style = widget.style ??
        IconButton.styleFrom(
          splashFactory: widget.splashFactory,
          enabledMouseCursor: widget.mouseCursor,
          disabledMouseCursor: widget.mouseCursor,
        );

    return switch (widget._variant) {
      _IconButtonVariant.standard => IconButton(
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
          onPressed:
              _isLoading || widget.onPressed == null ? null : _handlePressed,
          onHover: widget.onHover,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.mouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          tooltip: widget.tooltip,
          enableFeedback: widget.enableFeedback,
          constraints: widget.constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedChild,
          icon: icon,
        ),
      _IconButtonVariant.filled => IconButton.filled(
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
          onPressed:
              _isLoading || widget.onPressed == null ? null : _handlePressed,
          onHover: widget.onHover,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.mouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          tooltip: widget.tooltip,
          enableFeedback: widget.enableFeedback,
          constraints: widget.constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedChild,
          icon: icon,
        ),
      _IconButtonVariant.filledTonal => IconButton.filledTonal(
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
          onPressed:
              _isLoading || widget.onPressed == null ? null : _handlePressed,
          onHover: widget.onHover,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.mouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          tooltip: widget.tooltip,
          enableFeedback: widget.enableFeedback,
          constraints: widget.constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedChild,
          icon: icon,
        ),
      _IconButtonVariant.outlined => IconButton.outlined(
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
          onPressed:
              _isLoading || widget.onPressed == null ? null : _handlePressed,
          onHover: widget.onHover,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.mouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          tooltip: widget.tooltip,
          enableFeedback: widget.enableFeedback,
          constraints: widget.constraints,
          style: style,
          isSelected: isSelected,
          selectedIcon: selectedChild,
          icon: icon,
        ),
    };
  }
}

class _AsyncIconButtonChild extends StatelessWidget {
  const _AsyncIconButtonChild({
    required this.icon,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    this.loadingChild,
    this.style,
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
    if (transitionType == TransitionAnimationType.customBuilder) {
      return customBuilder?.call(isLoading, icon, loadingChild) ?? icon;
    }

    return LoadingTransition(
      child: icon,
      loadingChild: loadingChild ?? _DefaultLoadingIndicator(style: style),
      isLoading: isLoading,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
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
      color: _style?.foregroundColor?.resolve(<MaterialState>{}) ??
          IconButtonTheme.of(context)
              .style
              ?.foregroundColor
              ?.resolve(<MaterialState>{}) ??
          IconTheme.of(context).color ??
          DefaultTextStyle.of(context).style.color,
      strokeWidth: _defaultStrokeWidth,
      strokeCap: StrokeCap.round,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
    );
  }
}
