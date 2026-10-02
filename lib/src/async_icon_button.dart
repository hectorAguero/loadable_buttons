import 'dart:async';

import 'package:loadable_buttons/src/async_button_helpers.dart';
import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

/// A Material [IconButton] with external and async loading states.
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
  }) : assert(
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
  }) : assert(
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
  }) : assert(
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
  }) : assert(
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
  /// Null disables the button.
  final FutureOr<void> Function()? onPressed;

  /// Whether the application requests external loading.
  ///
  /// Defaults to false. Effective loading combines this flag with a pending
  /// [onPressed] callback. Setting it to false neither cancels nor unlocks that
  /// callback; callback completion does not clear this flag.
  final bool loading;

  /// The synchronous long-press callback forwarded to [IconButton].
  ///
  /// Follows native IconButton behavior and does not start internal loading.
  /// Enabled state is determined by [onPressed] and effective loading.
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
  /// Resolved on each build with [WidgetState] disabled when loading or when
  /// [onPressed] is null, and an empty state set otherwise. A null property
  /// preserves normal push-button behavior.
  final WidgetStateProperty<bool>? isSelected;

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

class _AsyncIconButtonState extends State<AsyncIconButton>
    with AsyncButtonState<AsyncIconButton> {
  @override
  bool get externalLoading => widget.loading;

  @override
  FutureOr<void> Function()? get asyncOnPressed => widget.onPressed;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected?.resolve({
      if (isLoading || widget.onPressed == null) WidgetState.disabled,
    });
    final icon = _AsyncIconButtonChild(
      icon: widget.icon,
      isLoading: isLoading,
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
            isLoading: isLoading,
            transitionType: widget.transitionType,
            animationDuration: widget.animationDuration,
            minimumChildOpacity: widget.minimumChildOpacity,
            loadingChild: widget.loadingChild,
            style: widget.style,
            customBuilder: widget.customBuilder,
          );

    // Flutter 3.29 styleFrom supplies a default cursor that would otherwise
    // override IconButton's forwarded mouseCursor when these styles merge.
    final style =
        widget.style ??
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
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
        onPressed: isLoading || widget.onPressed == null ? null : handlePressed,
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
      loadingChild:
          loadingChild ??
          DefaultLoadingIndicator(
            style: style,
            themeStyleOf: (context) => IconButtonTheme.of(context).style,
          ),
      isLoading: isLoading,
      transitionType: transitionType,
      animationDuration: animationDuration,
      minimumChildOpacity: minimumChildOpacity,
    );
  }
}
