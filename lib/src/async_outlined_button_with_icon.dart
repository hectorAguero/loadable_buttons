// To support lower versions than 3.22.0 for MaterialState.
// ignore_for_file: deprecated_member_use

part of 'async_outlined_button.dart';

class _AsyncOutlinedButtonWithIcon extends AsyncOutlinedButton {
  _AsyncOutlinedButtonWithIcon({
    required Widget label,
    required Widget icon,
    required super.onPressed,
    required super.loading,
    required super.loadingChild,
    super.key,
    super.style,
    IconAlignment? iconAlignment,
    bool? autofocus,
    super.clipBehavior,
    super.statesController,
    super.animationDuration,
    super.minimumChildOpacity,
    super.transitionType,
    super.customBuilder,
  }) : super(
          autofocus: autofocus ?? false,
          child: _OutlinedButtonWithIconChild(
            label: label,
            icon: icon,
            buttonStyle: style,
            iconAlignment: iconAlignment,
          ),
        );
}

/// Copy of OutlinedButton.icon with the loading animation.
class _OutlinedButtonWithIconChild extends StatelessWidget {
  const _OutlinedButtonWithIconChild({
    required this.label,
    required this.icon,
    required this.buttonStyle,
    required this.iconAlignment,
  });

  final Widget label;
  final Widget icon;
  final ButtonStyle? buttonStyle;
  final IconAlignment? iconAlignment;

  @override
  Widget build(BuildContext context) {
    final defaultFontSize =
        buttonStyle?.textStyle?.resolve(const <MaterialState>{})?.fontSize ??
            14.0;
    final scale = clampDouble(
          MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0,
          1,
          2,
        ) -
        1.0;
    final gap = lerpDouble(8, 4, scale) ?? 6;
    final elevatedButtonTheme = OutlinedButtonTheme.of(context);
    final effectiveIconAlignment = iconAlignment ??
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
