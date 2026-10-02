import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef _IconButtonBuilder =
    Widget Function({
      required FutureOr<void> Function()? onPressed,
      required Widget label,
      Widget? icon,
      VoidCallback? onLongPress,
      ValueChanged<bool>? onHover,
      ValueChanged<bool>? onFocusChange,
      FocusNode? focusNode,
      ButtonStyle? style,
      bool loading,
      Widget? loadingChild,
    });

void main() {
  final builders = <String, _IconButtonBuilder>{
    'Elevated.icon': AsyncElevatedButton.icon,
    'Filled.icon': AsyncFilledButton.icon,
    'Filled.tonalIcon': AsyncFilledButton.tonalIcon,
    'Outlined.icon': AsyncOutlinedButton.icon,
    'Text.icon': AsyncTextButton.icon,
  };

  for (final entry in builders.entries) {
    for (final direction in TextDirection.values) {
      for (final paddingSource in ['default', 'theme', 'widget']) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('${entry.key} centers its loader in the full button: '
              '$direction $paddingSource scale=$scale', (tester) async {
            final pending = Completer<void>();
            const loadingKey = ValueKey('loading');
            const paddingStyle = ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsetsDirectional.fromSTEB(10, 4, 30, 16),
              ),
            );
            await tester.pumpWidget(
              _host(
                entry.value(
                  onPressed: () => pending.future,
                  icon: const Icon(Icons.add),
                  label: const Text('Run this operation'),
                  style: paddingSource == 'widget' ? paddingStyle : null,
                  loadingChild: scale == 2.0
                      ? const SizedBox(key: loadingKey, width: 24, height: 20)
                      : null,
                ),
                direction: direction,
                scale: scale,
                themeStyle: paddingSource == 'theme' ? paddingStyle : null,
              ),
            );
            final button = find.byWidgetPredicate(
              (widget) => widget is ButtonStyleButton,
            );
            final idleSize = tester.getSize(button);
            await tester.tap(find.text('Run this operation'));
            await tester.pump();
            for (final elapsed in [
              Duration.zero,
              Durations.medium1 ~/ 2,
              Durations.medium1,
            ]) {
              await tester.pump(elapsed);
              final loader = scale == 2.0
                  ? find.byKey(loadingKey)
                  : find.byType(CircularProgressIndicator);
              final buttonCenter = tester.getCenter(button);
              final loaderCenter = tester.getCenter(loader);
              expect(loaderCenter.dx, closeTo(buttonCenter.dx, 0.01));
              expect(loaderCenter.dy, closeTo(buttonCenter.dy, 0.01));
              expect(tester.getSize(button), idleSize);
            }
            pending.complete();
            await tester.pump();
            await tester.pump(Durations.medium1);
          });
        }
      }
    }

    for (final styleSource in ['widget', 'theme']) {
      testWidgets('${entry.key} keeps centered custom loading controls and '
          '$styleSource background content usable', (tester) async {
        const loadingKey = ValueKey('loading-control');
        var calls = 0;
        final semantics = tester.ensureSemantics();
        try {
          final style = ButtonStyle(
            fixedSize: const WidgetStatePropertyAll(Size(280, 96)),
            alignment: AlignmentDirectional.bottomStart,
            padding: const WidgetStatePropertyAll(
              EdgeInsetsDirectional.fromSTEB(60, 2, 10, 14),
            ),
            backgroundBuilder: (_, _, child) =>
                Semantics(label: 'Button decoration', child: child),
          );
          await tester.pumpWidget(
            _host(
              entry.value(
                onPressed: () {},
                loading: true,
                icon: const Icon(Icons.add),
                label: const Text('Run'),
                style: styleSource == 'widget' ? style : null,
                loadingChild: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => calls++,
                  child: const SizedBox(key: loadingKey, width: 24, height: 24),
                ),
              ),
              themeStyle: styleSource == 'theme' ? style : null,
            ),
          );
          final button = find.byWidgetPredicate(
            (widget) => widget is ButtonStyleButton,
          );
          final buttonCenter = tester.getCenter(button);
          final loaderCenter = tester.getCenter(find.byKey(loadingKey));
          expect(loaderCenter.dx, closeTo(buttonCenter.dx, 0.01));
          expect(loaderCenter.dy, closeTo(buttonCenter.dy, 0.01));
          expect(find.semantics.byLabel(RegExp('Button decoration')), findsOne);
          await tester.tapAt(loaderCenter);
          expect(calls, 1);
        } finally {
          semantics.dispose();
        }
      });
    }

    for (final hasIcon in [true, false]) {
      final icon = hasIcon ? const Icon(Icons.add) : null;
      group('${entry.key} with ${hasIcon ? 'an icon' : 'a null icon'}', () {
        testWidgets('delivers long presses with and without onPressed', (
          tester,
        ) async {
          var longPresses = 0;
          var presses = 0;
          void onLongPress() {
            longPresses++;
          }

          await tester.pumpWidget(
            _host(
              entry.value(
                onPressed: () {
                  presses++;
                },
                onLongPress: onLongPress,
                icon: icon,
                label: const Text('Run'),
              ),
            ),
          );
          await tester.longPress(find.text('Run'));
          expect(longPresses, 1);
          expect(presses, 0);

          await tester.pumpWidget(
            _host(
              entry.value(
                onPressed: null,
                onLongPress: onLongPress,
                icon: icon,
                label: const Text('Run'),
              ),
            ),
          );
          await tester.longPress(find.text('Run'));
          expect(longPresses, 2);
        });

        testWidgets('reports mouse enter and exit', (tester) async {
          final hoverChanges = <bool>[];
          await tester.pumpWidget(
            _host(
              entry.value(
                onPressed: () {},
                onHover: hoverChanges.add,
                icon: icon,
                label: const Text('Run'),
              ),
            ),
          );
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          addTearDown(mouse.removePointer);
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getCenter(find.text('Run')));
          await tester.pump();
          expect(hoverChanges, [true]);

          await mouse.moveTo(Offset.zero);
          await tester.pump();
          expect(hoverChanges, [true, false]);
        });

        testWidgets('uses requested focus and reports focus changes', (
          tester,
        ) async {
          final focusNode = FocusNode();
          addTearDown(focusNode.dispose);
          final focusChanges = <bool>[];
          var presses = 0;
          await tester.pumpWidget(
            _host(
              entry.value(
                onPressed: () {
                  presses++;
                },
                focusNode: focusNode,
                onFocusChange: focusChanges.add,
                icon: icon,
                label: const Text('Run'),
              ),
            ),
          );

          focusNode.requestFocus();
          await tester.pump();
          expect(focusNode.hasFocus, isTrue);
          expect(focusChanges, [true]);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          expect(presses, 1);

          focusNode.unfocus();
          await tester.pump();
          expect(focusNode.hasFocus, isFalse);
          expect(focusChanges, [true, false]);
        });
      });
    }
  }
}

Widget _host(
  Widget button, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1.0,
  ButtonStyle? themeStyle,
}) => MaterialApp(
  theme: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(style: themeStyle),
    filledButtonTheme: FilledButtonThemeData(style: themeStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: themeStyle),
    textButtonTheme: TextButtonThemeData(style: themeStyle),
  ),
  home: Scaffold(
    body: Center(
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Directionality(textDirection: direction, child: button),
      ),
    ),
  ),
);
