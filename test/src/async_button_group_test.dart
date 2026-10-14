import 'dart:async';
import 'dart:ui' show SemanticsAction, SemanticsFlag;

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../support/async_button_fixture.dart';

Finder _nativeButtonOf(String label) => find
    .ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is cupertino.CupertinoButton ||
            widget is ButtonStyleButton ||
            widget is IconButton ||
            widget is FloatingActionButton,
      ),
    )
    .first;

bool _isEnabled(WidgetTester tester, String label) {
  final data = tester.getSemantics(_nativeButtonOf(label)).getSemanticsData();

  // flagsCollection is unavailable on the minimum supported SDK.
  // ignore: deprecated_member_use
  return data.hasFlag(SemanticsFlag.isEnabled) &&
      data.hasAction(SemanticsAction.tap);
}

void main() {
  // Every constructor participates in both roles: as the active button that
  // blocks a peer, and as a peer blocked natively without loading content.
  for (final entry in asyncButtonConstructorBuilders.entries) {
    testWidgets('${entry.key} blocks and is blocked by group peers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var operation = Completer<void>();
      final calls = <String>[];
      final peerFocus = FocusNode();
      addTearDown(peerFocus.dispose);
      Widget member(String label, {FocusNode? focusNode}) => entry.value(
        child: Text(label),
        loadingChild: Text('$label busy'),
        focusNode: focusNode,
        onPressed: () {
          calls.add(label);

          return operation.future;
        },
      );
      final buttons = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          member('Save'),
          member('Delete', focusNode: peerFocus),
        ],
      );
      await tester.pumpWidget(
        buttonHost(member('unused')) is cupertino.CupertinoApp
            ? cupertino.CupertinoApp(
                home: Center(child: AsyncButtonGroup(child: buttons)),
              )
            : MaterialApp(
                home: Scaffold(
                  body: Center(child: AsyncButtonGroup(child: buttons)),
                ),
              ),
      );

      for (final (active, peer) in [('Save', 'Delete'), ('Delete', 'Save')]) {
        await tester.tap(_nativeButtonOf(active));
        await tester.pump();
        expect(find.text('$active busy'), findsOneWidget);
        expect(find.text('$peer busy'), findsNothing);
        expect(_isEnabled(tester, peer), isFalse);

        await tester.tap(_nativeButtonOf(peer), warnIfMissed: false);
        if (peer == 'Delete') {
          peerFocus.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
        }
        expect(calls, [if (active == 'Delete') 'Save', active]);

        operation.complete();
        await tester.pumpAndSettle();
        expect(_isEnabled(tester, peer), isTrue);
        operation = Completer<void>();
      }
      handle.dispose();
    });
  }

  Widget group(List<Widget> children) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: AsyncButtonGroup(
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    ),
  );

  Widget button(
    String label,
    FutureOr<void> Function() onPressed, {
    bool excludeFromGroup = false,
    bool loading = false,
    AsyncButtonController? controller,
    AsyncButtonErrorHandler? onError,
  }) => AsyncTextButton(
    excludeFromGroup: excludeFromGroup,
    loading: loading,
    controller: controller,
    onError: onError,
    loadingChild: Text('$label busy'),
    onPressed: onPressed,
    child: Text(label),
  );

  testWidgets('claims synchronously so same-frame activations cannot race', (
    tester,
  ) async {
    final operation = Completer<void>();
    final calls = <String>[];
    await tester.pumpWidget(
      group([
        button('Save', () {
          calls.add('Save');

          return operation.future;
        }),
        button('Delete', () => calls.add('Delete')),
      ]),
    );
    final save = tester.widget<ButtonStyleButton>(_nativeButtonOf('Save'));
    final delete = tester.widget<ButtonStyleButton>(_nativeButtonOf('Delete'));

    // Both callbacks fire before any rebuild disables the peer.
    save.onPressed?.call();
    delete.onPressed?.call();
    expect(calls, ['Save']);

    operation.complete();
    await tester.pumpAndSettle();
  });

  for (final handled in [true, false]) {
    testWidgets('restores peers after a ${handled ? '' : 'un'}handled error', (
      tester,
    ) async {
      final uncaught = <Object>[];
      var deletes = 0;
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          group([
            button(
              'Save',
              () => Future<void>.error(StateError('failed')),
              onError: handled ? (_, _) {} : null,
            ),
            button('Delete', () => deletes++),
          ]),
        );
        await tester.tap(_nativeButtonOf('Save'));
        await tester.pumpAndSettle();
      }, (error, _) => uncaught.add(error));

      expect(uncaught, handled ? isEmpty : hasLength(1));
      await tester.tap(_nativeButtonOf('Delete'));
      expect(deletes, 1);
    });
  }

  testWidgets('excluded buttons stay available and never block members', (
    tester,
  ) async {
    final save = Completer<void>();
    final cancel = Completer<void>();
    final calls = <String>[];
    await tester.pumpWidget(
      group([
        button('Save', () {
          calls.add('Save');

          return save.future;
        }),
        button('Delete', () => calls.add('Delete')),
        button('Cancel', () {
          calls.add('Cancel');

          return cancel.future;
        }, excludeFromGroup: true),
      ]),
    );

    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();
    await tester.tap(_nativeButtonOf('Cancel'));
    await tester.pump();
    expect(calls, ['Save', 'Cancel']);
    expect(find.text('Cancel busy'), findsOneWidget);

    save.complete();
    await tester.pumpAndSettle();
    // A pending excluded operation does not claim the group.
    await tester.tap(_nativeButtonOf('Delete'));
    expect(calls, ['Save', 'Cancel', 'Delete']);
    cancel.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('loading requests affect only their own button', (
    tester,
  ) async {
    final controller = AsyncButtonController(loading: true);
    addTearDown(controller.dispose);
    var deletes = 0;
    await tester.pumpWidget(
      group([
        button('Save', () {}, loading: true),
        button('Sync', () {}, controller: controller),
        button('Delete', () => deletes++),
      ]),
    );

    expect(find.text('Save busy'), findsOneWidget);
    expect(find.text('Sync busy'), findsOneWidget);
    await tester.tap(_nativeButtonOf('Delete'));
    expect(deletes, 1);
  });

  testWidgets('nested groups coordinate their own members independently', (
    tester,
  ) async {
    final inner = Completer<void>();
    final calls = <String>[];
    await tester.pumpWidget(
      group([
        button('Outer', () => calls.add('Outer')),
        AsyncButtonGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              button('Inner', () {
                calls.add('Inner');

                return inner.future;
              }),
              button('Inner peer', () => calls.add('Inner peer')),
            ],
          ),
        ),
      ]),
    );

    await tester.tap(_nativeButtonOf('Inner'));
    await tester.pump();
    expect(_isEnabled(tester, 'Inner peer'), isFalse);
    expect(_isEnabled(tester, 'Outer'), isTrue);
    await tester.tap(_nativeButtonOf('Outer'));
    expect(calls, ['Inner', 'Outer']);

    inner.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a disposed active button keeps peers blocked until done', (
    tester,
  ) async {
    final operation = Completer<void>();
    var deletes = 0;
    Widget layout({required bool showSave}) => group([
      if (showSave) button('Save', () => operation.future),
      button('Delete', () => deletes++),
    ]);

    await tester.pumpWidget(layout(showSave: true));
    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();
    await tester.pumpWidget(layout(showSave: false));
    await tester.tap(_nativeButtonOf('Delete'), warnIfMissed: false);
    expect(deletes, 0);

    operation.complete();
    await tester.pumpAndSettle();
    await tester.tap(_nativeButtonOf('Delete'));
    expect(deletes, 1);
  });

  testWidgets('stale completions never release a newer group operation', (
    tester,
  ) async {
    final first = Completer<void>();
    final second = Completer<void>();
    final calls = <String>[];
    Widget layout({required Key groupKey}) => MaterialApp(
      home: Scaffold(
        body: AsyncButtonGroup(
          key: groupKey,
          child: Column(
            children: [
              button('Save', () {
                calls.add('Save');

                return calls.length == 1 ? first.future : second.future;
              }),
              button('Delete', () => calls.add('Delete')),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(layout(groupKey: const ValueKey(1)));
    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();

    // Replacing the group remounts its members and releases the old claim.
    await tester.pumpWidget(layout(groupKey: const ValueKey(2)));
    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();
    expect(calls, ['Save', 'Save']);

    first.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(_nativeButtonOf('Delete'), warnIfMissed: false);
    expect(calls, ['Save', 'Save']);

    second.complete();
    await tester.pumpAndSettle();
    await tester.tap(_nativeButtonOf('Delete'));
    expect(calls, ['Save', 'Save', 'Delete']);
  });

  testWidgets('isActiveOf reports pending member work for other widgets', (
    tester,
  ) async {
    final operation = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncButtonGroup(
            child: Column(
              children: [
                button('Save', () => operation.future),
                Builder(
                  builder: (context) => Text(
                    AsyncButtonGroup.isActiveOf(context) ? 'Busy' : 'Idle',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Idle'), findsOneWidget);
    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();
    expect(find.text('Busy'), findsOneWidget);
    operation.complete();
    await tester.pumpAndSettle();
    expect(find.text('Idle'), findsOneWidget);
  });

  testWidgets('isActiveOf is false and buttons are independent without one', (
    tester,
  ) async {
    final operation = Completer<void>();
    var deletes = 0;
    late bool active;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              button('Save', () => operation.future),
              button('Delete', () => deletes++),
              Builder(
                builder: (context) {
                  active = AsyncButtonGroup.isActiveOf(context);

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(_nativeButtonOf('Save'));
    await tester.pump();
    await tester.tap(_nativeButtonOf('Delete'));
    expect(deletes, 1);
    expect(active, isFalse);
    operation.complete();
    await tester.pumpAndSettle();
  });
}
