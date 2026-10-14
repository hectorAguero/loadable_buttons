import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../support/async_button_fixture.dart';

Map<String, DiagnosticsNode> _properties(Diagnosticable target) => {
  for (final property in target.toDiagnosticsNode().getProperties())
    if (property.name case final String name) name: property,
};

// Returns the property text as the inspector shows it, or null when hidden
// because the value matches its default.
String? _shown(Diagnosticable target, String name) {
  final property = _properties(target)[name];
  if (property == null || property.isFiltered(DiagnosticLevel.info)) {
    return null;
  }

  return property.toDescription();
}

void main() {
  // Every constructor describes the shared async contract.
  for (final entry in asyncButtonConstructorBuilders.entries) {
    test('${entry.key} describes the async contract', () {
      final controller = AsyncButtonController();
      addTearDown(controller.dispose);
      final button = entry.value(
        child: const Text('Run'),
        onPressed: () {},
        onError: (_, _) {},
        controller: controller,
        excludeFromGroup: true,
        loading: true,
        loadingSemanticsLabel: 'Saving',
        transitionType: TransitionAnimationType.animatedSwitcher,
        minimumChildOpacity: 0.5,
      );

      expect(_shown(button, 'enabled'), isNull);
      expect(_shown(button, 'onError'), isNotNull);
      expect(_shown(button, 'controller'), isNotNull);
      expect(_shown(button, 'excludeFromGroup'), 'excluded from group');
      expect(_shown(button, 'loading'), 'loading requested');
      expect(_shown(button, 'loadingSemanticsLabel'), '"Saving"');
      expect(_shown(button, 'transitionType'), 'animatedSwitcher');
      expect(_shown(button, 'minimumChildOpacity'), '0.5');

      // Defaults stay out of the inspector summary.
      final idle = entry.value(child: const Text('Run'), onPressed: null);
      expect(_shown(idle, 'enabled'), 'disabled');
      expect(_shown(idle, 'loading'), isNull);
      expect(_shown(idle, 'transitionType'), isNull);
      expect(_shown(idle, 'animationDuration'), isNull);
    });
  }

  test('Material families describe their style shortcuts', () {
    const padding = EdgeInsets.all(7);
    final buttons = <Diagnosticable>[
      AsyncElevatedButton(
        onPressed: () {},
        padding: padding,
        child: const Text('Run'),
      ),
      AsyncFilledButton.tonal(
        onPressed: () {},
        padding: padding,
        child: const Text('Run'),
      ),
      AsyncOutlinedButton(
        onPressed: () {},
        padding: padding,
        child: const Text('Run'),
      ),
      AsyncTextButton(
        onPressed: () {},
        padding: padding,
        child: const Text('Run'),
      ),
    ];
    for (final button in buttons) {
      expect(_shown(button, 'padding'), padding.toString());
    }
  });

  test('family-specific properties are described', () {
    expect(
      _shown(
        AsyncCupertinoButton.filled(
          onPressed: () {},
          sizeStyle: cupertino.CupertinoButtonSize.small,
          child: const Text('Run'),
        ),
        'sizeStyle',
      ),
      'small',
    );
    expect(
      _shown(
        AsyncIconButton(
          onPressed: () {},
          tooltip: 'Favorite',
          icon: const Icon(Icons.favorite),
        ),
        'tooltip',
      ),
      '"Favorite"',
    );
    expect(
      _shown(
        AsyncFloatingActionButton.small(
          onPressed: () {},
          heroTag: 'save',
          child: const Icon(Icons.save),
        ),
        'heroTag',
      ),
      'save',
    );
    expect(
      _shown(
        AsyncAdaptiveButton(
          onPressed: () {},
          platform: TargetPlatform.iOS,
          child: const Text('Run'),
        ),
        'platform',
      ),
      'iOS',
    );
  });

  testWidgets('the state describes effective runtime loading and blocking', (
    tester,
  ) async {
    final operation = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncButtonGroup(
            child: Column(
              children: [
                AsyncTextButton(
                  key: const ValueKey('save'),
                  onPressed: () => operation.future,
                  child: const Text('Save'),
                ),
                AsyncTextButton(
                  key: const ValueKey('delete'),
                  onPressed: () {},
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    State<StatefulWidget> state(String key) =>
        tester.state(find.byKey(ValueKey(key)));

    expect(_shown(state('save'), 'isLoading'), isNull);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(_shown(state('save'), 'isLoading'), 'loading');
    expect(_shown(state('save'), 'operationPending'), 'operation pending');
    expect(_shown(state('delete'), 'blockedByGroup'), 'blocked by group');
    expect(_shown(state('delete'), 'isLoading'), isNull);

    operation.complete();
    await tester.pumpAndSettle();
    expect(_shown(state('delete'), 'blockedByGroup'), isNull);
  });
}
