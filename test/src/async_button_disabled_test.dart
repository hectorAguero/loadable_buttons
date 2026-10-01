// Keep compatibility with the package's Flutter 3.29 minimum.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui' show SemanticsAction, SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _ButtonBuilder = Widget Function(
    {required FutureOr<void> Function()? onPressed});

void main() {
  final builders = <String, _ButtonBuilder>{
    'Elevated': ({required onPressed}) =>
        AsyncElevatedButton(onPressed: onPressed, child: const Text('Run')),
    'Elevated.icon': ({required onPressed}) => AsyncElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('Run')),
    'Filled': ({required onPressed}) => AsyncFilledButton(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Filled.icon': ({required onPressed}) => AsyncFilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Filled.tonal': ({required onPressed}) => AsyncFilledButton.tonal(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Filled.tonalIcon': ({required onPressed}) => AsyncFilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Outlined': ({required onPressed}) => AsyncOutlinedButton(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Outlined.icon': ({required onPressed}) => AsyncOutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Text': ({required onPressed}) => AsyncTextButton(
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Text.icon': ({required onPressed}) => AsyncTextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Icon': ({required onPressed}) => AsyncIconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.filled': ({required onPressed}) => AsyncIconButton.filled(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.filledTonal': ({required onPressed}) => AsyncIconButton.filledTonal(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.outlined': ({required onPressed}) => AsyncIconButton.outlined(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Floating action': ({required onPressed}) => AsyncFloatingActionButton(
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.small': ({required onPressed}) =>
        AsyncFloatingActionButton.small(
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.large': ({required onPressed}) =>
        AsyncFloatingActionButton.large(
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.extended': ({required onPressed}) =>
        AsyncFloatingActionButton.extended(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
  };

  for (final entry in builders.entries) {
    testWidgets('${entry.key} preserves disabled semantics and re-enables',
        (tester) async {
      var calls = 0;
      Widget host(bool enabled) => MaterialApp(
            home: Scaffold(
                body: Center(
                    child: entry.value(
                        onPressed: enabled
                            ? () {
                                calls++;
                              }
                            : null))),
          );
      final button = find
          .byWidgetPredicate((widget) =>
              widget is ButtonStyleButton ||
              widget is IconButton ||
              widget is FloatingActionButton)
          .first;
      void expectDisabled() {
        final node = tester.getSemantics(button);
        expect(node.getSemanticsData().hasFlag(SemanticsFlag.hasEnabledState),
            isTrue);
        expect(
            node.getSemanticsData().hasFlag(SemanticsFlag.isEnabled), isFalse);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      }

      await tester.pumpWidget(host(false));
      expectDisabled();
      await tester.tap(button);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
      await tester.pumpWidget(host(true));
      expect(
          tester
              .getSemantics(button)
              .getSemanticsData()
              .hasFlag(SemanticsFlag.isEnabled),
          isTrue);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.pumpWidget(host(false));
      expectDisabled();
      await tester.tap(button);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 1);
      await tester.pumpWidget(host(true));
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(calls, 2);
    });
  }
}
