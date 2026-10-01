import 'dart:developer';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() {
  group('AsyncIconButton', () {
    testWidgets('renders icon correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              log('Button pressed');
            },
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
            },
          ),
        ),
      );

      // Verify initial state.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the button.
      await tester.tap(find.byType(AsyncIconButton));
      // Pump the frame to show loading state.
      await tester.pump();

      // Verify loading state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Icon should still but potentially faded depending on transition.
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Wait for the delay to complete.
      await tester.pump(const Duration(seconds: 1));
      // Pump one more frame to update the UI.
      await tester.pump();

      // Verify final state.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('handles stack transition type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            },
            loadingChild: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      // Both icon and loading indicator should be present in stack mode.
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('handles animatedSwitcher transition type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            },
            loadingChild: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            transitionType: TransitionAnimationType.animatedSwitcher,
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Only loading indicator should be present during switch.
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // These variants are internal and not exposed via constructors in the code.
    // Need to either expose them
    // or use a different testing strategy if they are meant to be used.

    testWidgets('custom builder works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            },
            transitionType: TransitionAnimationType.customBuilder,
            customBuilder: (bool loading, Widget icon, Widget? _) {
              return loading ? const Text('Loading...') : icon;
            },
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('button is disabled during loading', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              wasPressed = true;
              // No async delay, loading state controlled externally.
            },
            loading: true, // Start in loading state.
          ),
        ),
      );

      // Verify loading state is active.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Attempt to tap the button while loading.
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      // Verify onPressed was not called.
      expect(wasPressed, isFalse);
    });

    testWidgets('handles long press correctly', (tester) async {
      var wasLongPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              log('Button pressed');
            },
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

    testWidgets('tooltip is displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              log('Button pressed');
            },
            tooltip: 'Add Item',
          ),
        ),
      );

      expect(find.byTooltip('Add Item'), findsOneWidget);
    });

    // Note: IconButton itself doesn't visually change
    // with isSelected like ToggleButtons.
    // This test verifies the property can be passed.
    testWidgets('isSelected property is handled', (tester) async {
      bool selected = false;
      const selectedIcon = Icon(Icons.check);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, setState) {
              return AsyncIconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => selected = !selected),
                isSelected: WidgetStateProperty.resolveWith<bool>(
                  (_) => selected,
                ),
                selectedIcon: selectedIcon,
              );
            },
          ),
        ),
      );

      // Initially not selected.
      expect(find.byIcon(Icons.add), findsOneWidget);
      // Selected icon not shown by default IconButton.
      expect(
        find.byWidget(selectedIcon),
        findsNothing,
      );

      // Tap to select.
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      // Still shows the main icon,
      //isSelected doesn't swap it automatically for standard IconButton.
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byWidget(selectedIcon), findsNothing);

      // This test mainly confirms the properties exist and don't crash.
      // Visual confirmation of selection state might need specific style checks
      // or testing variants (filled, tonal, outlined) if they behave different.
    });

    testWidgets('prevents multiple taps while async is running',
        (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              count++;
              await Future<void>.delayed(const Duration(milliseconds: 200));
            },
          ),
        ),
      );

      // Two quick taps.
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();
      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      // Let async finish.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(count, 1);
    });

    testWidgets(
        'default loading indicator takes color from style.foregroundColor',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Future<void>.delayed(const Duration(milliseconds: 50));
              },
              style: IconButton.styleFrom(foregroundColor: Colors.green)),
        ),
      );

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      final cpi = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(cpi.color, Colors.green);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('minimumChildOpacity is applied in stack transition',
        (tester) async {
      const minOpacity = 0.3;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
              },
              minimumChildOpacity: minOpacity),
        ),
      );

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      // Find the AnimatedOpacity that wraps the icon (child is AnimatedSize).
      final animatedOpacities =
          tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity));
      final iconOpacityWidget = animatedOpacities.firstWhere(
        (w) => w.child is AnimatedSize,
      );

      expect(iconOpacityWidget.opacity, minOpacity);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();

      // Back to fully visible.
      final iconOpacityAfter = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .firstWhere(
            (w) => w.child is AnimatedSize,
          );
      expect(iconOpacityAfter.opacity, 1.0);
    });

    testWidgets('filled variant shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton.filled(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            },
          ),
        ),
      );

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('filledTonal variant shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            },
          ),
        ),
      );

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('outlined variant shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton.outlined(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            },
          ),
        ),
      );

      await tester.tap(find.byType(AsyncIconButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    test(
        'asserts when customBuilder is '
        'not provided with customBuilder transition', () {
      expect(
        () => AsyncIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            print('Pressed');
          },
          transitionType: TransitionAnimationType.customBuilder,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when using splashFactory together with style', () {
      expect(
        () => AsyncIconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            print('Pressed');
          },
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
          onPressed: () {
            print('Pressed');
          },
          splashRadius: 0,
        ),
        throwsAssertionError,
      );
    });

    test('asserts when splashRadius <= 0 on outlined', () {
      expect(
        () => AsyncIconButton.outlined(
          icon: const Icon(Icons.add),
          onPressed: () {
            print('Pressed');
          },
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
              onPressed: () {
                print('Pressed');
              },
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

    testWidgets('forwards constraints and mouseCursor to IconButton',
        (tester) async {
      const constraints = BoxConstraints.tightFor(width: 48, height: 48);
      const cursor = SystemMouseCursors.click;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                print('Pressed');
              },
              mouseCursor: cursor,
              constraints: constraints),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints, constraints);
      expect(iconButton.mouseCursor, cursor);
    });

    testWidgets('onLongPress does not fire while loading (onPressed disabled)',
        (tester) async {
      var longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                print('Pressed');
              },
              loading: true,
              onLongPress: () {
                longPressed = true;
              }),
        ),
      );

      await tester.longPress(find.byType(AsyncIconButton));
      await tester.pump();

      // IconButton is disabled when onPressed is null (loading),
      // so long press won't fire.
      expect(longPressed, isFalse);
    });
  });
}
