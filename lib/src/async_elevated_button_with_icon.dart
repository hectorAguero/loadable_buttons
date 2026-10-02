part of 'async_elevated_button.dart';

class _AsyncElevatedButtonWithIcon extends AsyncElevatedButton {
  _AsyncElevatedButtonWithIcon({
    required Widget label,
    required Widget icon,
    required super.onPressed,
    required super.loading,
    required super.loadingChild,
    super.key,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.focusNode,
    super.style,
    IconAlignment? iconAlignment,
    bool? autofocus,
    super.clipBehavior,
    super.statesController,
    super.animationDuration,
    super.minimumChildOpacity,
    super.transitionType,
    super.customBuilder,
    super.splashFactory,
    super.loadingSemanticsLabel,
  }) : super(
         autofocus: autofocus ?? false,
         child: _ElevatedButtonWithIconChild(
           label: label,
           icon: icon,
           buttonStyle: style,
           iconAlignment: iconAlignment,
         ),
       );
}

// Keep the complete async content as the child while using native icon
// defaults. Material still owns widget/theme/default style precedence.
class _ElevatedButtonWithIconPadding extends ElevatedButton
    with StackLoadingButton {
  const _ElevatedButtonWithIconPadding({
    required this._hasIcon,
    required super.onPressed,
    required super.child,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus,
    super.clipBehavior,
    super.statesController,
  });

  final bool _hasIcon;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    if (!_hasIcon) return super.defaultStyleOf(context);

    return ElevatedButton.icon(
      onPressed: null,
      icon: const SizedBox.shrink(),
      label: const SizedBox.shrink(),
    ).defaultStyleOf(context);
  }
}

/// Copy of ElevatedButton.icon with the loading animation.
class _ElevatedButtonWithIconChild extends StatelessWidget {
  const _ElevatedButtonWithIconChild({
    required this.label,
    required this.icon,
    required this.buttonStyle,
    required this.iconAlignment,
  });

  static const double _defaultFontSize = 14.0;
  static const double _maximumTextScale = 2.0;
  static const double _unscaledIconGap = 8.0;
  static const double _scaledIconGap = 4.0;
  static const double _fallbackIconGap = 6.0;

  final Widget label;
  final Widget icon;
  final ButtonStyle? buttonStyle;
  final IconAlignment? iconAlignment;

  @override
  Widget build(BuildContext context) {
    final defaultFontSize =
        buttonStyle?.textStyle?.resolve(const <WidgetState>{})?.fontSize ??
        _defaultFontSize;
    final scale =
        clampDouble(
          MediaQuery.textScalerOf(context).scale(defaultFontSize) /
              _defaultFontSize,
          1,
          _maximumTextScale,
        ) -
        1.0;
    final gap =
        lerpDouble(_unscaledIconGap, _scaledIconGap, scale) ?? _fallbackIconGap;
    final elevatedButtonTheme = ElevatedButtonTheme.of(context);
    final effectiveIconAlignment =
        iconAlignment ??
        elevatedButtonTheme.style?.iconAlignment ??
        buttonStyle?.iconAlignment ??
        IconAlignment.start;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: effectiveIconAlignment == IconAlignment.start
          ? <Widget>[icon, SizedBox(width: gap), Flexible(child: label)]
          : <Widget>[Flexible(child: label), SizedBox(width: gap), icon],
    );
  }
}
