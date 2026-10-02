import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef _Builder =
    Widget Function({
      required Widget child,
      required Widget? loadingChild,
      required bool loading,
      required Future<void> Function() onPressed,
      required TransitionAnimationType transition,
    });

const _duration = Duration(milliseconds: 200);
const _halfDuration = Duration(milliseconds: 100);
const ValueKey<String> _buttonKey = ValueKey('button');

final _builders = <String, _Builder>{
  'Elevated':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncElevatedButton(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Filled':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncFilledButton(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Filled tonal':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncFilledButton.tonal(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Outlined':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncOutlinedButton(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Text':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncTextButton(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Icon':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncIconButton(
        icon: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Floating action':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncFloatingActionButton(
        child: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
  'Extended floating action':
      ({
        required child,
        required loadingChild,
        required loading,
        required onPressed,
        required transition,
      }) => AsyncFloatingActionButton.extended(
        label: child,
        loadingChild: loadingChild,
        loading: loading,
        onPressed: onPressed,
        transitionType: transition,
        animationDuration: _duration,
        minimumChildOpacity: 0.0,
      ),
};

void main() {
  for (final entry in _builders.entries) {
    for (final transition in [
      TransitionAnimationType.stack,
      TransitionAnimationType.animatedSwitcher,
    ]) {
      testWidgets('${entry.key} $transition blocks nested pointer actions', (
        tester,
      ) async {
        final pending = Completer<void>();
        var nestedCalls = 0;
        await tester.pumpWidget(
          _host(
            entry.value(
              child: _action('Idle action', null, () => nestedCalls++),
              loadingChild: const SizedBox.shrink(),
              loading: false,
              onPressed: () => pending.future,
              transition: transition,
            ),
          ),
        );
        final actionPosition = tester.getCenter(find.text('Idle action'));
        await tester.tapAt(actionPosition);
        expect(nestedCalls, 1);
        _startOperation(tester);
        await tester.pump();
        for (final elapsed in [Duration.zero, _halfDuration, _duration]) {
          await tester.pump(elapsed);
          await tester.tapAt(actionPosition);
          expect(nestedCalls, 1);
        }
        pending.complete();
        await tester.pump();
        await tester.pump(_duration);
        await tester.tap(find.text('Idle action'));
        expect(nestedCalls, 2);
      });

      testWidgets(
        '${entry.key} $transition excludes hidden focus and actions',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            final idleFocus = FocusNode();
            final loadingFocus = FocusNode();
            addTearDown(idleFocus.dispose);
            addTearDown(loadingFocus.dispose);
            var idleCalls = 0;
            var loadingCalls = 0;
            Widget host(bool loading) => _host(
              entry.value(
                child: _action('Idle action', idleFocus, () => idleCalls++),
                loadingChild: _action(
                  'Loading action',
                  loadingFocus,
                  () => loadingCalls++,
                ),
                loading: loading,
                onPressed: Future<void>.value,
                transition: transition,
              ),
            );
            await tester.pumpWidget(host(false));
            idleFocus.requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            expect(idleCalls, 1);

            await tester.pumpWidget(host(true));
            for (final elapsed in [Duration.zero, _halfDuration, _duration]) {
              await tester.pump(elapsed);
              idleFocus.requestFocus();
              await tester.pump();
              expect(
                find.semantics.byLabel(RegExp('Idle action')),
                findsNothing,
              );
              expect(idleFocus.hasFocus, isFalse);
              await tester.sendKeyEvent(LogicalKeyboardKey.enter);
              expect(idleCalls, 1);
            }
            tester.semantics.performAction(
              find.semantics.byLabel('Loading action'),
              SemanticsAction.tap,
            );
            await tester.pump();
            expect(loadingCalls, 1);
            loadingFocus.requestFocus();
            await tester.pump();
            expect(loadingFocus.hasFocus, isTrue);

            await tester.pumpWidget(host(false));
            for (final elapsed in [Duration.zero, _halfDuration, _duration]) {
              await tester.pump(elapsed);
              loadingFocus.requestFocus();
              await tester.pump();
              expect(loadingFocus.hasFocus, isFalse);
              expect(
                find.semantics.byLabel(RegExp('Loading action')),
                findsNothing,
              );
              await tester.sendKeyEvent(LogicalKeyboardKey.enter);
              expect(loadingCalls, 1);
            }
            final callsBeforeRestoringFocus = idleCalls;
            idleFocus.requestFocus();
            await tester.pump();
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
            expect(idleCalls, callsBeforeRestoringFocus + 1);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }

  for (final entry in _builders.entries.where(
    (entry) => entry.key == 'Filled' || entry.key == 'Extended floating action',
  )) {
    testWidgets('${entry.key} switcher resizes smoothly in both directions', (
      tester,
    ) async {
      Widget host(bool loading) => _host(
        entry.value(
          child: const Text('Send the saved document'),
          loadingChild: const SizedBox.square(
            dimension: 24,
            child: ColoredBox(color: Colors.teal),
          ),
          loading: loading,
          onPressed: Future<void>.value,
          transition: TransitionAnimationType.animatedSwitcher,
        ),
      );
      Future<List<double>> widthsDuringTransition(bool loading) async {
        await tester.pumpWidget(host(loading));
        final widths = <double>[tester.getSize(find.byKey(_buttonKey)).width];
        const frameDuration = Duration(milliseconds: 20);
        for (
          var elapsed = Duration.zero;
          elapsed < _duration * 3;
          elapsed += frameDuration
        ) {
          await tester.pump(frameDuration);
          widths.add(tester.getSize(find.byKey(_buttonKey)).width);
        }

        return widths;
      }

      await tester.pumpWidget(host(false));
      final idleWidth = tester.getSize(find.byKey(_buttonKey)).width;
      final shrinkingWidths = await widthsDuringTransition(true);
      final loadingWidth = shrinkingWidths.last;
      expect(loadingWidth, lessThan(idleWidth));
      expect(shrinkingWidths.first, closeTo(idleWidth, 0.01));
      expect(
        shrinkingWidths,
        contains(allOf(greaterThan(loadingWidth), lessThan(idleWidth))),
      );

      final growingWidths = await widthsDuringTransition(false);
      expect(growingWidths.first, closeTo(loadingWidth, 0.01));
      expect(
        growingWidths,
        contains(allOf(greaterThan(loadingWidth), lessThan(idleWidth))),
      );
      expect(growingWidths.last, closeTo(idleWidth, 0.01));
    });
  }

  for (final transition in [
    TransitionAnimationType.stack,
    TransitionAnimationType.animatedSwitcher,
  ]) {
    testWidgets('$transition isolates outgoing loading pointer actions', (
      tester,
    ) async {
      var idleCalls = 0;
      var loadingCalls = 0;
      Widget host(bool loading) => _host(
        AsyncFilledButton(
          loading: loading,
          onPressed: () {},
          transitionType: transition,
          animationDuration: _duration,
          minimumChildOpacity: 0.3,
          child: _action('Idle action', null, () => idleCalls++),
          loadingChild: SizedBox(
            width: 120,
            height: 24,
            child: Align(
              alignment: Alignment.centerRight,
              child: _action('Loading action', null, () => loadingCalls++),
            ),
          ),
        ),
      );
      await tester.pumpWidget(host(false));
      await tester.pumpWidget(host(true));
      await tester.pump(_duration);
      // Idle content is still faintly visible but must not accept gestures.
      await tester.tapAt(tester.getCenter(find.text('Idle action')));
      expect(idleCalls, 0);
      final loadingPosition = tester.getCenter(find.text('Loading action'));
      await tester.tapAt(loadingPosition);
      expect(loadingCalls, 1);
      await tester.pumpWidget(host(false));
      await tester.tapAt(loadingPosition);
      expect(loadingCalls, 1);
      await tester.pump(_halfDuration);
      await tester.tapAt(loadingPosition);
      expect(loadingCalls, 1);
      // Reverse again before the outgoing animation finishes.
      await tester.pumpWidget(host(true));
      await tester.pump(_duration);
      await tester.tap(find.text('Loading action'));
      expect(loadingCalls, 2);
      await tester.pumpWidget(host(false));
      await tester.pump(_duration);
      await tester.tap(find.text('Idle action'));
      expect(idleCalls, 1);
    });
  }

  testWidgets('extended FAB switcher preserves a keyed icon across loading', (
    tester,
  ) async {
    final iconKey = GlobalKey();
    Widget host(bool loading) => _host(
      AsyncFloatingActionButton.extended(
        onPressed: () {},
        loading: loading,
        label: const Text('Send'),
        icon: Icon(Icons.send, key: iconKey),
        transitionType: TransitionAnimationType.animatedSwitcher,
        animationDuration: _duration,
      ),
    );
    await tester.pumpWidget(host(false));
    await tester.pumpWidget(host(true));
    expect(tester.takeException(), isNull);
    await tester.pump(_duration + const Duration(milliseconds: 1));
    await tester.pumpWidget(host(false));
    await tester.pump(_duration + const Duration(milliseconds: 1));
    expect(tester.takeException(), isNull);
  });

  for (final withIcon in [false, true]) {
    for (final direction in TextDirection.values) {
      for (final paddingSource in [
        'default',
        'theme',
        'inherited',
        'empty inherited',
        'widget',
      ]) {
        testWidgets(
          'extended FAB preserves Material layout and centers its loader: '
          '$withIcon $direction $paddingSource',
          (tester) async {
            final iconKey = GlobalKey();
            final icon = withIcon ? Icon(Icons.send, key: iconKey) : null;
            const label = Text('Send');
            final padding = paddingSource == 'widget'
                ? const EdgeInsetsDirectional.fromSTEB(12, 2, 18, 10)
                : null;
            final spacing = paddingSource == 'widget' ? 12.0 : null;
            const loadingKey = ValueKey('extended-loading-control');
            var loadingCalls = 0;
            final loadingChild = paddingSource == 'widget'
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => loadingCalls++,
                    child: const SizedBox(
                      key: loadingKey,
                      width: 24,
                      height: 20,
                    ),
                  )
                : null;
            final textStyle = paddingSource == 'widget'
                ? const TextStyle(fontSize: 16)
                : null;
            Widget host(Widget button) => MaterialApp(
              theme: ThemeData(
                floatingActionButtonTheme: paddingSource == 'default'
                    ? const FloatingActionButtonThemeData()
                    : const FloatingActionButtonThemeData(
                        extendedPadding: EdgeInsetsDirectional.fromSTEB(
                          10,
                          4,
                          26,
                          12,
                        ),
                        extendedIconLabelSpacing: 20,
                        extendedTextStyle: TextStyle(fontSize: 18),
                      ),
              ),
              home: Scaffold(
                body: Center(
                  child: MediaQuery(
                    data: const MediaQueryData(
                      textScaler: TextScaler.linear(2),
                    ),
                    child: Directionality(
                      textDirection: direction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: KeyedSubtree(
                          key: _buttonKey,
                          child:
                              paddingSource == 'default' ||
                                  paddingSource == 'theme'
                              ? button
                              : FloatingActionButtonTheme(
                                  data: paddingSource == 'empty inherited'
                                      ? const FloatingActionButtonThemeData()
                                      : const FloatingActionButtonThemeData(
                                          extendedPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                6,
                                                8,
                                                30,
                                                14,
                                              ),
                                          extendedIconLabelSpacing: 28,
                                          extendedTextStyle: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                  child: button,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpWidget(
              host(
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: label,
                  icon: icon,
                  extendedPadding: padding,
                  extendedIconLabelSpacing: spacing,
                  extendedTextStyle: textStyle,
                ),
              ),
            );
            final materialSize = tester.getSize(find.byKey(_buttonKey));
            final materialLabelRect = tester.getRect(find.text('Send'));
            final materialIconRect = withIcon
                ? tester.getRect(find.byKey(iconKey))
                : null;
            Widget button(bool loading) => AsyncFloatingActionButton.extended(
              onPressed: () {},
              label: label,
              icon: icon,
              loading: loading,
              loadingChild: loadingChild,
              extendedPadding: padding,
              extendedIconLabelSpacing: spacing,
              extendedTextStyle: textStyle,
            );
            await tester.pumpWidget(host(button(false)));
            expect(tester.getSize(find.byKey(_buttonKey)), materialSize);
            final labelRect = tester.getRect(find.text('Send'));
            expect(labelRect, materialLabelRect);
            if (withIcon) {
              expect(tester.getRect(find.byKey(iconKey)), materialIconRect);
              final labelX = labelRect.center.dx;
              final iconX = tester.getCenter(find.byKey(iconKey)).dx;
              expect(
                direction == TextDirection.ltr
                    ? iconX < labelX
                    : iconX > labelX,
                isTrue,
              );
            }
            await tester.pumpWidget(host(button(true)));
            final loader = loadingChild == null
                ? find.byType(CircularProgressIndicator)
                : find.byKey(loadingKey);
            for (final elapsed in [Duration.zero, _halfDuration, _duration]) {
              await tester.pump(elapsed);
              expect(tester.takeException(), isNull);
              expect(tester.getSize(find.byKey(_buttonKey)), materialSize);
              expect(
                tester.getCenter(loader).dx,
                closeTo(tester.getCenter(find.byKey(_buttonKey)).dx, 0.01),
              );
              expect(
                tester.getCenter(loader).dy,
                closeTo(tester.getCenter(find.byKey(_buttonKey)).dy, 0.01),
              );
            }
            if (loadingChild != null) {
              await tester.tapAt(tester.getCenter(loader));
              expect(loadingCalls, 1);
            }
            await tester.pumpWidget(host(button(false)));
            await tester.pump(_duration);
            expect(tester.getSize(find.byKey(_buttonKey)), materialSize);
          },
        );
      }
    }
  }

  for (final entry in _builders.entries) {
    testWidgets('${entry.key} spinner follows the Material foreground theme', (
      tester,
    ) async {
      final style = ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? Colors.grey : Colors.teal,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(style: style),
            filledButtonTheme: FilledButtonThemeData(style: style),
            outlinedButtonTheme: OutlinedButtonThemeData(style: style),
            textButtonTheme: TextButtonThemeData(style: style),
            iconButtonTheme: IconButtonThemeData(style: style),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              foregroundColor: Colors.teal,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.orange,
            ),
          ),
          home: Scaffold(
            body: Center(
              child: entry.value(
                child: const Icon(Icons.send),
                loadingChild: null,
                loading: true,
                onPressed: Future<void>.value,
                transition: TransitionAnimationType.stack,
              ),
            ),
          ),
        ),
      );
      final spinner = find.byType(CircularProgressIndicator);
      expect(
        tester.widget<CircularProgressIndicator>(spinner).color,
        Colors.teal,
      );
    });
  }

  testWidgets('spinner resolves each foreground before applying precedence', (
    tester,
  ) async {
    final themeStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? Colors.grey : Colors.teal,
      ),
    );
    for (final foreground in <Color?>[Colors.green, null]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            filledButtonTheme: FilledButtonThemeData(style: themeStyle),
          ),
          home: Scaffold(
            body: Center(
              child: AsyncFilledButton(
                child: const Text('Send'),
                onPressed: Future<void>.value,
                loading: true,
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? Colors.purple
                        : foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .color,
        foreground ?? Colors.teal,
      );
    }
  });

  testWidgets('stack sizing respects custom content and parent constraints', (
    tester,
  ) async {
    Widget host(bool loading, double loadingWidth) => _host(
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: AsyncElevatedButton(
          onPressed: () {},
          loading: loading,
          loadingChild: SizedBox(width: loadingWidth, height: 24),
          child: const Text('Send'),
        ),
      ),
    );
    await tester.pumpWidget(host(false, 16));
    final idleSize = tester.getSize(find.byKey(_buttonKey));
    await tester.pumpWidget(host(true, 16));
    await tester.pump(_duration);
    expect(tester.getSize(find.byKey(_buttonKey)), idleSize);
    await tester.pumpWidget(host(true, 240));
    await tester.pump(_duration);
    final loadingSize = tester.getSize(find.byKey(_buttonKey));
    expect(loadingSize.width, greaterThan(idleSize.width));
    expect(loadingSize.width, lessThanOrEqualTo(160));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(host(false, 240));
    await tester.pump(_duration);
    expect(tester.getSize(find.byKey(_buttonKey)), idleSize);
  });

  for (final transition in [
    TransitionAnimationType.stack,
    TransitionAnimationType.animatedSwitcher,
  ]) {
    testWidgets('Elevated $transition exposes only the current loading label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        Widget host(bool loading, {Widget? loadingChild}) => _host(
          AsyncElevatedButton(
            onPressed: () {},
            loading: loading,
            transitionType: transition,
            animationDuration: _duration,
            loadingSemanticsLabel: 'Saving',
            loadingChild: loadingChild,
            child: const Text('Save'),
          ),
        );
        await tester.pumpWidget(host(false));
        expect(find.semantics.byLabel(RegExp('Saving')), findsNothing);
        await tester.pumpWidget(host(true));
        await tester.pump(_halfDuration);
        expect(find.semantics.byLabel(RegExp('Saving')), findsOne);
        expect(find.semantics.byLabel('Save'), findsNothing);
        await tester.pumpWidget(host(false));
        expect(find.semantics.byLabel(RegExp('Saving')), findsNothing);
        await tester.pump(_duration);
        await tester.pumpWidget(
          host(true, loadingChild: const Text('Working')),
        );
        await tester.pump(_duration);
        expect(find.semantics.byLabel(RegExp('Saving')), findsNothing);
        expect(find.semantics.byLabel(RegExp('Working')), findsOne);
      } finally {
        semantics.dispose();
      }
    });
  }
}

Widget _action(String label, FocusNode? focusNode, VoidCallback onPressed) =>
    SizedBox(
      width: 24,
      height: 24,
      child: TextButton(
        focusNode: focusNode,
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label, maxLines: 1),
      ),
    );

void _startOperation(WidgetTester tester) {
  final button = tester.widget<Widget>(
    find
        .byWidgetPredicate(
          (widget) =>
              widget is ButtonStyleButton ||
              widget is IconButton ||
              widget is FloatingActionButton,
        )
        .first,
  );
  VoidCallback? onPressed;
  if (button is ButtonStyleButton) {
    onPressed = button.onPressed;
  } else if (button is IconButton) {
    onPressed = button.onPressed;
  } else if (button is FloatingActionButton) {
    onPressed = button.onPressed;
  }
  if (onPressed == null) fail('The idle Material button must be enabled.');
  onPressed();
}

Widget _host(Widget button) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: KeyedSubtree(key: _buttonKey, child: button),
    ),
  ),
);
