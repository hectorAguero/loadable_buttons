import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _Builder = Widget Function({
  required bool loading,
  required Future<void> Function()? onPressed,
  required VoidCallback onLongPress,
});

void main() {
  final builders = <String, _Builder>{
    'Elevated': (
            {required loading, required onPressed, required onLongPress}) =>
        AsyncElevatedButton(
            loading: loading,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: true,
            child: const Text('Run')),
    'Filled': ({required loading, required onPressed, required onLongPress}) =>
        AsyncFilledButton(
            loading: loading,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: true,
            child: const Text('Run')),
    'Filled tonal': (
            {required loading, required onPressed, required onLongPress}) =>
        AsyncFilledButton.tonal(
            loading: loading,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: true,
            child: const Text('Run')),
    'Outlined': (
            {required loading, required onPressed, required onLongPress}) =>
        AsyncOutlinedButton(
            loading: loading,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: true,
            child: const Text('Run')),
    'Text': ({required loading, required onPressed, required onLongPress}) =>
        AsyncTextButton(
            loading: loading,
            onPressed: onPressed,
            onLongPress: onLongPress,
            autofocus: true,
            child: const Text('Run')),
  };

  for (final entry in builders.entries) {
    testWidgets('${entry.key} blocks long press and keyboard while pending',
        (tester) async {
      final pending = Completer<void>();
      var presses = 0;
      var longPresses = 0;
      await tester.pumpWidget(_host(entry.value(
        loading: false,
        onPressed: () {
          presses++;
          return pending.future;
        },
        onLongPress: () {
          longPresses++;
        },
      )));
      await tester.pump();
      final button =
          find.byWidgetPredicate((widget) => widget is ButtonStyleButton);
      final position = tester.getCenter(button);
      // Capture a callback already exposed to Material before the next frame.
      final idleLongPress =
          tester.widget<ButtonStyleButton>(button).onLongPress!;
      await tester.tapAt(position);
      idleLongPress();
      expect(longPresses, 0);
      await tester.pump();
      expect(
          tester.getSemantics(button),
          matchesSemantics(
            label: 'Run',
            isFocused: true,
            isFocusable: true,
            hasFocusAction: true,
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ));
      await tester.longPressAt(position);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(presses, 1);
      expect(longPresses, 0);
      pending.complete();
      await tester.pump();
      await tester.longPressAt(position);
      expect(longPresses, 1);
    });

    testWidgets('${entry.key} preserves idle long-press-only behavior',
        (tester) async {
      var calls = 0;
      Widget host(bool loading) => _host(entry.value(
            loading: loading,
            onPressed: null,
            onLongPress: () {
              calls++;
            },
          ));
      await tester.pumpWidget(host(true));
      final button =
          find.byWidgetPredicate((widget) => widget is ButtonStyleButton);
      final position = tester.getCenter(button);
      expect(
          tester.getSemantics(button),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ));
      await tester.longPressAt(position);
      expect(calls, 0);
      await tester.pumpWidget(host(false));
      await tester.longPressAt(position);
      expect(calls, 1);
      expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);
    });
  }
}

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
