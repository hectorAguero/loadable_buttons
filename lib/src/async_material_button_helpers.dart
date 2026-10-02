import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

/// Presents stack content in Material's full button layer, including padding.
///
/// The native button keeps control of padding, alignment, sizing, state, and
/// inherited styles. Loading content shares its paint, hit-test, and semantics
/// bounds instead of being translated outside the idle content's layout.
mixin StackLoadingButton on ButtonStyleButton {
  @override
  Widget? get child {
    final content = super.child;

    return content is LoadingTransition &&
            content.transitionType == TransitionAnimationType.stack
        ? content.child
        : content;
  }

  @override
  ButtonStyle? get style {
    final originalStyle = super.style;
    final content = super.child;
    if (content is! LoadingTransition ||
        content.transitionType != TransitionAnimationType.stack) {
      return originalStyle;
    }

    return (originalStyle ?? const ButtonStyle()).copyWith(
      backgroundBuilder: (context, states, child) {
        final backgroundBuilder =
            originalStyle?.backgroundBuilder ??
            themeStyleOf(context)?.backgroundBuilder ??
            defaultStyleOf(context).backgroundBuilder;

        final transition = LoadingTransition(
          child: child ?? const SizedBox.shrink(),
          loadingChild: content.loadingChild,
          isLoading: content.isLoading,
          transitionType: content.transitionType,
          animationDuration: content.animationDuration,
          minimumChildOpacity: content.minimumChildOpacity,
          animateChildSize: content.animateChildSize,
          preserveChildConstraints: true,
        );

        return backgroundBuilder?.call(context, states, transition) ??
            transition;
      },
    );
  }
}

/// Applies optional constructor shortcuts over the supplied [style].
///
/// Returns [style] unchanged when every shortcut is null. Otherwise, each
/// non-null shortcut replaces only its property and state. Enabled colors
/// leave disabled states to [style], disabled colors leave other states to
/// [style], and states a shortcut doesn't cover keep resolving through [style],
/// then the family theme and native defaults. A plain [mouseCursor] applies in
/// every state; a [WidgetStateMouseCursor] resolves per state.
ButtonStyle? applyButtonStyleShortcuts(
  ButtonStyle? style, {
  EdgeInsetsGeometry? padding,
  Size? minimumSize,
  AlignmentGeometry? alignment,
  Color? backgroundColor,
  Color? foregroundColor,
  Color? disabledBackgroundColor,
  Color? disabledForegroundColor,
  MouseCursor? mouseCursor,
}) {
  if (padding == null &&
      minimumSize == null &&
      alignment == null &&
      backgroundColor == null &&
      foregroundColor == null &&
      disabledBackgroundColor == null &&
      disabledForegroundColor == null &&
      mouseCursor == null) {
    return style;
  }

  return (style ?? const ButtonStyle()).copyWith(
    padding: padding == null
        ? null
        : WidgetStatePropertyAll<EdgeInsetsGeometry?>(padding),
    minimumSize: minimumSize == null
        ? null
        : WidgetStatePropertyAll<Size?>(minimumSize),
    alignment: alignment,
    backgroundColor: _composeStateColor(
      enabled: backgroundColor,
      disabled: disabledBackgroundColor,
      fallback: style?.backgroundColor,
    ),
    foregroundColor: _composeStateColor(
      enabled: foregroundColor,
      disabled: disabledForegroundColor,
      fallback: style?.foregroundColor,
    ),
    mouseCursor: mouseCursor == null
        ? null
        : WidgetStateProperty.resolveWith<MouseCursor?>(
            (states) =>
                WidgetStateProperty.resolveAs<MouseCursor>(mouseCursor, states),
          ),
  );
}

/// Overrides enabled or disabled colors while keeping [fallback] per state.
WidgetStateProperty<Color?>? _composeStateColor({
  required Color? enabled,
  required Color? disabled,
  required WidgetStateProperty<Color?>? fallback,
}) {
  if (enabled == null && disabled == null) return fallback;

  return WidgetStateProperty.resolveWith<Color?>(
    (states) =>
        (states.contains(WidgetState.disabled) ? disabled : enabled) ??
        fallback?.resolve(states),
  );
}

/// Keeps Material's original clipping policy when adding the loading layer.
Clip resolveButtonClipBehavior({
  required Clip? clipBehavior,
  required ButtonStyle? style,
  required ButtonStyle? themeStyle,
}) =>
    clipBehavior ??
    ((style?.backgroundBuilder ?? themeStyle?.backgroundBuilder) != null ||
            (style?.foregroundBuilder ?? themeStyle?.foregroundBuilder) != null
        ? Clip.antiAlias
        : Clip.none);

/// Package-internal default indicator, resolved inside the Material button.
class DefaultLoadingIndicator extends StatelessWidget {
  /// Keeps each family's foreground source and optional semantics explicit.
  const DefaultLoadingIndicator({
    this.style,
    this.themeStyleOf,
    this.color,
    this.loadingSemanticsLabel,
    super.key,
  });

  static const double _defaultStrokeWidth = 3.0;

  /// The explicit button style.
  final ButtonStyle? style;

  /// Looks up the family-specific theme using the indicator's own context.
  final ButtonStyle? Function(BuildContext context)? themeStyleOf;

  /// The explicit FAB foreground color.
  final Color? color;

  /// The optional localized accessibility label for the default spinner.
  final String? loadingSemanticsLabel;

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
    // WidgetState is available in Flutter 3.22. Resolve each foreground
    // in the normal state before applying precedence.
    color:
        color ??
        style?.foregroundColor?.resolve(<WidgetState>{}) ??
        themeStyleOf
            ?.call(context)
            ?.foregroundColor
            ?.resolve(<WidgetState>{}) ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color,
    strokeWidth: _defaultStrokeWidth,
    semanticsLabel: loadingSemanticsLabel,
    strokeCap: StrokeCap.round,
    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
  );
}
