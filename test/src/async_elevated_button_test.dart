import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart'; // adjust import based on your package name

void main() {
  group('AsyncElevatedButton', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            onPressed: () async {},
            child: const Text('Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when pressed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            onPressed: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: const Text('Test Button'),
          ),
        ),
      );

      // Verify initial state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(AsyncElevatedButton));
      // Pump the frame to show loading state
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the delay to complete
      await tester.pump(const Duration(seconds: 1));
      // Pump one more frame to update the UI
      await tester.pump();

      // Verify final state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('handles different transition types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            onPressed: () async {},
            transitionType: TransitionAnimationType.animatedSwitcher,

            loadingChild: const CircularProgressIndicator(),
            child: const Text('Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('icon variant renders correctly', (tester) async {
      const ColorScheme colorScheme = ColorScheme.light();
      final ThemeData theme = ThemeData.from(colorScheme: colorScheme);
      final Key iconButtonKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: AsyncElevatedButton.icon(
            key: iconButtonKey,
            onPressed: () async {},
            icon: const Icon(Icons.add),
            label: const Text('label'),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('label'), findsOneWidget);
    });

    testWidgets('custom builder works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            onPressed: () async {},
            transitionType: TransitionAnimationType.customBuilder,
            customBuilder: ({
              required bool loading,
              required Widget child,
              Widget? loadingChild,
            }) {
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
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            loading: true,
            onPressed: () async {
              wasPressed = true;
            },
            child: const Text('Test Button'),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncElevatedButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('handles long press correctly', (tester) async {
      bool wasLongPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AsyncElevatedButton(
            onPressed: () async {},
            onLongPress: () {
              wasLongPressed = true;
            },
            child: const Text('Test Button'),
          ),
        ),
      );

      await tester.longPress(find.byType(AsyncElevatedButton));
      await tester.pump();

      expect(wasLongPressed, isTrue);
    });
  });
}
