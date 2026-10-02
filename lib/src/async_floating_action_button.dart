import 'dart:async';

import 'package:loadable_buttons/src/async_button_error_handler.dart';
import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

enum _FloatingActionButtonType { regular, small, large, extended }

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionButton tag>';
}

/// A Material [FloatingActionButton] with external and async loading states.
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
class AsyncFloatingActionButton extends StatefulWidget {
  /// General constructor that allows both sync and async callbacks.
  /// A null [onPressed] preserves the native Material disabled behavior.
  const AsyncFloatingActionButton({
    required this.child,
    required this.onPressed,
    this.onError,
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
    this.splashFactory,
    super.key,
  }) : assert(
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
    this.onError,
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
    this.splashFactory,
    super.key,
  }) : assert(
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
    this.onError,
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
    this.splashFactory,
    super.key,
  }) : assert(
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
    this.onError,
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
    this.extendedIconLabelSpacing,
    this.extendedPadding,
    this.extendedTextStyle,
    this.isExtended = true,
    this.splashFactory,
    Widget? icon,
    super.key,
  }) : assert(
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
  /// Null disables the button.
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

  /// The focusNode of the button.
  final FocusNode? focusNode;

  /// The autofocus of the button.
  final bool autofocus;

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
  /// Extended buttons can call the builder separately for icon and label slots.
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
  final Widget? _extendedLabel;

  /// The padding of the button.
  final TextStyle? extendedTextStyle;

  /// The padding of the button.
  final EdgeInsetsGeometry? extendedPadding;

  /// The padding of the button.
  final double? extendedIconLabelSpacing;

  /// Optional SplashFactory to customize the splash effect.
  /// Use NoSplash.splashFactory to disable flutter default splash effect.
  final InteractiveInkFeatureFactory? splashFactory;

  @override
  State<AsyncFloatingActionButton> createState() =>
      _AsyncFloatingActionButtonState();
}

