import 'package:flutter/foundation.dart';
import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

/// Describes the style shortcuts and native options of the Elevated, Filled,
/// Outlined, and Text families.
///
/// Shortcuts are folded into the native button's single `style`, so they are
/// described individually here.
void debugFillMaterialButtonProperties(
  DiagnosticPropertiesBuilder properties, {
  required ButtonStyle? style,
  required EdgeInsetsGeometry? padding,
  required Size? minimumSize,
  required AlignmentGeometry? alignment,
  required Color? backgroundColor,
  required Color? foregroundColor,
  required Color? disabledBackgroundColor,
  required Color? disabledForegroundColor,
  required Clip? clipBehavior,
  required WidgetStatesController? statesController,
  required ValueChanged<bool>? onHover,
  required InteractiveInkFeatureFactory? splashFactory,
}) {
  properties
    ..add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null))
    ..add(
      DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding',
        padding,
        defaultValue: null,
      ),
    )
    ..add(
      DiagnosticsProperty<Size>('minimumSize', minimumSize, defaultValue: null),
    )
    ..add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        alignment,
        defaultValue: null,
      ),
    )
    ..add(ColorProperty('backgroundColor', backgroundColor, defaultValue: null))
    ..add(ColorProperty('foregroundColor', foregroundColor, defaultValue: null))
    ..add(
      ColorProperty(
        'disabledBackgroundColor',
        disabledBackgroundColor,
        defaultValue: null,
      ),
    )
    ..add(
      ColorProperty(
        'disabledForegroundColor',
        disabledForegroundColor,
        defaultValue: null,
      ),
    )
    ..add(EnumProperty<Clip>('clipBehavior', clipBehavior, defaultValue: null))
    ..add(
      DiagnosticsProperty<WidgetStatesController>(
        'statesController',
        statesController,
        defaultValue: null,
      ),
    )
    ..add(ObjectFlagProperty<ValueChanged<bool>>.has('onHover', onHover))
    ..add(
      DiagnosticsProperty<InteractiveInkFeatureFactory>(
        'splashFactory',
        splashFactory,
        defaultValue: null,
      ),
    );
}

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
  final ButtonStyle base = style ?? ButtonStyle(splashFactory: splashFactory);
  if (padding == null &&
      minimumSize == null &&
      alignment == null &&
      backgroundColor == null &&
      foregroundColor == null &&
      disabledBackgroundColor == null &&
      disabledForegroundColor == null &&
      mouseCursor == null) {
    return base;
  }

  return base.copyWith(
    padding: ButtonStyleButton.allOrNull(padding),
    minimumSize: ButtonStyleButton.allOrNull(minimumSize),
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
    mouseCursor: _overrideButtonCursor(base.mouseCursor, mouseCursor),
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

WidgetStateProperty<MouseCursor?>? _overrideButtonCursor(
  WidgetStateProperty<MouseCursor?>? original,
  MouseCursor? cursor,
) {
  if (cursor == null) return original;

  return WidgetStateProperty.resolveWith(
    (states) =>
        WidgetStateProperty.resolveAs<MouseCursor?>(cursor, states) ??
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
    final Widget? content = super.child;

    return content is LoadingTransition &&
            content.transitionType == TransitionAnimationType.stack
        ? content.child
        : content;
  }

  @override
  ButtonStyle? get style {
    final ButtonStyle? originalStyle = super.style;
    final Widget? content = super.child;
    if (content is! LoadingTransition ||
        content.transitionType != TransitionAnimationType.stack) {
      return originalStyle;
    }

    return (originalStyle ?? const ButtonStyle()).copyWith(
      backgroundBuilder: (context, states, child) {
        final Widget Function(
          BuildContext context,
          Set<WidgetState> states,
          Widget? child,
        )?
        backgroundBuilder =
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null),
      )
      ..add(ObjectFlagProperty<Function>.has('themeStyleOf', themeStyleOf))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(
        StringProperty(
          'loadingSemanticsLabel',
          loadingSemanticsLabel,
          defaultValue: null,
        ),
      );
  }

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
