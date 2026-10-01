import 'dart:async';
import 'dart:ui' show SemanticsAction, SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

import '../support/async_button_fixture.dart';

const _duration = Duration(milliseconds: 200);

void main() {
  for (final entry in asyncButtonBuilders.entries) {
    group(entry.key, () {
      testWidgets('default indicator clears on completion and allows retry', (
        tester,
      ) async {
        final pending = Completer<void>();
        var calls = 0;
        await tester.pumpWidget(
          buttonHost(
            entry.value(
              child: const Text('Run'),
              onPressed: () {
                calls++;

                return pending.future;
              },
            ),
          ),
        );
        expect(find.text('Run'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(materialButton);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        pending.complete();
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Run'), findsOneWidget);
        // Accessibility activation must also reach the restored callback.
        tester.semantics.performAction(
          find.semantics.byLabel('Run'),
          SemanticsAction.tap,
        );
        await tester.pumpAndSettle();
        expect(calls, 2);
      });

      for (final transition in TransitionAnimationType.values) {
        testWidgets(
          '${transition.name} presents custom loading and idle content',
          (tester) async {
            final pending = Completer<void>();
            await tester.pumpWidget(
              buttonHost(
                entry.value(
                  child: const Text('Run'),
                  loadingChild: const Text('Busy'),
                  onPressed: () => pending.future,
                  transitionType: transition,
                  animationDuration: _duration,
                  customBuilder:
                      (loading, child, loadingChild) => Semantics(
                        label: loading ? 'Custom busy' : 'Custom idle',
                        child:
                            loading
                                ? loadingChild ?? const Text('Missing loader')
                                : child,
                      ),
                ),
              ),
            );
            expect(find.bySemanticsLabel(RegExp('Run')), findsOneWidget);
            expect(find.text('Busy'), findsNothing);
            if (transition == TransitionAnimationType.customBuilder) {
              expect(
                tester.getSemantics(materialButton).getSemanticsData().label,
                contains('Custom idle'),
              );
            }
            await tester.tap(materialButton);
            // Text loading content has no indefinite animation. Settling also
            // waits for outgoing switcher entries in either direction.
            await tester.pumpAndSettle();
            expect(find.bySemanticsLabel(RegExp('Run')), findsNothing);
            expect(find.bySemanticsLabel(RegExp('Busy')), findsOneWidget);
            if (transition == TransitionAnimationType.customBuilder) {
              expect(
                tester.getSemantics(materialButton).getSemanticsData().label,
                contains('Custom busy'),
              );
            }
            expect(find.text('Missing loader'), findsNothing);
            expect(find.byType(CircularProgressIndicator), findsNothing);
            if (transition != TransitionAnimationType.stack) {
              expect(find.text('Run'), findsNothing);
            }
            pending.complete();
            await tester.pumpAndSettle();
            expect(find.bySemanticsLabel(RegExp('Run')), findsOneWidget);
            expect(find.text('Busy'), findsNothing);
            if (transition == TransitionAnimationType.customBuilder) {
              expect(
                tester.getSemantics(materialButton).getSemanticsData().label,
                contains('Custom idle'),
              );
            }
          },
        );
      }

      testWidgets(
        'custom builder handles a nullable loadingChild in both states',
        (tester) async {
          final pending = Completer<void>();
          await tester.pumpWidget(
            buttonHost(
              entry.value(
                child: const Text('Run'),
                onPressed: () => pending.future,
                transitionType: TransitionAnimationType.customBuilder,
                customBuilder:
                    (loading, child, loadingChild) =>
                        loading
                            ? loadingChild ?? const Text('Fallback')
                            : child,
              ),
            ),
          );
          expect(find.text('Run'), findsOneWidget);
          expect(find.text('Fallback'), findsNothing);
          await tester.tap(materialButton);
          await tester.pumpAndSettle();
          expect(find.text('Run'), findsNothing);
          expect(find.text('Fallback'), findsOneWidget);
          pending.complete();
          await tester.pumpAndSettle();
          expect(find.text('Run'), findsOneWidget);
          expect(find.text('Fallback'), findsNothing);
        },
      );

      for (final asynchronous in [false, true]) {
        final failureName =
            asynchronous ? 'failed Future' : 'synchronous throw';
        testWidgets('$failureName propagates and permits retry', (
          tester,
        ) async {
          final failure = StateError('Consumer failure');
          final errors = <Object>[];
          var calls = 0;
          // Material takes a VoidCallback. Uncaught consumer failures reach the
          // caller's zone, which we observe without accessing private State.
          await runZonedGuarded(() async {
            final pending = Completer<void>();
            await tester.pumpWidget(
              buttonHost(
                entry.value(
                  child: const Text('Run'),
                  onPressed: () {
                    calls++;
                    if (calls > 1) return Future<void>.value();
                    if (asynchronous) return pending.future;
                    throw failure;
                  },
                ),
              ),
            );
            await tester.tap(materialButton);
            await tester.pump();
            if (asynchronous) pending.completeError(failure);
            await tester.pump();
          }, (error, _) => errors.add(error));
          // Keep matchers outside the error zone so a failing assertion cannot
          // be mistaken for a consumer error or prevent the test completing.
          expect(errors, [failure]);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          await tester.pumpAndSettle();
          await tester.tap(materialButton);
          await tester.pumpAndSettle();
          expect(calls, 2);
          expect(errors, [failure]);
        });
      }

      testWidgets('disposal leaves pending work free to complete', (
        tester,
      ) async {
        final pending = Completer<void>();
        var completions = 0;
        await tester.pumpWidget(
          buttonHost(
            entry.value(
              child: const Text('Run'),
              onPressed: () async {
                await pending.future;
                completions++;
              },
            ),
          ),
        );
        await tester.tap(materialButton);
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpWidget(buttonHost(const Text('Removed')));
        pending.complete();
        await tester.pumpAndSettle();
        expect(completions, 1);
        expect(tester.takeException(), isNull);
        expect(find.text('Removed'), findsOneWidget);
      });
    });
  }

  // Text-button keyboard/loading semantics are already owned by #8. IconButton
  // and FAB have distinct native controls, so cover their activation here.
  for (final entry in asyncButtonBuilders.entries.where(
    (entry) =>
        entry.key.startsWith('Icon') || entry.key.startsWith('Floating action'),
  )) {
    testWidgets(
      '${entry.key} gates keyboard and semantic tap actions on loading',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          final focus = FocusNode();
          addTearDown(focus.dispose);
          final pending = Completer<void>();
          var calls = 0;
          Widget host(bool loading) => buttonHost(
            entry.value(
              child: const Text('Run'),
              loadingChild: const Text('Busy'),
              loading: loading,
              focusNode: focus,
              onPressed: () {
                calls++;

                return pending.future;
              },
            ),
          );
          void expectLoading() {
            final data = tester.getSemantics(materialButton).getSemanticsData();
            // flagsCollection is unavailable on Flutter 3.29.
            // ignore: deprecated_member_use
            expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
            // flagsCollection is unavailable on Flutter 3.29.
            // ignore: deprecated_member_use
            expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
            expect(data.hasAction(SemanticsAction.tap), isFalse);
          }

          await tester.pumpWidget(host(false));
          focus.requestFocus();
          await tester.pump();
          expect(focus.hasFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(calls, 1);
          expectLoading();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(calls, 1);

          await tester.pumpWidget(host(true));
          pending.complete();
          await tester.pumpAndSettle();
          expectLoading();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          expect(calls, 1);

          await tester.pumpWidget(host(false));
          await tester.pumpAndSettle();
          final node = tester.getSemantics(materialButton);
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          focus.requestFocus();
          await tester.pump();
          expect(focus.hasFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(calls, 2);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
