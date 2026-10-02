import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../support/async_button_fixture.dart';

void main() {
  // Constructor forwarding is a distinct risk from the shared error policy.
  for (final entry in asyncButtonErrorBuilders.entries) {
    for (final asynchronous in [false, true]) {
      final failureName = asynchronous ? 'failed Future' : 'synchronous throw';
      testWidgets('${entry.key} consumes $failureName once and allows retry', (
        tester,
      ) async {
        final failure = StateError('Operation failed');
        final originalTrace = StackTrace.fromString('original operation trace');
        final handled = <(Object, StackTrace)>[];
        final uncaught = <Object>[];
        var calls = 0;
        await runZonedGuarded(() async {
          final pending = Completer<void>();
          await tester.pumpWidget(
            buttonHost(
              entry.value(
                child: const Text('Run'),
                loadingChild: const Text('Busy'),
                onPressed: () {
                  calls++;
                  if (calls > 1) return Future<void>.value();
                  if (asynchronous) return pending.future;
                  Error.throwWithStackTrace(failure, originalTrace);
                },
                onError: (error, trace) => handled.add((error, trace)),
              ),
            ),
          );
          await tester.tap(materialButton);
          await tester.pump();
          if (asynchronous) pending.completeError(failure, originalTrace);
          await tester.pumpAndSettle();
        }, (error, _) => uncaught.add(error));
        expect(handled, hasLength(1));
        expect(handled.single.$1, same(failure));
        expect(handled.single.$2.toString(), originalTrace.toString());
        expect(uncaught, isEmpty);
        expect(find.bySemanticsLabel('Run'), findsOneWidget);
        expect(find.bySemanticsLabel('Busy'), findsNothing);
        await tester.tap(materialButton);
        await tester.pumpAndSettle();
        expect(calls, 2);
        expect(handled, hasLength(1));
        expect(uncaught, isEmpty);
      });
    }
  }

  // All constructors use the same policy owner; exercise its edge cases once.
  testWidgets(
    'async recovery retains the lock and external loading ownership',
    (
      tester,
    ) async {
      final operation = Completer<void>();
      final recovery = Completer<void>();
      var calls = 0;
      var handlerCalls = 0;
      Widget host(bool loading) => buttonHost(
        AsyncElevatedButton(
          loading: loading,
          loadingChild: const Text('Busy'),
          onPressed: () {
            calls++;

            return calls == 1 ? operation.future : null;
          },
          onError: (_, _) {
            handlerCalls++;

            return recovery.future;
          },
          child: const Text('Run'),
        ),
      );
      await tester.pumpWidget(host(false));
      final activate = tester.widget<ElevatedButton>(materialButton).onPressed;
      if (activate == null) throw StateError('Missing activation callback');
      // Stale native callbacks must also honor the synchronous reentry lock.
      activate();
      activate();
      await tester.pump();
      operation.completeError(StateError('Operation failed'));
      await tester.pumpAndSettle();
      activate();
      await tester.tap(materialButton);
      expect(calls, 1);
      expect(handlerCalls, 1);
      expect(find.bySemanticsLabel('Busy'), findsOneWidget);

      await tester.pumpWidget(host(true));
      await tester.pumpWidget(host(false));
      activate();
      expect(calls, 1);
      expect(find.bySemanticsLabel('Busy'), findsOneWidget);

      await tester.pumpWidget(host(true));
      recovery.complete();
      await tester.pumpAndSettle();
      activate();
      expect(calls, 1);
      expect(find.bySemanticsLabel('Busy'), findsOneWidget);

      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      await tester.tap(materialButton);
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(handlerCalls, 1);
      expect(find.bySemanticsLabel('Run'), findsOneWidget);
      expect(find.bySemanticsLabel('Busy'), findsNothing);
    },
  );

  for (final asynchronous in [false, true]) {
    final failureName = asynchronous ? 'failed Future' : 'synchronous throw';
    testWidgets(
      'handler $failureName propagates its own trace and allows retry',
      (
        tester,
      ) async {
        final failure = StateError('Handler failed');
        final handlerTrace = StackTrace.fromString('original handler trace');
        final uncaught = <(Object, StackTrace)>[];
        var calls = 0;
        var handlerCalls = 0;
        await runZonedGuarded(() async {
          final recovery = Completer<void>();
          await tester.pumpWidget(
            buttonHost(
              AsyncElevatedButton(
                loadingChild: const Text('Busy'),
                onPressed: () {
                  calls++;
                  if (calls == 1) throw StateError('Operation failed');
                },
                onError: (_, _) {
                  handlerCalls++;
                  if (asynchronous) return recovery.future;
                  Error.throwWithStackTrace(failure, handlerTrace);
                },
                child: const Text('Run'),
              ),
            ),
          );
          await tester.tap(materialButton);
          await tester.pump();
          if (asynchronous) recovery.completeError(failure, handlerTrace);
          await tester.pumpAndSettle();
        }, (error, trace) => uncaught.add((error, trace)));
        expect(uncaught, hasLength(1));
        expect(uncaught.single.$1, same(failure));
        expect(uncaught.single.$2.toString(), handlerTrace.toString());
        expect(handlerCalls, 1);
        expect(find.bySemanticsLabel('Busy'), findsNothing);
        await tester.tap(materialButton);
        await tester.pumpAndSettle();
        expect(calls, 2);
        expect(handlerCalls, 1);
        expect(uncaught, hasLength(1));
      },
    );
  }

  testWidgets('rebuilds retain the handler captured by each activation', (
    tester,
  ) async {
    final operation = Completer<void>();
    var originalCalls = 0;
    var replacementCalls = 0;
    var callbackCalls = 0;
    Widget host(AsyncButtonErrorHandler handler) => buttonHost(
      AsyncElevatedButton(
        loadingChild: const Text('Busy'),
        onPressed: () {
          callbackCalls++;
          if (callbackCalls == 1) return operation.future;
          throw StateError('Retry failed');
        },
        onError: handler,
        child: const Text('Run'),
      ),
    );
    await tester.pumpWidget(host((_, _) => originalCalls++));
    await tester.tap(materialButton);
    await tester.pumpWidget(host((_, _) => replacementCalls++));
    operation.completeError(StateError('Operation failed'));
    await tester.pumpAndSettle();
    expect(originalCalls, 1);
    expect(replacementCalls, 0);
    await tester.tap(materialButton);
    await tester.pumpAndSettle();
    expect(callbackCalls, 2);
    expect(originalCalls, 1);
    expect(replacementCalls, 1);
  });

  for (final hasHandler in [false, true]) {
    testWidgets(
      'disposal preserves ${hasHandler ? 'handling' : 'propagation'}',
      (
        tester,
      ) async {
        final failure = StateError('Operation failed after disposal');
        final originalTrace = StackTrace.fromString('original disposed trace');
        final handled = <(Object, StackTrace)>[];
        final uncaught = <(Object, StackTrace)>[];
        await runZonedGuarded(() async {
          final operation = Completer<void>();
          await tester.pumpWidget(
            buttonHost(
              AsyncElevatedButton(
                onPressed: () => operation.future,
                onError: hasHandler
                    ? (error, trace) => handled.add((error, trace))
                    : null,
                child: const Text('Run'),
              ),
            ),
          );
          await tester.tap(materialButton);
          await tester.pumpWidget(buttonHost(const Text('Removed')));
          operation.completeError(failure, originalTrace);
          await tester.pump();
        }, (error, trace) => uncaught.add((error, trace)));
        final reported = hasHandler ? handled : uncaught;
        expect(reported, hasLength(1));
        expect(reported.single.$1, same(failure));
        expect(reported.single.$2.toString(), originalTrace.toString());
        expect(hasHandler ? uncaught : handled, isEmpty);
        expect(tester.takeException(), isNull);
        expect(find.text('Removed'), findsOneWidget);
      },
    );
  }

  for (final handlerFails in [false, true]) {
    testWidgets(
      'disposal during async recovery preserves its result ($handlerFails)',
      (
        tester,
      ) async {
        final handlerFailure = StateError('Recovery failed after disposal');
        final handlerTrace = StackTrace.fromString(
          'original disposed handler trace',
        );
        final uncaught = <(Object, StackTrace)>[];
        var handlerCalls = 0;
        var handlerCompletions = 0;
        await runZonedGuarded(() async {
          final recovery = Completer<void>();
          await tester.pumpWidget(
            buttonHost(
              AsyncElevatedButton(
                loadingChild: const Text('Busy'),
                onPressed: () => throw StateError('Operation failed'),
                onError: (_, _) async {
                  handlerCalls++;
                  await recovery.future;
                  handlerCompletions++;
                },
                child: const Text('Run'),
              ),
            ),
          );
          await tester.tap(materialButton);
          await tester.pumpAndSettle();
          await tester.pumpWidget(buttonHost(const Text('Removed')));
          if (handlerFails) {
            recovery.completeError(handlerFailure, handlerTrace);
          } else {
            recovery.complete();
          }
          await tester.pump();
        }, (error, trace) => uncaught.add((error, trace)));
        expect(handlerCalls, 1);
        expect(handlerCompletions, handlerFails ? 0 : 1);
        if (handlerFails) {
          expect(uncaught, hasLength(1));
          expect(uncaught.single.$1, same(handlerFailure));
          expect(uncaught.single.$2.toString(), handlerTrace.toString());
        } else {
          expect(uncaught, isEmpty);
        }
        expect(tester.takeException(), isNull);
        expect(find.text('Removed'), findsOneWidget);
      },
    );
  }
}
