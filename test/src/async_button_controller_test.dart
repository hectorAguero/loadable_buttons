import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../support/async_button_fixture.dart';

void main() {
  // Every constructor forwards the controller to the shared loading owner.
  for (final entry in asyncButtonConstructorBuilders.entries) {
    testWidgets('${entry.key} reflects controller requests and its operation', (
      tester,
    ) async {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      final operation = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        buttonHost(
          entry.value(
            child: const Text('Run'),
            loadingChild: const Text('Busy'),
            controller: controller,
            onPressed: () {
              calls++;

              return operation.future;
            },
          ),
        ),
      );

      controller.loading = true;
      await tester.pumpAndSettle();
      expect(find.text('Busy'), findsOneWidget);
      await tester.tap(nativeButton, warnIfMissed: false);
      expect(calls, 0);

      controller.loading = false;
      await tester.pumpAndSettle();
      expect(find.text('Busy'), findsNothing);
      await tester.tap(nativeButton);
      await tester.pump();
      expect(calls, 1);
      expect(controller.isPending, isTrue);
      expect(controller.isLoading, isTrue);
      expect(controller.loading, isFalse);

      // A manual request toggled during the operation never unlocks it.
      controller
        ..loading = true
        ..loading = false;
      await tester.pumpAndSettle();
      expect(find.text('Busy'), findsOneWidget);
      await tester.tap(nativeButton, warnIfMissed: false);
      expect(calls, 1);

      operation.complete();
      await tester.pumpAndSettle();
      expect(controller.isPending, isFalse);
      expect(find.text('Busy'), findsNothing);
    });
  }

  Widget host({
    required AsyncButtonController? controller,
    required FutureOr<void> Function() onPressed,
    bool text = false,
    AsyncButtonErrorHandler? onError,
  }) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: text
            ? AsyncTextButton(
                controller: controller,
                loadingChild: const Text('Busy'),
                onPressed: onPressed,
                onError: onError,
                child: const Text('Run'),
              )
            : AsyncElevatedButton(
                controller: controller,
                loadingChild: const Text('Busy'),
                onPressed: onPressed,
                onError: onError,
                child: const Text('Run'),
              ),
      ),
    ),
  );

  testWidgets('notifies only for effective controller changes', (
    tester,
  ) async {
    final controller = AsyncButtonController(loading: true);
    addTearDown(controller.dispose);
    final operation = Completer<void>();
    var notifications = 0;
    controller.addListener(() => notifications++);
    await tester.pumpWidget(
      host(controller: controller, onPressed: () => operation.future),
    );
    expect(find.text('Busy'), findsOneWidget);

    controller.loading = true;
    expect(notifications, 0);
    controller.loading = false;
    expect(notifications, 1);
    await tester.pump();

    await tester.tap(nativeButton);
    expect(notifications, 2);
    operation.complete();
    await tester.pumpAndSettle();
    expect(notifications, 3);
    expect(controller.isLoading, isFalse);
  });

  testWidgets('async error recovery stays pending until the handler ends', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    final recovery = Completer<void>();
    await tester.pumpWidget(
      host(
        controller: controller,
        onPressed: () => throw StateError('failed'),
        onError: (_, _) => recovery.future,
      ),
    );

    await tester.tap(nativeButton);
    await tester.pump();
    expect(controller.isPending, isTrue);
    recovery.complete();
    await tester.pumpAndSettle();
    expect(controller.isPending, isFalse);
    expect(find.text('Busy'), findsNothing);
  });

  testWidgets('replacing the controller keeps the pending lock', (
    tester,
  ) async {
    final first = AsyncButtonController();
    final second = AsyncButtonController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final operation = Completer<void>();
    var calls = 0;
    Future<void> onPressed() {
      calls++;

      return operation.future;
    }

    await tester.pumpWidget(host(controller: first, onPressed: onPressed));
    await tester.tap(nativeButton);
    await tester.pump();
    await tester.pumpWidget(host(controller: second, onPressed: onPressed));
    await tester.pumpAndSettle();

    expect(first.isPending, isTrue);
    expect(second.isPending, isFalse);
    expect(find.text('Busy'), findsOneWidget);
    await tester.tap(nativeButton, warnIfMissed: false);
    expect(calls, 1);

    // The new controller can still request loading; the old one cannot.
    first.loading = true;
    second.loading = true;
    second.loading = false;
    operation.complete();
    await tester.pumpAndSettle();
    expect(first.isPending, isFalse);
    expect(find.text('Busy'), findsNothing);

    await tester.pumpWidget(host(controller: null, onPressed: onPressed));
    second.loading = true;
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsNothing);
  });

  testWidgets('a pending operation locks a new button using its controller', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    final operation = Completer<void>();
    var calls = 0;
    Future<void> onPressed() {
      calls++;

      return operation.future;
    }

    await tester.pumpWidget(host(controller: controller, onPressed: onPressed));
    await tester.tap(nativeButton);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    expect(controller.isPending, isTrue);

    await tester.pumpWidget(host(controller: controller, onPressed: onPressed));
    expect(find.text('Busy'), findsOneWidget);
    await tester.tap(nativeButton, warnIfMissed: false);
    expect(calls, 1);

    operation.complete();
    await tester.pumpAndSettle();
    expect(controller.isPending, isFalse);
    expect(find.text('Busy'), findsNothing);
    await tester.tap(nativeButton);
    expect(calls, 2);
  });

  testWidgets('moves between button types in one frame without unlocking', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    final operation = Completer<void>();
    var calls = 0;
    Future<void> onPressed() {
      calls++;

      return operation.future;
    }

    await tester.pumpWidget(host(controller: controller, onPressed: onPressed));
    await tester.tap(nativeButton);
    await tester.pump();
    await tester.pumpWidget(
      host(controller: controller, onPressed: onPressed, text: true),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(AsyncTextButton), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
    await tester.tap(nativeButton, warnIfMissed: false);
    expect(calls, 1);

    operation.complete();
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsNothing);
  });

  testWidgets('never disposes the controller and tolerates owner disposal', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    final operation = Completer<void>();
    await tester.pumpWidget(
      host(controller: controller, onPressed: () => operation.future),
    );
    await tester.tap(nativeButton);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    // Still usable after its button is gone, until the owner disposes it.
    controller.loading = true;
    expect(controller.isLoading, isTrue);
    controller.dispose();
    operation.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports attaching one controller to two buttons', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            AsyncTextButton(
              controller: controller,
              onPressed: () {},
              child: const Text('First'),
            ),
            AsyncTextButton(
              controller: controller,
              onPressed: () {},
              child: const Text('Second'),
            ),
          ],
        ),
      ),
    );

    expect(
      tester.takeException(),
      isA<FlutterError>().having(
        (error) => error.message,
        'message',
        contains('one button at a time'),
      ),
    );
    // Reporting leaves both buttons mounted and the tree consistent.
    expect(find.byType(AsyncTextButton), findsNWidgets(2));
  });
}
