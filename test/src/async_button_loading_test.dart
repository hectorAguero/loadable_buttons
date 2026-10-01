import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _ButtonBuilder = Widget Function({
  required bool loading,
  required Future<void> Function() onPressed,
});

void main() {
  final builders = <String, _ButtonBuilder>{
    'Elevated': ({required loading, required onPressed}) => AsyncElevatedButton(
          loading: loading,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Filled': ({required loading, required onPressed}) => AsyncFilledButton(
          loading: loading,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Outlined': ({required loading, required onPressed}) => AsyncOutlinedButton(
          loading: loading,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Text': ({required loading, required onPressed}) => AsyncTextButton(
          loading: loading,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
    'Icon': ({required loading, required onPressed}) => AsyncIconButton(
          loading: loading,
          onPressed: onPressed,
          icon: const Text('Run'),
        ),
    'Floating action': ({required loading, required onPressed}) =>
        AsyncFloatingActionButton(
          loading: loading,
          onPressed: onPressed,
          child: const Text('Run'),
        ),
  };

  for (final entry in builders.entries) {
    group('${entry.key} loading ownership', () {
      testWidgets('external updates keep a pending operation locked', (
        tester,
      ) async {
        final pending = Completer<void>();
        var calls = 0;
        Future<void> onPressed() {
          calls++;
          return pending.future;
        }

        Widget host(bool loading) =>
            _host(entry.value(loading: loading, onPressed: onPressed));

        await tester.pumpWidget(host(false));
        final position = tester.getCenter(find.text('Run'));
        await tester.tapAt(position);
        // A second activation before rebuilding must also be ignored.
        await tester.tapAt(position);
        expect(calls, 1);

        await tester.pumpWidget(host(true));
        await tester.pumpWidget(host(false));
        await tester.tapAt(position);
        expect(calls, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        pending.complete();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tapAt(position);
        await tester.pump();
        expect(calls, 2);
      });

      testWidgets('completion keeps external loading active', (tester) async {
        final pending = Completer<void>();
        var calls = 0;
        Future<void> onPressed() {
          calls++;
          return pending.future;
        }

        Widget host(bool loading) =>
            _host(entry.value(loading: loading, onPressed: onPressed));

        await tester.pumpWidget(host(false));
        final position = tester.getCenter(find.text('Run'));
        await tester.tapAt(position);
        await tester.pumpWidget(host(true));

        pending.complete();
        await tester.pump();
        await tester.tapAt(position);
        expect(calls, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpWidget(host(false));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tapAt(position);
        await tester.pump();
        expect(calls, 2);
      });
    });
  }
}

Widget _host(Widget button) => MaterialApp(
      home: Scaffold(body: Center(child: button)),
    );
