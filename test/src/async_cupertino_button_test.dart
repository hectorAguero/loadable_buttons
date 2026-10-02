import 'dart:async';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsData;
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/cupertino.dart';

typedef _NativeBuilder =
    CupertinoButton Function({
      required Widget child,
      required VoidCallback? onPressed,
      CupertinoButtonSize sizeStyle,
      EdgeInsetsGeometry? padding,
      Size? minimumSize,
      Color? color,
      Color? foregroundColor,
      Color disabledColor,
      BorderRadius? borderRadius,
      AlignmentGeometry alignment,
      double? pressedOpacity,
    });

typedef _AsyncBuilder =
    AsyncCupertinoButton Function({
      required Widget child,
      required FutureOr<void> Function()? onPressed,
      Key? key,
      bool loading,
      CupertinoButtonSize sizeStyle,
      EdgeInsetsGeometry? padding,
      Size? minimumSize,
      Color? color,
      Color? foregroundColor,
      Color disabledColor,
      BorderRadius? borderRadius,
      AlignmentGeometry alignment,
      double? pressedOpacity,
      VoidCallback? onLongPress,
      Widget? loadingChild,
      TransitionAnimationType transitionType,
      double minimumChildOpacity,
      Color? focusColor,
      FocusNode? focusNode,
      ValueChanged<bool>? onFocusChange,
      bool autofocus,
      MouseCursor? mouseCursor,
    });

final _variants = <String, (_NativeBuilder, _AsyncBuilder)>{
  'plain': (CupertinoButton.new, AsyncCupertinoButton.new),
  'filled': (CupertinoButton.filled, AsyncCupertinoButton.filled),
  'tinted': (CupertinoButton.tinted, AsyncCupertinoButton.tinted),
};

