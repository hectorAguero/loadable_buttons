part of 'async_text_button.dart';

class _AsyncTextButtonWithIcon extends AsyncTextButton {
  _AsyncTextButtonWithIcon({
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
  }) : super(
         autofocus: autofocus ?? false,
         child: _TextButtonWithIconChild(
           label: label,
           icon: icon,
           buttonStyle: style,
           iconAlignment: iconAlignment,
         ),
       );
}

/// Copy of TextButton.icon with the loading animation.
class _TextButtonWithIconChild extends StatelessWidget {
  const _TextButtonWithIconChild({
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
    final elevatedButtonTheme = TextButtonTheme.of(context);
    final effectiveIconAlignment =
        iconAlignment ??
        elevatedButtonTheme.style?.iconAlignment ??
        buttonStyle?.iconAlignment ??
        IconAlignment.start;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          effectiveIconAlignment == IconAlignment.start
              ? <Widget>[icon, SizedBox(width: gap), Flexible(child: label)]
              : <Widget>[Flexible(child: label), SizedBox(width: gap), icon],
    );
  }
}
