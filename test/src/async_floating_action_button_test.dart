import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() {
  group('AsyncFloatingActionButton', () {
    testWidgets('renders child icon correctly (regular)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: Icon(Icons.add),
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when pressed (regular)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('prevents multiple taps while async is running',
        (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  count++;
                  await Future<void>.delayed(const Duration(milliseconds: 200));
                },
              ),
            ),
          ),
        ),
      );

      // Two quick taps.
      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(count, 1);
    });

    testWidgets('handles animatedSwitcher transition type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
                transitionType: TransitionAnimationType.animatedSwitcher,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byType(AsyncFloatingActionButton));
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

    testWidgets('custom builder works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
                transitionType: TransitionAnimationType.customBuilder,
                customBuilder: (bool loading, Widget child, Widget? _) {
                  return loading ? const Text('Loading...') : child;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    test('asserts when customBuilder is not provided with custom transition',
        () {
      expect(
        () => AsyncFloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print('Pressed');
          },
          transitionType: TransitionAnimationType.customBuilder,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('button is disabled during external loading', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  wasPressed = true;
                },
                loading: true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('default loading indicator color uses foregroundColor',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 50));
                },
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

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('minimumChildOpacity is applied in stack transition',
        (tester) async {
      const minOpacity = 0.3;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
                minimumChildOpacity: minOpacity,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      final iconOpacityWidget = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .firstWhere((w) => w.child is! Visibility);

      expect(iconOpacityWidget.opacity, minOpacity);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();

      final iconOpacityAfter = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .firstWhere((w) => w.child is! Visibility);
      expect(iconOpacityAfter.opacity, 1.0);
    });

    testWidgets('small variant shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton.small(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 50));
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('large variant shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton.large(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 50));
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('extended variant shows loading in label, keeps icon area',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton.extended(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                },
                label: const Text('Send'),
                icon: const Icon(Icons.send),
              ),
            ),
          ),
        ),
      );

      // Initial: label and icon visible, no loader.
      expect(find.text('Send'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      // During load: default loader appears (from label builder).
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Icon is still part of the tree (it may be faded but present).
      expect(find.byIcon(Icons.send), findsWidgets);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('extended variant with custom loadingChild in label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AsyncFloatingActionButton.extended(
                  onPressed: () async {
                    await Future<void>.delayed(
                        const Duration(milliseconds: 100));
                  },
                  label: const Text('Send'),
                  loadingChild: const Text('Loading...'),
                  icon: const Icon(Icons.send)),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AsyncFloatingActionButton));
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();

      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Send'), findsOneWidget);
    });
  });
}
