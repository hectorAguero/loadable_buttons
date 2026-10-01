import 'dart:async';
import 'dart:ui' show PointerDeviceKind, SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

typedef _IconButtonBuilder =
    AsyncIconButton Function({
      required Widget icon,
      required FutureOr<void> Function()? onPressed,
      WidgetStateProperty<bool>? isSelected,
      Widget? selectedIcon,
      ButtonStyle? style,
      bool loading,
      Widget? loadingChild,
      TransitionAnimationType transitionType,
      Widget Function(bool loading, Widget icon, Widget? loadingChild)?
      customBuilder,
    });

void main() {
  group('AsyncIconButton', () {
    testWidgets('default indicator covers selected content and restores it', (
      tester,
    ) async {
      final pending = Completer<void>();
      await tester.pumpWidget(
        _host(
          AsyncIconButton(
            icon: const Icon(Icons.add),
            selectedIcon: const Icon(Icons.check, semanticLabel: 'Selected'),
            isSelected: const WidgetStatePropertyAll(true),
            onPressed: () => pending.future,
          ),
        ),
      );
      expect(find.bySemanticsLabel('Selected'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Selected'), findsNothing);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel('Selected'), findsOneWidget);
    });

    testWidgets('switcher completes both fades around a pending operation', (
      tester,
    ) async {
      final pending = Completer<void>();
      const duration = Duration(milliseconds: 200);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncIconButton(
                icon: const Icon(Icons.add),
                onPressed: () => pending.future,
                transitionType: TransitionAnimationType.animatedSwitcher,
                animationDuration: duration,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AsyncIconButton));
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

    testWidgets('handles long press correctly', (tester) async {
      var wasLongPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            onLongPress: () {
              wasLongPressed = true;
            },
          ),
        ),
      );

      await tester.longPress(find.byType(AsyncIconButton));
      await tester.pump();

      expect(wasLongPressed, isTrue);
    });

    testWidgets('long press displays the configured tooltip', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            tooltip: 'Add Item',
          ),
        ),
      );

      expect(find.text('Add Item'), findsNothing);
      await tester.longPress(find.byType(AsyncIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Add Item'), findsOneWidget);
    });

    final variants = <String, _IconButtonBuilder>{
      'standard': AsyncIconButton.new,
      'filled': AsyncIconButton.filled,
      'filledTonal': AsyncIconButton.filledTonal,
      'outlined': AsyncIconButton.outlined,
    };

    for (final variant in variants.entries) {
      group('${variant.key} selection', () {
        testWidgets('toggles icons, resolved color, and selection semantics', (
          tester,
        ) async {
          var selected = false;

          await tester.pumpWidget(
            _host(
              StatefulBuilder(
                builder: (_, setState) {
                  return variant.value(
                    icon: const Icon(Icons.add),
                    selectedIcon: const Icon(Icons.check),
                    isSelected: WidgetStateProperty.resolveWith(
                      (_) => selected,
                    ),
                    onPressed: () => setState(() => selected = !selected),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) =>
                            states.contains(WidgetState.selected)
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          );

          void expectSelection(bool selected) {
            final icon = find.byIcon(selected ? Icons.check : Icons.add);
            expect(icon, findsOneWidget);
            expect(
              find.byIcon(selected ? Icons.add : Icons.check),
              findsNothing,
            );
            expect(
              IconTheme.of(tester.element(icon)).color,
              selected ? Colors.green : Colors.red,
            );
            expect(
              tester
                  .getSemantics(find.byType(IconButton))
                  .getSemanticsData()
                  // flagsCollection is unavailable on Flutter 3.29.
                  // ignore: deprecated_member_use
                  .hasFlag(SemanticsFlag.isSelected),
              selected,
            );
          }

          expectSelection(false);
          await tester.tap(find.byType(AsyncIconButton));
          await tester.pumpAndSettle();
          expectSelection(true);
          await tester.tap(find.byType(AsyncIconButton));
          await tester.pumpAndSettle();
          expectSelection(false);
        });

        testWidgets(
          'keeps the original icon without a selected icon or state',
          (tester) async {
            Widget host(bool? selected, {Widget? selectedIcon}) => _host(
              variant.value(
                icon: const Icon(Icons.add),
                selectedIcon: selectedIcon,
                isSelected:
                    selected == null ? null : WidgetStatePropertyAll(selected),
                onPressed: () {},
              ),
            );

            await tester.pumpWidget(host(true));
            expect(find.byIcon(Icons.add), findsOneWidget);
            expect(
              tester
                  .getSemantics(find.byType(IconButton))
                  .getSemanticsData()
                  // flagsCollection is unavailable on Flutter 3.29.
                  // ignore: deprecated_member_use
                  .hasFlag(SemanticsFlag.isSelected),
              isTrue,
            );

            await tester.pumpWidget(host(false));
            expect(find.byIcon(Icons.add), findsOneWidget);
            expect(
              tester
                  .getSemantics(find.byType(IconButton))
                  .getSemanticsData()
                  // flagsCollection is unavailable on Flutter 3.29.
                  // ignore: deprecated_member_use
                  .hasFlag(SemanticsFlag.isSelected),
              isFalse,
            );

            await tester.pumpWidget(
              host(null, selectedIcon: const Icon(Icons.check)),
            );
            expect(find.byIcon(Icons.add), findsOneWidget);
            expect(find.byIcon(Icons.check), findsNothing);
          },
        );

        testWidgets('resolves selection for disabled and loading states', (
          tester,
        ) async {
          Widget host({bool enabled = true, bool loading = false}) => _host(
            variant.value(
              icon: const Icon(Icons.add),
              selectedIcon: const Icon(Icons.check),
              isSelected: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled),
              ),
              onPressed: enabled ? () {} : null,
              loading: loading,
              loadingChild: const Text('Loading'),
            ),
          );

          await tester.pumpWidget(host());
          expect(find.byIcon(Icons.add), findsOneWidget);
          await tester.pumpWidget(host(enabled: false));
          expect(find.byIcon(Icons.check), findsOneWidget);

          await tester.pumpWidget(host(loading: true));
          await tester.pumpAndSettle();
          expect(find.text('Loading'), findsOneWidget);
          expect(
            tester
                .getSemantics(find.byType(IconButton))
                .getSemanticsData()
                // flagsCollection is unavailable on Flutter 3.29.
                // ignore: deprecated_member_use
                .hasFlag(SemanticsFlag.isSelected),
            isTrue,
          );

          await tester.pumpWidget(host());
          await tester.pumpAndSettle();
          expect(find.text('Loading'), findsNothing);
          expect(find.byIcon(Icons.check), findsNothing);
          expect(find.byIcon(Icons.add), findsOneWidget);
        });

        for (final transition in TransitionAnimationType.values) {
          testWidgets(
            '${transition.name} keeps loading above selected content',
            (tester) async {
              final pending = Completer<void>();
              Widget host({required bool selected, bool loading = false}) =>
                  _host(
                    variant.value(
                      icon: const Icon(Icons.add, semanticLabel: 'Unselected'),
                      selectedIcon: const Icon(
                        Icons.check,
                        semanticLabel: 'Selected',
                      ),
                      isSelected: WidgetStatePropertyAll(selected),
                      onPressed: () => pending.future,
                      loading: loading,
                      transitionType: transition,
                      loadingChild: const Text('Loading'),
                      customBuilder:
                          (loading, icon, loadingChild) =>
                              loading ? loadingChild ?? icon : icon,
                    ),
                  );
              void expectLoading() {
                expect(find.text('Loading'), findsOneWidget);
                expect(find.bySemanticsLabel('Selected'), findsNothing);
                expect(find.bySemanticsLabel('Unselected'), findsNothing);
              }

              await tester.pumpWidget(host(selected: true));
              expect(find.bySemanticsLabel('Selected'), findsOneWidget);
              await tester.pumpWidget(host(selected: true, loading: true));
              await tester.pumpAndSettle();
              expectLoading();
              await tester.pumpWidget(host(selected: true));
              await tester.pumpAndSettle();
              expect(find.text('Loading'), findsNothing);
              expect(find.bySemanticsLabel('Selected'), findsOneWidget);

              await tester.tap(find.byType(AsyncIconButton));
              await tester.pumpAndSettle();
              expectLoading();
              await tester.pumpWidget(host(selected: false));
              await tester.pumpAndSettle();
              expectLoading();

              pending.complete();
              await tester.pumpAndSettle();
              expect(find.text('Loading'), findsNothing);
              expect(find.byIcon(Icons.check), findsNothing);
              expect(find.bySemanticsLabel('Unselected'), findsOneWidget);
            },
          );
        }
      });
    }

    testWidgets(
      'default loading indicator takes color from style.foregroundColor',
      (tester) async {
        final pending = Completer<void>();
        await tester.pumpWidget(
          MaterialApp(
            home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () => pending.future,
              style: IconButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
        );

        await tester.tap(find.byType(AsyncIconButton));
        await tester.pump();

        final cpi = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(cpi.color, Colors.green);

        pending.complete();
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    test('asserts when customBuilder is '
        'not provided with customBuilder transition', () {
      expect(
        () => AsyncIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {},
          transitionType: TransitionAnimationType.customBuilder,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when using splashFactory together with style', () {
      expect(
        () => AsyncIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {},
          style: IconButton.styleFrom(),
          splashFactory: NoSplash.splashFactory,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when splashRadius <= 0 on filledTonal', () {
      expect(
        () => AsyncIconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: () {},
          splashRadius: 0,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when splashRadius <= 0 on outlined', () {
      expect(
        () => AsyncIconButton.outlined(
          icon: const Icon(Icons.add),
          onPressed: () {},
          splashRadius: 0,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('onHover callback fires on mouse enter/exit', (tester) async {
      bool? lastHover;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              onHover: (v) => lastHover = v,
            ),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byType(AsyncIconButton)));
      await tester.pump();

      expect(lastHover, isTrue);

      await gesture.moveTo(Offset.zero);
      await tester.pump();

      expect(lastHover, isFalse);
    });

    testWidgets('renders constrained bounds and selects the requested cursor', (
      tester,
    ) async {
      const constraints = BoxConstraints.tightFor(width: 80, height: 64);
      const cursor = SystemMouseCursors.forbidden;

      await tester.pumpWidget(
        _host(
          AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
            mouseCursor: cursor,
            constraints: constraints,
          ),
        ),
      );

      final button = find.byType(AsyncIconButton);
      expect(tester.getSize(button), const Size(80, 64));
      final mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(button));
      await tester.pump();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        cursor,
      );
    });

    testWidgets(
      'onLongPress does not fire while loading (onPressed disabled)',
      (tester) async {
        var longPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              loading: true,
              onLongPress: () {
                longPressed = true;
              },
            ),
          ),
        );

        await tester.longPress(find.byType(AsyncIconButton));
        await tester.pump();

        // IconButton is disabled when onPressed is null (loading),
        // so long press won't fire.
        expect(longPressed, isFalse);
      },
    );
  });
}

Widget _host(Widget button) => MaterialApp(
  theme: ThemeData(useMaterial3: true),
  home: Scaffold(body: Center(child: button)),
);