void main() {
  for (final entry in _variants.entries) {
    for (final size in CupertinoButtonSize.values) {
      for (final overrides in [false, true]) {
        testWidgets(
          '${entry.key} ${size.name} matches native layout, colors, and '
          'press feedback (overrides: $overrides)',
          (tester) async {
            const nativeKey = ValueKey('native');
            const asyncKey = ValueKey('async');
            var enabled = true;
            var calls = 0;
            Widget buildButton(bool native) {
              final builder = native ? entry.value.$1 : entry.value.$2;

              return KeyedSubtree(
                key: native ? nativeKey : asyncKey,
                child: builder(
                  child: const Text('Save changes'),
                  onPressed: enabled ? () => calls++ : null,
                  sizeStyle: size,
                  padding: overrides
                      ? const EdgeInsetsDirectional.fromSTEB(30, 8, 12, 18)
                      : null,
                  minimumSize: overrides ? const Size(240, 72) : null,
                  color: overrides ? CupertinoColors.systemOrange : null,
                  foregroundColor: overrides ? CupertinoColors.white : null,
                  borderRadius: overrides ? BorderRadius.circular(28) : null,
                  alignment: overrides
                      ? AlignmentDirectional.centerEnd
                      : Alignment.center,
                  pressedOpacity: overrides ? 0.7 : 0.4,
                ),
              );
            }

            Widget host() => _host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [buildButton(true), buildButton(false)],
              ),
              dark: overrides,
              rtl: overrides,
            );
            await tester.pumpWidget(host());
            final native = find.byKey(nativeKey);
            final async = find.byKey(asyncKey);
            final nativeText = find.descendant(
              of: native,
              matching: find.text('Save changes'),
            );
            final asyncText = find.descendant(
              of: async,
              matching: find.text('Save changes'),
            );
            expect(tester.getSize(async), tester.getSize(native));
            expect(
              tester.getTopLeft(asyncText) - tester.getTopLeft(async),
              tester.getTopLeft(nativeText) - tester.getTopLeft(native),
            );
            expect(
              DefaultTextStyle.of(tester.element(asyncText)).style,
              DefaultTextStyle.of(tester.element(nativeText)).style,
            );
            ShapeDecoration decoration(Finder button) =>
                tester
                        .widget<DecoratedBox>(
                          find.descendant(
                            of: button,
                            matching: find.byWidgetPredicate(
                              (widget) =>
                                  widget is DecoratedBox &&
                                  widget.decoration is ShapeDecoration,
                            ),
                          ),
                        )
                        .decoration
                    as ShapeDecoration;
            expect(decoration(async), decoration(native));
            final nativePress = await tester.startGesture(
              tester.getCenter(native),
              pointer: 1,
            );
            final asyncPress = await tester.startGesture(
              tester.getCenter(async),
              pointer: 2,
            );
            await tester.pumpAndSettle();
            double opacity(Finder button) => tester
                .widget<FadeTransition>(
                  find
                      .descendant(
                        of: button,
                        matching: find.byType(FadeTransition),
                      )
                      .first,
                )
                .opacity
                .value;
            expect(opacity(async), opacity(native));
            expect(opacity(async), lessThan(1.0));
            await nativePress.cancel();
            await asyncPress.cancel();
            await tester.pumpAndSettle();
            enabled = false;
            await tester.pumpWidget(host());
            expect(decoration(async), decoration(native));
            expect(
              DefaultTextStyle.of(tester.element(asyncText)).style,
              DefaultTextStyle.of(tester.element(nativeText)).style,
            );
            await tester.tap(async);
            expect(calls, 0);
            final semantics = tester.getSemantics(async).getSemanticsData();
            expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
            expect(semantics.hasAction(SemanticsAction.tap), isFalse);
          },
        );
      }
    }

    testWidgets(
      '${entry.key} keeps public key state and blocks stale callbacks',
      (
        tester,
      ) async {
        final key = GlobalKey<State<AsyncCupertinoButton>>();
        final pending = Completer<void>();
        var presses = 0;
        var longPresses = 0;
        Widget host({bool loading = false, bool pressEnabled = true}) => _host(
          entry.value.$2(
            key: key,
            child: const Text('Run'),
            loadingChild: const Text('Busy'),
            loading: loading,
            onPressed: pressEnabled
                ? () {
                    presses++;

                    return pending.future;
                  }
                : null,
            onLongPress: () => longPresses++,
          ),
        );
        await tester.pumpWidget(host());
        final state = key.currentState;
        expect(state, isNotNull);
        final native = find.byType(CupertinoButton);
        final idle = tester.widget<CupertinoButton>(native);
        final activate = idle.onPressed;
        final longPress = idle.onLongPress;
        if (activate == null || longPress == null) {
          fail('Idle callbacks must be available at the native boundary.');
        }
        activate();
        activate();
        longPress();
        expect(presses, 1);
        expect(longPresses, 0);
        await tester.pumpWidget(host(loading: true));
        await tester.pumpWidget(host());
        expect(key.currentState, same(state));
        expect(key.currentWidget, isA<AsyncCupertinoButton>());
        await tester.longPress(native);
        expect(longPresses, 0);
        pending.complete();
        await tester.pumpAndSettle();
        await tester.longPress(native);
        expect(longPresses, 1);
        await tester.pumpWidget(host(pressEnabled: false));
        await tester.longPress(native);
        expect(longPresses, 2);
        expect(presses, 1);
        await tester.pumpWidget(host(loading: true, pressEnabled: false));
        await tester.longPress(native);
        expect(longPresses, 2);
        expect(
          tester
              .getSemantics(native)
              .getSemanticsData()
              .flagsCollection
              .isEnabled,
          Tristate.isFalse,
        );
        expect(tester.takeException(), isNull);
      },
    );

    for (final transition in [
      TransitionAnimationType.stack,
      TransitionAnimationType.animatedSwitcher,
    ]) {
      testWidgets('${entry.key} ${transition.name} isolates inactive actions', (
        tester,
      ) async {
        final idleFocus = FocusNode();
        addTearDown(idleFocus.dispose);
        var idleActions = 0;
        var cancellations = 0;
        final pending = Completer<void>();
        await tester.pumpWidget(
          _host(
            entry.value.$2(
              onPressed: () => pending.future,
              transitionType: transition,
              minimumChildOpacity: 0.5,
              child: SizedBox(
                width: 240,
                child: CupertinoButton(
                  alignment: Alignment.centerLeft,
                  focusNode: idleFocus,
                  onPressed: () => idleActions++,
                  child: const Text('Idle action'),
                ),
              ),
              loadingChild: CupertinoButton(
                onPressed: () {
                  cancellations++;
                },
                child: const Text('Cancel'),
              ),
            ),
          ),
        );
        final outer = find.byType(CupertinoButton).first;
        tester.semantics.performAction(
          find.semantics.byLabel('Idle action').first,
          SemanticsAction.tap,
        );
        expect(idleActions, 1);
        final activate = tester.widget<CupertinoButton>(outer).onPressed;
        if (activate == null) fail('Outer activation must be available.');
        activate();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.semantics.byLabel('Idle action'), findsNothing);
        idleFocus.requestFocus();
        await tester.pump();
        expect(idleFocus.hasFocus, isFalse);
        // Hit a retained idle area outside the centered Cancel action.
        await tester.tapAt(
          tester.getTopLeft(find.text('Idle action')) + const Offset(1, 1),
        );
        expect(idleActions, 1);
        await tester.tap(find.text('Cancel'));
        expect(cancellations, 1);
        tester.semantics.performAction(
          find.semantics.byLabel('Cancel'),
          SemanticsAction.tap,
        );
        expect(cancellations, 2);
        pending.complete();
        await tester.pumpAndSettle();
        expect(idleActions, 1);
        expect(find.semantics.byLabel('Cancel'), findsNothing);
        expect(find.semantics.byLabel('Idle action'), findsOne);
      });
    }

    testWidgets(
      '${entry.key} merges ancestor labels like the native button',
      (tester) async {
        var presses = 0;
        Future<SemanticsData> labeled({
          required bool native,
          bool loading = false,
        }) async {
          const icon = Icon(CupertinoIcons.add);
          await tester.pumpWidget(
            _host(
              Semantics(
                label: 'Add',
                child: native
                    ? entry.value.$1(child: icon, onPressed: () => presses++)
                    : entry.value.$2(
                        child: icon,
                        onPressed: () => presses++,
                        loading: loading,
                      ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));

          return find.semantics
              .byLabel('Add')
              .evaluate()
              .single
              .getSemanticsData();
        }

        final native = await labeled(native: true);
        final idle = await labeled(native: false);
        expect(idle.flagsCollection.isButton, native.flagsCollection.isButton);
        expect(idle.flagsCollection.isButton, isTrue);
        expect(idle.flagsCollection.isEnabled, Tristate.isTrue);
        expect(idle.hasAction(SemanticsAction.tap), isTrue);
        tester.semantics.performAction(
          find.semantics.byLabel('Add'),
          SemanticsAction.tap,
        );
        expect(presses, 1);
        final loading = await labeled(native: false, loading: true);
        expect(loading.flagsCollection.isButton, isTrue);
        expect(loading.flagsCollection.isEnabled, Tristate.isFalse);
        expect(loading.hasAction(SemanticsAction.tap), isFalse);
      },
    );

    testWidgets('${entry.key} keeps a valid spinner at zero text scale', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(0)),
          child: _host(
            entry.value.$2(
              loading: true,
              onPressed: () {},
              child: const Icon(CupertinoIcons.add),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<CupertinoActivityIndicator>(
              find.byType(CupertinoActivityIndicator),
            )
            .radius,
        greaterThan(0),
      );
    });

    testWidgets('${entry.key} forwards native focus and cursor options', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final focusChanges = <bool>[];
      await tester.pumpWidget(
        _host(
          entry.value.$2(
            child: const Text('Run'),
            onPressed: () {},
            focusColor: CupertinoColors.systemGreen,
            focusNode: focusNode,
            onFocusChange: focusChanges.add,
            autofocus: true,
            mouseCursor: SystemMouseCursors.help,
          ),
        ),
      );
      await tester.pump();
      final native = tester.widget<CupertinoButton>(
        find.byType(CupertinoButton),
      );
      expect(native.focusColor, CupertinoColors.systemGreen);
      expect(native.focusNode, same(focusNode));
      expect(native.autofocus, isTrue);
      expect(native.mouseCursor, SystemMouseCursors.help);
      expect(focusNode.hasFocus, isTrue);
      expect(focusChanges, [true]);
    });

    testWidgets(
      '${entry.key} uses Cupertino theme and explicit spinner colors',
      (
        tester,
      ) async {
        for (final foreground in [null, CupertinoColors.systemOrange]) {
          await tester.pumpWidget(
            _host(
              entry.value.$2(
                child: const Text('Run'),
                onPressed: () {},
                loading: true,
                foregroundColor: foreground,
              ),
            ),
          );
          final indicator = tester.widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          );
          // Loading shows the disabled fill, where white would disappear.
          expect(indicator.color, foreground ?? CupertinoColors.systemPurple);
        }
      },
    );

    testWidgets(
      '${entry.key} default spinner keeps the idle text size while loading',
      (tester) async {
        for (final size in CupertinoButtonSize.values) {
          for (final scale in [1.0, 2.0]) {
            Widget host({required bool loading}) => MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: _host(
                entry.value.$2(
                  sizeStyle: size,
                  loading: loading,
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ),
            );
            await tester.pumpWidget(host(loading: false));
            // Let the retained idle content finish resizing from the last case.
            await tester.pump(const Duration(milliseconds: 300));
            final native = find.byType(CupertinoButton);
            final idle = tester.getSize(native);
            await tester.pumpWidget(host(loading: true));
            await tester.pump(const Duration(milliseconds: 300));
            expect(
              tester.getSize(native),
              idle,
              reason: '${size.name} at text scale $scale',
            );
            expect(
              tester.getSize(find.byType(CupertinoActivityIndicator)).height,
              lessThanOrEqualTo(tester.getSize(find.text('Save')).height),
            );
          }
        }
      },
    );
  }
}

Widget _host(Widget child, {bool dark = false, bool rtl = false}) =>
    CupertinoApp(
      theme: CupertinoThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.systemPurple,
        primaryContrastingColor: CupertinoColors.white,
      ),
      home: CupertinoPageScaffold(
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Center(child: child),
        ),
      ),
    );
