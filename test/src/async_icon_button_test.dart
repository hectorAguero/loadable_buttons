import 'dart:developer';

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
            transitionType: TransitionAnimationType.stack,
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

    // These variants are internal and not exposed via constructors in the provided code.
    // Need to either expose them or use a different testing strategy if they are meant to be used.

    testWidgets('custom builder works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            },
            transitionType: TransitionAnimationType.customBuilder,
            customBuilder: (bool loading, Widget icon, Widget? loadingChild) {
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

    // Note: IconButton itself doesn't visually change with isSelected like ToggleButtons.
    // This test verifies the property can be passed.
    testWidgets('isSelected property is handled', (tester) async {
      bool selected = false;
      final selectedIcon = Icon(Icons.check);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return AsyncIconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => selected = !selected),
                isSelected: WidgetStateProperty.resolveWith<bool>(
                  (states) => selected,
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
      // or testing the variants (filled, tonal, outlined) if they behave differently.
    });
  });
}
