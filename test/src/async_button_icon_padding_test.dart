import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef _ButtonBuilder =
    Widget Function({
      required VoidCallback? onPressed,
      required Widget label,
      Widget? icon,
      ButtonStyle? style,
    });

typedef _Layout = ({Size size, Offset labelInset, Offset? iconInset});

final _buttons =
    <String, ({_ButtonBuilder nativeButton, _ButtonBuilder asyncButton})>{
      'Elevated.icon': (
        nativeButton: ElevatedButton.icon,
        asyncButton: AsyncElevatedButton.icon,
      ),
      'Filled.icon': (
        nativeButton: FilledButton.icon,
        asyncButton: AsyncFilledButton.icon,
      ),
      'Filled.tonalIcon': (
        nativeButton: FilledButton.tonalIcon,
        asyncButton: AsyncFilledButton.tonalIcon,
      ),
      'Outlined.icon': (
        nativeButton: OutlinedButton.icon,
        asyncButton: AsyncOutlinedButton.icon,
      ),
      'Text.icon': (
        nativeButton: TextButton.icon,
        asyncButton: AsyncTextButton.icon,
      ),
    };

void main() {
  for (final entry in _buttons.entries) {
    for (final useMaterial3 in [false, true]) {
      for (final direction in TextDirection.values) {
        for (final scale in [1.0, 1.5, 2.5]) {
          for (final hasIcon in [true, false]) {
            testWidgets(
              '${entry.key} matches native padding: '
              'M${useMaterial3 ? 3 : 2} $direction scale=$scale icon=$hasIcon',
              (tester) async {
                final layouts = await _measureLayouts(
                  tester,
                  entry.value,
                  useMaterial3: useMaterial3,
                  direction: direction,
                  scale: scale,
                  hasIcon: hasIcon,
                );
                expect(layouts.asyncLayout, layouts.nativeLayout);
              },
            );
          }
        }
      }
    }

    for (final direction in TextDirection.values) {
      final themeStyle = ButtonStyle(
        padding: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? const EdgeInsetsDirectional.fromSTEB(28, 6, 40, 6)
              : const EdgeInsetsDirectional.fromSTEB(20, 4, 32, 4),
        ),
      );
      final widgetStyle = ButtonStyle(
        padding: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? null
              : const EdgeInsetsDirectional.fromSTEB(36, 8, 48, 8),
        ),
      );
      for (final paddingCase in [
        (name: 'theme', style: null, themeStyle: themeStyle),
        (name: 'widget over theme', style: widgetStyle, themeStyle: themeStyle),
        (
          name: 'widget with null fallback',
          style: widgetStyle,
          themeStyle: null,
        ),
        (
          name: 'theme with null fallback',
          style: null,
          themeStyle: widgetStyle,
        ),
      ]) {
        for (final enabled in [true, false]) {
          testWidgets('${entry.key} preserves ${paddingCase.name} padding: '
              '$direction enabled=$enabled', (tester) async {
            final layouts = await _measureLayouts(
              tester,
              entry.value,
              direction: direction,
              style: paddingCase.style,
              themeStyle: paddingCase.themeStyle,
              enabled: enabled,
            );
            expect(layouts.asyncLayout, layouts.nativeLayout);
          });
        }
      }
    }
  }
}

Future<({_Layout nativeLayout, _Layout asyncLayout})> _measureLayouts(
  WidgetTester tester,
  ({_ButtonBuilder nativeButton, _ButtonBuilder asyncButton}) buttons, {
  bool useMaterial3 = true,
  TextDirection direction = TextDirection.ltr,
  double scale = 1.0,
  bool hasIcon = true,
  bool enabled = true,
  ButtonStyle? style,
  ButtonStyle? themeStyle,
}) async {
  const nativeKey = ValueKey('native');
  const asyncKey = ValueKey('async');
  Widget button(_ButtonBuilder builder) => builder(
    onPressed: enabled ? () {} : null,
    label: const Text('Save changes'),
    icon: hasIcon ? const Icon(Icons.save) : null,
    style: style,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: useMaterial3),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Directionality(
            textDirection: direction,
            child: ElevatedButtonTheme(
              data: ElevatedButtonThemeData(style: themeStyle),
              child: FilledButtonTheme(
                data: FilledButtonThemeData(style: themeStyle),
                child: OutlinedButtonTheme(
                  data: OutlinedButtonThemeData(style: themeStyle),
                  child: TextButtonTheme(
                    data: TextButtonThemeData(style: themeStyle),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KeyedSubtree(
                            key: nativeKey,
                            child: button(buttons.nativeButton),
                          ),
                          KeyedSubtree(
                            key: asyncKey,
                            child: button(buttons.asyncButton),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Finder within(Key key, Finder matching) =>
      find.descendant(of: find.byKey(key), matching: matching);
  // The native constructor is the independent reference, including its
  // SDK-specific scaling and padding. Check insets as well as total size.
  _Layout layout(Key key) {
    final rect = tester.getRect(
      within(
        key,
        find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
      ),
    );

    return (
      size: rect.size,
      labelInset:
          tester.getTopLeft(within(key, find.text('Save changes'))) -
          rect.topLeft,
      iconInset: hasIcon
          ? tester.getTopLeft(within(key, find.byIcon(Icons.save))) -
                rect.topLeft
          : null,
    );
  }

  return (nativeLayout: layout(nativeKey), asyncLayout: layout(asyncKey));
}
