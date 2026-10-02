import 'dart:async';
import 'dart:ui' show SemanticsAction, SemanticsFlag, Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../support/async_button_fixture.dart';

const _duration = Duration(milliseconds: 200);

void main() {
  for (final entry in asyncButtonBuilders.entries) {
    group(entry.key, () {
      for (final transition in TransitionAnimationType.values) {
        testWidgets(
          '${transition.name} presents custom loading and idle content',
          (tester) async {
            final pending = Completer<void>();
            var customBuilds = 0;
            await tester.pumpWidget(
              buttonHost(
                entry.value(
                  child: const Text('Run'),
                  loadingChild: const Text('Busy'),
                  loadingSemanticsLabel: 'Ignored default label',
                  onPressed: () => pending.future,
                  transitionType: transition,
                  animationDuration: _duration,
                  customBuilder: (loading, child, loadingChild) {
                    customBuilds++;

                    return Semantics(
                      label: loading ? 'Custom busy' : 'Custom idle',
                      child: loading
                          ? loadingChild ?? const Text('Missing loader')
                          : child,
                    );
                  },
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
            } else {
              expect(customBuilds, 0);
            }
            await tester.tap(materialButton);
            // Text loading content has no indefinite animation. Settling also
            // waits for outgoing switcher entries in either direction.
            await tester.pumpAndSettle();
            expect(find.bySemanticsLabel(RegExp('Run')), findsNothing);
            expect(find.bySemanticsLabel(RegExp('Busy')), findsOneWidget);
            expect(
              find.semantics.byLabel(RegExp('Ignored default label')),
              findsNothing,
            );
            if (transition == TransitionAnimationType.customBuilder) {
              expect(
                tester.getSemantics(materialButton).getSemanticsData().label,
                contains('Custom busy'),
              );
            } else {
              expect(customBuilds, 0);
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
            } else {
              expect(customBuilds, 0);
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
                loadingSemanticsLabel: 'Ignored default label',
                transitionType: TransitionAnimationType.customBuilder,
                customBuilder: (loading, child, loadingChild) =>
                    loading ? loadingChild ?? const Text('Fallback') : child,
              ),
            ),
          );
          expect(find.text('Run'), findsOneWidget);
          expect(find.text('Fallback'), findsNothing);
          await tester.tap(materialButton);
          await tester.pumpAndSettle();
          expect(find.text('Run'), findsNothing);
          expect(find.bySemanticsLabel('Fallback'), findsOneWidget);
          expect(
            find.semantics.byLabel(RegExp('Ignored default label')),
            findsNothing,
          );
          expect(find.byType(CircularProgressIndicator), findsNothing);
          pending.complete();
          await tester.pumpAndSettle();
          expect(find.text('Run'), findsOneWidget);
          expect(find.text('Fallback'), findsNothing);
        },
      );

      for (final asynchronous in [false, true]) {
        final failureName = asynchronous
            ? 'failed Future'
            : 'synchronous throw';
        testWidgets('$failureName propagates and permits retry', (
          tester,
        ) async {
          final failure = StateError('Consumer failure');
          final originalTrace = StackTrace.fromString(
            'original callback trace',
          );
          final errors = <(Object, StackTrace)>[];
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
                    Error.throwWithStackTrace(failure, originalTrace);
                  },
                ),
              ),
            );
            await tester.tap(materialButton);
            await tester.pump();
            if (asynchronous) pending.completeError(failure, originalTrace);
            await tester.pump();
          }, (error, trace) => errors.add((error, trace)));
          // Keep matchers outside the error zone so a failing assertion cannot
          // be mistaken for a consumer error or prevent the test completing.
          expect(errors, hasLength(1));
          expect(errors.single.$1, same(failure));
          expect(errors.single.$2.toString(), originalTrace.toString());
          expect(find.byType(CircularProgressIndicator), findsNothing);
          await tester.pumpAndSettle();
          await tester.tap(materialButton);
          await tester.pumpAndSettle();
          expect(calls, 2);
          expect(errors, hasLength(1));
          expect(errors.single.$1, same(failure));
          expect(errors.single.$2.toString(), originalTrace.toString());
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

  // One owner for default-indicator labels, including factory fallbacks and
  // selected icons. Check actual accessibility output during both loading
  // sources and fades, without depending on the transition's widget structure.
  for (final entry in asyncButtonSemanticsBuilders.entries) {
    for (final transition in [
      TransitionAnimationType.stack,
      TransitionAnimationType.animatedSwitcher,
    ]) {
      testWidgets(
        '${entry.key} ${transition.name} exposes only the current '
        'loading label',
        (tester) async {
          final semantics = tester.ensureSemantics();
          try {
            final pending = Completer<void>();
            var calls = 0;
            Widget host(bool loading, {String? label = 'Guardando cambios'}) =>
                buttonHost(
                  entry.value(
                    child: const Text('Run'),
                    onPressed: () {
                      calls++;

                      return pending.future;
                    },
                    loading: loading,
                    loadingSemanticsLabel: label,
                    transitionType: transition,
                    animationDuration: _duration,
                    minimumChildOpacity: 0.5,
                  ),
                );
            void expectLoadingLabel(String label) {
              final labels = find.semantics.byLabel(RegExp(label));
              expect(labels, findsOne);
              final data = labels.evaluate().single.getSemanticsData();
              // Exact text also detects duplicate labels merged onto one node.
              expect(data.label, label);
              // Material may merge progress into the outer disabled button.
              // There must still be only one button role in the semantics tree.
              expect(find.semantics.byFlag(SemanticsFlag.isButton), findsOne);
              expect(data.flagsCollection.isLiveRegion, isFalse);
              expect(data.hasAction(SemanticsAction.tap), isFalse);
              expect(find.semantics.byLabel('Run'), findsNothing);
              final outer = tester
                  .getSemantics(materialButton)
                  .getSemanticsData();
              expect(outer.flagsCollection.isButton, isTrue);
              expect(outer.flagsCollection.isEnabled, Tristate.isFalse);
              expect(outer.hasAction(SemanticsAction.tap), isFalse);
            }

            await tester.pumpWidget(host(false));
            expect(find.semantics.byLabel('Run'), findsOne);
            expect(find.semantics.byLabel('Guardando cambios'), findsNothing);

            // Null leaves progress unlabeled, with no English default.
            await tester.pumpWidget(host(true, label: null));
            await tester.pump(_duration ~/ 2);
            expect(
              tester
                  .getSemantics(find.byType(CircularProgressIndicator))
                  .getSemanticsData()
                  .label,
              isEmpty,
            );
            await tester.pumpWidget(host(false));
            await tester.pumpAndSettle();

            tester.semantics.performAction(
              find.semantics.byLabel('Run'),
              SemanticsAction.tap,
            );
            await tester.pump();
            await tester.pump(_duration ~/ 2);
            expectLoadingLabel('Guardando cambios');

            // Completing internal work leaves externally owned loading intact.
            await tester.pumpWidget(host(true));
            pending.complete();
            await tester.pump(_duration);
            expectLoadingLabel('Guardando cambios');
            expect(calls, 1);

            // Locale changes update the current label without making it live.
            await tester.pumpWidget(host(true, label: 'Enregistrement'));
            expectLoadingLabel('Enregistrement');
            expect(find.semantics.byLabel('Guardando cambios'), findsNothing);

            await tester.pumpWidget(host(false));
            // Outgoing loading content is inaccessible during its fade.
            expect(find.semantics.byLabel('Enregistrement'), findsNothing);
            await tester.pump(_duration ~/ 2);
            expect(find.semantics.byLabel('Run'), findsOne);
            await tester.pumpAndSettle();
            expect(find.byType(CircularProgressIndicator), findsNothing);
            tester.semantics.performAction(
              find.semantics.byLabel('Run'),
              SemanticsAction.tap,
            );
            await tester.pumpAndSettle();
            expect(calls, 2);
          } finally {
            semantics.dispose();
          }
        },
      );
    }
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
