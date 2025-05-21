import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() {
  group('AsyncTextButton', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            child: const Text('Test Button'),
            onPressed: () {
              log('Button pressed');
            },
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            child: const Text('Test Button'),
            onPressed: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
            },
          ),
        ),
      );

      // Verify initial state.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);

      // Tap the button.
      await tester.tap(find.byType(AsyncTextButton));
      // Pump the frame to show loading state.
      await tester.pump();

      // Verify loading state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the delay to complete.
      await tester.pump(const Duration(seconds: 1));
      // Pump one more frame to update the UI.
      await tester.pump();

      // Verify final state.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('handles different transition types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            onPressed: () {
              log('Button pressed');
            },
            loadingChild: const CircularProgressIndicator(),
            transitionType: TransitionAnimationType.animatedSwitcher,
            child: const Text('Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('icon variant renders correctly', (tester) async {
      const colorScheme = ColorScheme.light();
      final theme = ThemeData.from(colorScheme: colorScheme);
      final Key iconButtonKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton.icon(
            onPressed: () {
              log('Button pressed');
            },
            label: const Text('label'),
            key: iconButtonKey,
            icon: const Icon(Icons.add),
          ),
          theme: theme,
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('custom builder works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            onPressed: () {
              log('Button pressed');
            },
            transitionType: TransitionAnimationType.customBuilder,
            customBuilder: (bool loading, Widget child, Widget? loadingChild) {
              return loading
                  ? (loadingChild ?? const CircularProgressIndicator())
                  : child;
            },
            child: const Text('Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('button is disabled during loading', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            onPressed: () {
              wasPressed = true;
            },
            loading: true,
            child: const Text('Test Button'),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncTextButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('handles long press correctly', (tester) async {
      var wasLongPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncTextButton(
            child: const Text('Test Button'),
            onPressed: () {
              log('Button pressed');
            },
            onLongPress: () {
              wasLongPressed = true;
            },
          ),
        ),
      );

      await tester.longPress(find.byType(AsyncTextButton));
      await tester.pump();

      expect(wasLongPressed, isTrue);
    });
  });
}
