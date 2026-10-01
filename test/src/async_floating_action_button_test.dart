import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() {
  group('AsyncFloatingActionButton', () {
    testWidgets('switcher completes both fades around a pending operation', (
      tester,
    ) async {
      final pending = Completer<void>();
      const duration = Duration(milliseconds: 200);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => pending.future,
                transitionType: TransitionAnimationType.animatedSwitcher,
                animationDuration: duration,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();
      // Start the newly mounted transition before advancing its clock.
      await tester.pump();
      // Advance past the duration so the outgoing controller completes.
      await tester.pump(duration + const Duration(milliseconds: 1));
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete();
      await tester.pump();
      // Start the newly mounted transition before advancing its clock.
      await tester.pump();
      // Advance past the duration so the outgoing controller completes.
      await tester.pump(duration + const Duration(milliseconds: 1));
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    test(
      'asserts when customBuilder is not provided with custom transition',
      () {
        expect(
          () => AsyncFloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {},
            transitionType: TransitionAnimationType.customBuilder,
          ),
          throwsAssertionError,
        );
      },
    );

    testWidgets('default loading indicator color uses foregroundColor', (
      tester,
    ) async {
      final pending = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => pending.future,
                foregroundColor: Colors.green,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(cpi.color, Colors.green);

      pending.complete();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
