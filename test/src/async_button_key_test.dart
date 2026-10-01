import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _ButtonBuilder = StatefulWidget Function({
  required Key key,
  required Future<void> Function() onPressed,
});

void main() {
  final builders = <String, _ButtonBuilder>{
    'Filled': ({required key, required onPressed}) => AsyncFilledButton(
          key: key,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Filled.icon': ({required key, required onPressed}) =>
        AsyncFilledButton.icon(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Filled.tonal': ({required key, required onPressed}) =>
        AsyncFilledButton.tonal(
          key: key,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Filled.tonalIcon': ({required key, required onPressed}) =>
        AsyncFilledButton.tonalIcon(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Outlined': ({required key, required onPressed}) => AsyncOutlinedButton(
          key: key,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Outlined.icon': ({required key, required onPressed}) =>
        AsyncOutlinedButton.icon(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Text': ({required key, required onPressed}) => AsyncTextButton(
          key: key,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Text.icon': ({required key, required onPressed}) => AsyncTextButton.icon(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
    'Icon': ({required key, required onPressed}) => AsyncIconButton(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.filled': ({required key, required onPressed}) =>
        AsyncIconButton.filled(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.filledTonal': ({required key, required onPressed}) =>
        AsyncIconButton.filledTonal(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Icon.outlined': ({required key, required onPressed}) =>
        AsyncIconButton.outlined(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
        ),
    'Floating action': ({required key, required onPressed}) =>
        AsyncFloatingActionButton(
          key: key,
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.small': ({required key, required onPressed}) =>
        AsyncFloatingActionButton.small(
          key: key,
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.large': ({required key, required onPressed}) =>
        AsyncFloatingActionButton.large(
          key: key,
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
    'Floating action.extended': ({required key, required onPressed}) =>
        AsyncFloatingActionButton.extended(
          key: key,
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Run'),
        ),
  };

  for (final entry in builders.entries) {
    testWidgets('${entry.key} GlobalKey retains wrapper state while loading', (
      tester,
    ) async {
      final key = GlobalKey<State<StatefulWidget>>();
      final pending = Completer<void>();
      var calls = 0;
      Future<void> onPressed() {
        calls++;
        return pending.future;
      }

      final button = entry.value(key: key, onPressed: onPressed);
      await tester.pumpWidget(_host(button));
      expect(tester.takeException(), isNull);
      expect(key.currentWidget, same(button));
      final state = key.currentState;
      expect(state, isNotNull);

      await tester.tap(find.byKey(key));
      await tester.pump();
      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final rebuilt = entry.value(key: key, onPressed: onPressed);
      await tester.pumpWidget(_host(rebuilt));
      expect(tester.takeException(), isNull);
      expect(key.currentWidget, same(rebuilt));
      expect(key.currentState, same(state));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byKey(key));
      expect(calls, 1);

      pending.complete();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.byKey(key));
      await tester.pump();
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _host(Widget button) => MaterialApp(
      home: Scaffold(body: Center(child: button)),
    );
