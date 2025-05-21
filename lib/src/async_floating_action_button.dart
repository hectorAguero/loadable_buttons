// To support lower versions than 3.22.0 for MaterialState.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/transition_animation_type.dart';

enum _FloatingActionButtonType { regular, small, large, extended }

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionButton tag>';
}

/// AsyncFloatingActionButton is a custom widget that allows to load a child.
class AsyncFloatingActionButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// At least one callback must be non-null.
  const AsyncFloatingActionButton({
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag = const _DefaultHeroTag(),
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.mini = false,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.isExtended = false,
    this.enableFeedback,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.loadingChild,
    this.loading = false,
    this.style,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        _floatingActionButtonType = mini
            ? _FloatingActionButtonType.small
            : _FloatingActionButtonType.regular,
        _extendedLabel = null,
        extendedIconLabelSpacing = null,
        extendedPadding = null,
        extendedTextStyle = null;

  /// Constructor for small FAB.
  const AsyncFloatingActionButton.small({
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag = const _DefaultHeroTag(),
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.enableFeedback,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.loadingChild,
    this.loading = false,
    this.style,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(elevation == null || elevation >= 0.0),
        assert(focusElevation == null || focusElevation >= 0.0),
        assert(hoverElevation == null || hoverElevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        _floatingActionButtonType = _FloatingActionButtonType.small,
        mini = true,
        isExtended = false,
        _extendedLabel = null,
        extendedIconLabelSpacing = null,
        extendedPadding = null,
        extendedTextStyle = null;

  /// Constructor for large FAB.
  const AsyncFloatingActionButton.large({
    required this.child,
    required this.onPressed,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag = const _DefaultHeroTag(),
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.enableFeedback,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.loadingChild,
    this.loading = false,
    this.style,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(elevation == null || elevation >= 0.0),
        assert(focusElevation == null || focusElevation >= 0.0),
        assert(hoverElevation == null || hoverElevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        _floatingActionButtonType = _FloatingActionButtonType.large,
        mini = false,
        isExtended = false,
        _extendedLabel = null,
        extendedIconLabelSpacing = null,
        extendedPadding = null,
        extendedTextStyle = null;

  /// Constructor for extended FAB.
  const AsyncFloatingActionButton.extended({
    required this.onPressed,
    required Widget label,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.heroTag = const _DefaultHeroTag(),
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.mouseCursor,
    this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.enableFeedback,
    this.animationDuration = Durations.medium1,
    this.minimumChildOpacity = 0.0,
    this.transitionType = TransitionAnimationType.stack,
    this.customBuilder,
    this.loadingChild,
    this.loading = false,
    this.style,
    this.extendedIconLabelSpacing,
    this.extendedPadding,
    this.extendedTextStyle,
    this.isExtended = true,
    Widget? icon,
    super.key,
  })  : assert(
          transitionType != TransitionAnimationType.customBuilder ||
              customBuilder != null,
          'customBuilder must be provided when transitionType is customBuilder',
        ),
        assert(elevation == null || elevation >= 0.0),
        assert(focusElevation == null || focusElevation >= 0.0),
        assert(hoverElevation == null || hoverElevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        mini = false,
        _floatingActionButtonType = _FloatingActionButtonType.extended,
        child = icon,
        _extendedLabel = label;

  /// The child of the button, same as the [FloatingActionButton.child].
  final Widget? child;

  /// The child that be show when the button is loading.
  final Widget? loadingChild;

  /// The onPressed callback of the button, but being async.
  final FutureOr<void> Function()? onPressed;

  /// The loading state of the button, by default is false.
  final bool loading;

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

  /// The focusColor of the button.
  final Color? focusColor;

  /// The hoverColor of the button.
  final Color? hoverColor;

  /// The splash color of the button.
  final Color? splashColor;

  /// The mouse cursor of the button.
  final MouseCursor? mouseCursor;

  /// The tooltip of the button.
  final String? tooltip;

  /// The visual density of the button.
  final bool? enableFeedback;

  /// Whether the button is mini or not.
  final bool mini;

  /// The visual density of the button.
  final _FloatingActionButtonType _floatingActionButtonType;

  /// The onPressed callback of the button.
  final Color? foregroundColor;

  /// The focus color of the button.
  final Color? backgroundColor;

  /// The splash color of the button.
  final Object? heroTag;

  /// The shape of the button.
  final double? elevation;

  /// The elevation of the button when it is focused.
  final double? focusElevation;

  /// The elevation of the button when it is hovered.
  final double? hoverElevation;

  /// The elevation of the button when it is highlighted.
  final double? highlightElevation;

  /// The elevation of the button when it is disabled.
  final double? disabledElevation;

  /// The shape of the button.
  final ShapeBorder? shape;

  /// The clip behavior of the button.
  final Clip clipBehavior;

  /// The loading state of the button.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// The padding of the button.
  final bool isExtended;

  /// The padding of the button.
  final ButtonStyle? style;

  /// The padding of the button.
  final Widget? _extendedLabel;

  /// The padding of the button.
  final TextStyle? extendedTextStyle;

  /// The padding of the button.
  final EdgeInsetsGeometry? extendedPadding;

  /// The padding of the button.
  final double? extendedIconLabelSpacing;

  @override
  State<AsyncFloatingActionButton> createState() =>
      _AsyncFloatingActionButtonState();
}

class _AsyncFloatingActionButtonState extends State<AsyncFloatingActionButton> {
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
  void didUpdateWidget(covariant AsyncFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the loading state changes, update the state.
    if (oldWidget.loading != widget.loading) {
      _isLoading = widget.loading;
    }
  }

  @override
  Widget build(BuildContext context) =>
      switch (widget._floatingActionButtonType) {
        _FloatingActionButtonType.regular => FloatingActionButton(
            key: widget.key,
            tooltip: widget.tooltip,
            foregroundColor: widget.foregroundColor,
            backgroundColor: widget.backgroundColor,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            splashColor: widget.splashColor,
            heroTag: widget.heroTag,
            elevation: widget.elevation,
            focusElevation: widget.focusElevation,
            hoverElevation: widget.hoverElevation,
            highlightElevation: widget.highlightElevation,
            disabledElevation: widget.disabledElevation,
            onPressed: _isLoading ? null : _handlePressed,
            mouseCursor: widget.mouseCursor,
            mini: widget.mini,
            shape: widget.shape,
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            materialTapTargetSize: widget.materialTapTargetSize,
            isExtended: widget.isExtended,
            enableFeedback: widget.enableFeedback,
            child: _AsyncFloatingActionButtonChild(
              loadingChild: widget.loadingChild,
              color:
                  widget.foregroundColor ?? ColorScheme.of(context).secondary,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
        _FloatingActionButtonType.small => FloatingActionButton.small(
            key: widget.key,
            tooltip: widget.tooltip,
            foregroundColor: widget.foregroundColor,
            backgroundColor: widget.backgroundColor,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            splashColor: widget.splashColor,
            heroTag: widget.heroTag,
            elevation: widget.elevation,
            focusElevation: widget.focusElevation,
            hoverElevation: widget.hoverElevation,
            highlightElevation: widget.highlightElevation,
            disabledElevation: widget.disabledElevation,
            onPressed: _isLoading ? null : _handlePressed,
            mouseCursor: widget.mouseCursor,
            shape: widget.shape,
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            materialTapTargetSize: widget.materialTapTargetSize,
            enableFeedback: widget.enableFeedback,
            child: _AsyncFloatingActionButtonChild(
              loadingChild: widget.loadingChild,
              color:
                  widget.foregroundColor ?? ColorScheme.of(context).secondary,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
        _FloatingActionButtonType.large => FloatingActionButton.large(
            key: widget.key,
            tooltip: widget.tooltip,
            foregroundColor: widget.foregroundColor,
            backgroundColor: widget.backgroundColor,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            splashColor: widget.splashColor,
            heroTag: widget.heroTag,
            elevation: widget.elevation,
            focusElevation: widget.focusElevation,
            hoverElevation: widget.hoverElevation,
            highlightElevation: widget.highlightElevation,
            disabledElevation: widget.disabledElevation,
            onPressed: _isLoading ? null : _handlePressed,
            mouseCursor: widget.mouseCursor,
            shape: widget.shape,
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            materialTapTargetSize: widget.materialTapTargetSize,
            enableFeedback: widget.enableFeedback,
            child: _AsyncFloatingActionButtonChild(
              loadingChild: widget.loadingChild,
              color:
                  widget.foregroundColor ?? ColorScheme.of(context).secondary,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
              child: widget.child ?? const SizedBox.shrink(),
            ),
          ),
        _FloatingActionButtonType.extended => FloatingActionButton.extended(
            key: widget.key,
            tooltip: widget.tooltip,
            foregroundColor: widget.foregroundColor,
            backgroundColor: widget.backgroundColor,
            focusColor: widget.focusColor,
            hoverColor: widget.hoverColor,
            heroTag: widget.heroTag,
            elevation: widget.elevation,
            focusElevation: widget.focusElevation,
            hoverElevation: widget.hoverElevation,
            splashColor: widget.splashColor,
            highlightElevation: widget.highlightElevation,
            disabledElevation: widget.disabledElevation,
            onPressed: _isLoading ? null : _handlePressed,
            mouseCursor: widget.mouseCursor,
            shape: widget.shape,
            isExtended: widget.isExtended,
            materialTapTargetSize: widget.materialTapTargetSize,
            clipBehavior: widget.clipBehavior,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            icon: widget.child,
            label: _AsyncFloatingActionButtonChild(
              loadingChild: widget.loadingChild,
              color:
                  widget.foregroundColor ?? ColorScheme.of(context).secondary,
              isLoading: _isLoading,
              transitionType: widget.transitionType,
              animationDuration: widget.animationDuration,
              minimumChildOpacity: widget.minimumChildOpacity,
              customBuilder: widget.customBuilder,
              child: widget._extendedLabel ?? const SizedBox.shrink(),
            ),
            enableFeedback: widget.enableFeedback,
          ),
      };
}

class _AsyncFloatingActionButtonChild extends StatelessWidget {
  const _AsyncFloatingActionButtonChild({
    required this.child,
    required this.color,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    this.loadingChild,
    this.customBuilder,
  });

  final Widget child;
  final Widget? loadingChild;
  final Color? color;
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
              opacity: isLoading ? minimumChildOpacity : 1.0,
              duration: animationDuration,
              child: child,
            ),
            AnimatedOpacity(
              opacity: isLoading ? 1.0 : 0.0,
              duration: animationDuration,
              child: Visibility(
                visible: isLoading,
                child: _DefaultLoadingIndicator(color: color),
              ),
            ),
          ],
        ),
      TransitionAnimationType.animatedSwitcher => AnimatedSwitcher(
          duration: animationDuration,
          child: !isLoading
              ? IgnorePointer(ignoring: isLoading, child: child)
              : loadingChild ?? _DefaultLoadingIndicator(color: color),
        ),
      TransitionAnimationType.customBuilder => customBuilder != null
          ? customBuilder?.call(isLoading, child, loadingChild) ?? child
          : child
    };
  }
}

class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator({required Color? color}) : _color = color;

  static const double _defaultStrokeWidth = 3.0;

  final Color? _color;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: _color,
      strokeWidth: _defaultStrokeWidth,
      strokeCap: StrokeCap.round,
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
    );
  }
}