class _AsyncFloatingActionButtonState extends State<AsyncFloatingActionButton>
    with AsyncButtonState<AsyncFloatingActionButton> {
  static const _extendedPaddingWithIcon = EdgeInsetsDirectional.only(
    start: 16,
    end: 20,
  );

  static const _extendedPaddingWithoutIcon = EdgeInsets.symmetric(
    horizontal: 20,
  );

  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  @override
  AsyncButtonErrorHandler? get asyncOnError => widget.onError;

  bool get _useFullExtendedStack =>
      widget.transitionType == TransitionAnimationType.stack &&
      widget.isExtended;

  bool get _useCombinedExtendedContent =>
      _useFullExtendedStack && widget.child != null;

  EdgeInsetsGeometry _extendedPaddingOf(BuildContext context) =>
      widget.extendedPadding ??
      FloatingActionButtonTheme.of(context).extendedPadding ??
      (widget.child == null
          ? _extendedPaddingWithoutIcon
          : _extendedPaddingWithIcon);

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(splashFactory: widget.splashFactory),
    child: switch (widget._floatingActionButtonType) {
      _FloatingActionButtonType.regular => FloatingActionButton(
        child: _AsyncFloatingActionButtonChild(
          child: widget.child ?? const SizedBox.shrink(),
          color: widget.foregroundColor,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          loadingChild: widget.loadingChild,
          customBuilder: widget.customBuilder,
        ),
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
        mouseCursor: widget.mouseCursor,
        mini: widget.mini,
        shape: widget.shape,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        materialTapTargetSize: widget.materialTapTargetSize,
        isExtended: widget.isExtended,
        enableFeedback: widget.enableFeedback,
      ),
      _FloatingActionButtonType.small => FloatingActionButton.small(
        child: _AsyncFloatingActionButtonChild(
          child: widget.child ?? const SizedBox.shrink(),
          color: widget.foregroundColor,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          loadingChild: widget.loadingChild,
          customBuilder: widget.customBuilder,
        ),
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
        mouseCursor: widget.mouseCursor,
        shape: widget.shape,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        materialTapTargetSize: widget.materialTapTargetSize,
        enableFeedback: widget.enableFeedback,
      ),
      _FloatingActionButtonType.large => FloatingActionButton.large(
        child: _AsyncFloatingActionButtonChild(
          child: widget.child ?? const SizedBox.shrink(),
          color: widget.foregroundColor,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          loadingChild: widget.loadingChild,
          customBuilder: widget.customBuilder,
        ),
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
        mouseCursor: widget.mouseCursor,
        shape: widget.shape,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        materialTapTargetSize: widget.materialTapTargetSize,
        enableFeedback: widget.enableFeedback,
      ),
      _FloatingActionButtonType.extended => FloatingActionButton.extended(
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
        mouseCursor: widget.mouseCursor,
        shape: widget.shape,
        isExtended: widget.isExtended,
        materialTapTargetSize: widget.materialTapTargetSize,
        clipBehavior: widget.clipBehavior,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        extendedIconLabelSpacing: widget.extendedIconLabelSpacing,
        // Keep padding in the retained idle layout so the stack's center
        // includes it without changing the native idle dimensions.
        extendedPadding: _useFullExtendedStack
            ? EdgeInsets.zero
            : widget.extendedPadding,
        extendedTextStyle: widget.extendedTextStyle,
        icon: widget.child == null || _useCombinedExtendedContent
            ? null
            : _AsyncFloatingActionButtonChild(
                child: widget.child ?? const SizedBox.shrink(),
                color: widget.foregroundColor,
                isLoading: isLoading,
                transitionType: widget.transitionType,
                animationDuration: widget.animationDuration,
                minimumChildOpacity: widget.minimumChildOpacity,
                loadingChild: const SizedBox.shrink(),
                customBuilder: widget.customBuilder,
              ),
        label: _AsyncFloatingActionButtonChild(
          contentPadding: _useFullExtendedStack
              ? _extendedPaddingOf(context)
              : EdgeInsets.zero,
          leadingIcon: _useCombinedExtendedContent ? widget.child : null,
          iconLabelSpacing: widget.extendedIconLabelSpacing,
          child: AnimatedSize(
            child: widget._extendedLabel ?? const SizedBox.shrink(),
            duration: widget.animationDuration,
          ),
          color: widget.foregroundColor,
          isLoading: isLoading,
          transitionType: widget.transitionType,
          animationDuration: widget.animationDuration,
          minimumChildOpacity: widget.minimumChildOpacity,
          loadingChild: widget.loadingChild,
          customBuilder: widget.customBuilder,
        ),
        enableFeedback: widget.enableFeedback,
      ),
    },
  );
}

class _AsyncFloatingActionButtonChild extends StatelessWidget {
  const _AsyncFloatingActionButtonChild({
    required this.child,
    required this.color,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    required this.loadingChild,
    required this.customBuilder,
    this.leadingIcon,
    this.iconLabelSpacing,
    this.contentPadding = EdgeInsets.zero,
  });

  static const double _defaultIconLabelSpacing = 8.0;

  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final Widget? leadingIcon;
  final double? iconLabelSpacing;
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
    if (transitionType == TransitionAnimationType.customBuilder) {
      return customBuilder?.call(isLoading, child, loadingChild) ?? child;
    }

    final icon = leadingIcon;

    return LoadingTransition(
      child: Padding(
        padding: contentPadding,
        child: icon == null
            ? child
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  SizedBox(
                    width:
                        iconLabelSpacing ??
                        FloatingActionButtonTheme.of(
                          context,
                        ).extendedIconLabelSpacing ??
                        _defaultIconLabelSpacing,
                  ),
                  child,
                ],
              ),
      ),
      loadingChild: loadingChild ?? DefaultLoadingIndicator(color: color),
      isLoading: isLoading,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
      animateChildSize: false,
    );
  }
}
