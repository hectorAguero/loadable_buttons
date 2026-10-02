import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

/// Applies nullable Material shortcuts, preserving unrelated style fields.
///
/// For each property and state, a non-null shortcut wins over [style]. A null
/// shortcut result preserves the supplied resolver, allowing the native button
/// to fall back to its family theme and defaults when both return null.
ButtonStyle resolveMaterialButtonStyle({
  ButtonStyle? style,
  EdgeInsetsGeometry? padding,
  Size? minimumSize,
  AlignmentGeometry? alignment,
  Color? backgroundColor,
  Color? foregroundColor,
  Color? disabledBackgroundColor,
  Color? disabledForegroundColor,
  MouseCursor? mouseCursor,
  InteractiveInkFeatureFactory? splashFactory,
}) {
  final base = style ?? ButtonStyle(splashFactory: splashFactory);

  return base.copyWith(
    padding: padding == null ? null : WidgetStatePropertyAll(padding),
    minimumSize: minimumSize == null
        ? null
        : WidgetStatePropertyAll(minimumSize),
    alignment: alignment,
    backgroundColor: _overrideButtonColors(
      base.backgroundColor,
      backgroundColor,
      disabledBackgroundColor,
    ),
    foregroundColor: _overrideButtonColors(
      base.foregroundColor,
      foregroundColor,
      disabledForegroundColor,
    ),
    mouseCursor: mouseCursor == null
        ? null
        : WidgetStateProperty.resolveWith(
            (states) =>
                WidgetStateProperty.resolveAs<MouseCursor?>(
                  mouseCursor,
                  states,
                ) ??
                base.mouseCursor?.resolve(states),
          ),
  );
}

WidgetStateProperty<Color?>? _overrideButtonColors(
  WidgetStateProperty<Color?>? original,
  Color? enabled,
  Color? disabled,
) {
  if (enabled == null && disabled == null) return original;

  return WidgetStateProperty.resolveWith(
    (states) =>
        (states.contains(WidgetState.disabled) ? disabled : enabled) ??
        original?.resolve(states),
  );
}

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
