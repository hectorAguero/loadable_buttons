part of 'async_elevated_button.dart';

class _AsyncElevatedButtonWithIcon extends AsyncElevatedButton {
  _AsyncElevatedButtonWithIcon({
    required this.label,
    required this.icon,
    required super.onPressed,
    required super.loading,
    required super.loadingChild,
    super.style,
    IconAlignment? iconAlignment,
    bool? autofocus,
    super.clipBehavior,
    super.statesController,
  }) : super(
         autofocus: autofocus ?? false,
         child: _ElevatedButtonWithIconChild(
           icon: icon,
           label: label,
           buttonStyle: style,
           iconAlignment: iconAlignment,
         ),
       );

  final Widget label;
  final Widget icon;

  @override
  State<_AsyncElevatedButtonWithIcon> createState() =>
      __AsyncElevatedButtonWithIconState();
}

class __AsyncElevatedButtonWithIconState
    extends State<_AsyncElevatedButtonWithIcon> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: widget.icon,
      label:
          widget.loading
              ? widget.child
              : widget.loadingChild ??
                  _DefaultLoadingIndicator(style: widget.style),
      onLongPress: widget.onLongPress,
      onHover: widget.onHover,
      onFocusChange: widget.onFocusChange,
      style: widget.style,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      clipBehavior: widget.clipBehavior,
      statesController: widget.statesController,
    );
  }
}

/// Copy of ElevatedButton.icon with the loading animation
class _ElevatedButtonWithIconChild extends StatelessWidget {
  const _ElevatedButtonWithIconChild({
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
        buttonStyle?.textStyle?.resolve(const <WidgetState>{})?.fontSize ??
        14.0;
    final scale =
        clampDouble(
          MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0,
          1,
          2,
        ) -
        1.0;
    final gap = lerpDouble(8, 4, scale) ?? 6;
    final elevatedButtonTheme = ElevatedButtonTheme.of(context);
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
