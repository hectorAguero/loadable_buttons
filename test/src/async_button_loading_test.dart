import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/async_button_fixture.dart';

void main() {
  for (final entry in asyncButtonBuilders.entries) {
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

        Widget host(bool loading) => buttonHost(
          entry.value(
            child: const Text('Run'),
            loading: loading,
            onPressed: onPressed,
          ),
        );

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

        Widget host(bool loading) => buttonHost(
          entry.value(
            child: const Text('Run'),
            loading: loading,
            onPressed: onPressed,
          ),
        );

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
