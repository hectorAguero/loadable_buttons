import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _IconButtonBuilder = Widget Function({
  required FutureOr<void> Function()? onPressed,
  required Widget label,
  Widget? icon,
  VoidCallback? onLongPress,
  ValueChanged<bool>? onHover,
  ValueChanged<bool>? onFocusChange,
  FocusNode? focusNode,
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
    for (final hasIcon in [true, false]) {
      final icon = hasIcon ? const Icon(Icons.add) : null;
      group('${entry.key} with ${hasIcon ? 'an icon' : 'a null icon'}', () {
        testWidgets('delivers long presses with and without onPressed',
            (tester) async {
          var longPresses = 0;
          var presses = 0;
          void onLongPress() {
            longPresses++;
          }

          await tester.pumpWidget(_host(entry.value(
            onPressed: () {
              presses++;
            },
            onLongPress: onLongPress,
            icon: icon,
            label: const Text('Run'),
          )));
          await tester.longPress(find.text('Run'));
          expect(longPresses, 1);
          expect(presses, 0);

          await tester.pumpWidget(_host(entry.value(
            onPressed: null,
            onLongPress: onLongPress,
            icon: icon,
            label: const Text('Run'),
          )));
          await tester.longPress(find.text('Run'));
          expect(longPresses, 2);
        });

        testWidgets('reports mouse enter and exit', (tester) async {
          final hoverChanges = <bool>[];
          await tester.pumpWidget(_host(entry.value(
            onPressed: () {},
            onHover: hoverChanges.add,
            icon: icon,
            label: const Text('Run'),
          )));
          final mouse =
              await tester.createGesture(kind: PointerDeviceKind.mouse);
          addTearDown(mouse.removePointer);
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(tester.getCenter(find.text('Run')));
          await tester.pump();
          expect(hoverChanges, [true]);

          await mouse.moveTo(Offset.zero);
          await tester.pump();
          expect(hoverChanges, [true, false]);
        });

        testWidgets('uses requested focus and reports focus changes',
            (tester) async {
          final focusNode = FocusNode();
          addTearDown(focusNode.dispose);
          final focusChanges = <bool>[];
          var presses = 0;
          await tester.pumpWidget(_host(entry.value(
            onPressed: () {
              presses++;
            },
            focusNode: focusNode,
            onFocusChange: focusChanges.add,
            icon: icon,
            label: const Text('Run'),
          )));

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

Widget _host(Widget button) => MaterialApp(
      home: Scaffold(body: Center(child: button)),
    );
