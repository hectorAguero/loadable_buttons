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

  testWidgets('hands off during an animated switch while both are shown', (
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

    Widget switcher({required bool text}) => MaterialApp(
      home: Center(
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: text
              ? AsyncTextButton(
                  key: const ValueKey('text'),
                  controller: controller,
                  loadingChild: const Text('Text busy'),
                  onPressed: onPressed,
                  child: const Text('Text run'),
                )
              : AsyncElevatedButton(
                  key: const ValueKey('elevated'),
                  controller: controller,
                  loadingChild: const Text('Elevated busy'),
                  onPressed: onPressed,
                  child: const Text('Elevated run'),
                ),
        ),
      ),
    );

    await tester.pumpWidget(switcher(text: false));
    await tester.tap(find.text('Elevated run'));
    await tester.pump();
    await tester.pumpWidget(switcher(text: true));
    await tester.pump(const Duration(milliseconds: 500));

    // Both buttons are mounted mid-transition and share the pending lock.
    expect(tester.takeException(), isNull);
    expect(find.text('Elevated busy'), findsOneWidget);
    expect(find.text('Text busy'), findsOneWidget);
    await tester.tap(find.text('Text busy'), warnIfMissed: false);
    expect(calls, 1);

    await tester.pumpAndSettle();
    operation.complete();
    await tester.pumpAndSettle();
    expect(find.text('Text run'), findsOneWidget);
    await tester.tap(find.text('Text run'));
    expect(calls, 2);
  });

  testWidgets('skips rebuilds when effective controller loading is unchanged', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    final operation = Completer<void>();
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncTextButton(
          controller: controller,
          transitionType: TransitionAnimationType.customBuilder,
          customBuilder: (loading, child, _) {
            builds++;

            return loading ? const Text('Busy') : child;
          },
          onPressed: () => operation.future,
          child: const Text('Run'),
        ),
      ),
    );
    await tester.tap(find.text('Run'));
    await tester.pump();
    final pendingBuilds = builds;

    // isLoading stays true, so neither notification rebuilds the button.
    controller
      ..loading = true
      ..loading = false;
    await tester.pump();
    expect(builds, pendingBuilds);

    operation.complete();
    await tester.pump();
    expect(builds, greaterThan(pendingBuilds));
    expect(find.text('Run'), findsOneWidget);
  });

  testWidgets('reads the current state of a newly supplied controller', (
    tester,
  ) async {
    final idle = AsyncButtonController();
    final requested = AsyncButtonController(loading: true);
    addTearDown(idle.dispose);
    addTearDown(requested.dispose);
    await tester.pumpWidget(host(controller: idle, onPressed: () {}));
    expect(find.text('Busy'), findsNothing);

    await tester.pumpWidget(host(controller: requested, onPressed: () {}));
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsOneWidget);
  });

  testWidgets('keeps controller state when reparented with a GlobalKey', (
    tester,
  ) async {
    final controller = AsyncButtonController(loading: true);
    addTearDown(controller.dispose);
    final buttonKey = GlobalKey();
    Widget layout({required bool wrapped}) {
      final button = AsyncElevatedButton(
        key: buttonKey,
        controller: controller,
        loadingChild: const Text('Busy'),
        onPressed: () {},
        child: const Text('Run'),
      );

      return MaterialApp(
        home: Center(
          child: wrapped ? Card(child: button) : button,
        ),
      );
    }

    await tester.pumpWidget(layout(wrapped: false));
    await tester.pumpWidget(layout(wrapped: true));
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsOneWidget);

    controller.loading = false;
    await tester.pumpAndSettle();
    expect(find.text('Busy'), findsNothing);
  });
}
