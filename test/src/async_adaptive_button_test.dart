import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

typedef _AdaptiveBuilder =
    Widget Function({
      required Widget child,
      required FutureOr<void> Function()? onPressed,
      Widget? loadingChild,
      AsyncButtonController? controller,
      AsyncButtonErrorHandler? onError,
      TargetPlatform? platform,
      Color? backgroundColor,
      ButtonStyle? materialStyle,
      cupertino.CupertinoButtonSize cupertinoSizeStyle,
    });

// An adaptive constructor and the concrete widgets it should render.
typedef _VariantCase = ({
  _AdaptiveBuilder adaptive,
  Widget Function(Widget child) material,
  Widget Function(Widget child) cupertino,
});

const Set<TargetPlatform> _cupertinoPlatforms = {
  TargetPlatform.iOS,
  TargetPlatform.macOS,
};

final Map<String, _VariantCase> _variants = {
  'default': (
    adaptive: AsyncAdaptiveButton.new,
    material: (child) => AsyncTextButton(onPressed: () {}, child: child),
    cupertino: (child) => AsyncCupertinoButton(onPressed: () {}, child: child),
  ),
  'filled': (
    adaptive: AsyncAdaptiveButton.filled,
    material: (child) => AsyncFilledButton(onPressed: () {}, child: child),
    cupertino: (child) =>
        AsyncCupertinoButton.filled(onPressed: () {}, child: child),
  ),
  'tinted': (
    adaptive: AsyncAdaptiveButton.tinted,
    material: (child) =>
        AsyncFilledButton.tonal(onPressed: () {}, child: child),
    cupertino: (child) =>
        AsyncCupertinoButton.tinted(onPressed: () {}, child: child),
  ),
};

Widget _host(Widget button, {TargetPlatform? platform}) => MaterialApp(
  theme: ThemeData(platform: platform),
  home: Scaffold(body: Center(child: button)),
);

Finder get _native => find
    .byWidgetPredicate(
      (widget) =>
          widget is cupertino.CupertinoButton || widget is ButtonStyleButton,
    )
    .first;

// The rendered background identifies the native variant without relying on
// private constructor state.
Color? _background(WidgetTester tester) {
  final material = find.descendant(
    of: _native,
    matching: find.byType(Material),
  );
  if (material.evaluate().isNotEmpty) {
    return tester.widget<Material>(material.first).color;
  }
  final boxes = find.descendant(
    of: _native,
    matching: find.byType(DecoratedBox),
  );
  for (final element in boxes.evaluate()) {
    final decoration = (element.widget as DecoratedBox).decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      return decoration.color;
    }
    if (decoration is ShapeDecoration && decoration.color != null) {
      return decoration.color;
    }
  }

  return null;
}

void main() {
  for (final variant in _variants.entries) {
    for (final platform in TargetPlatform.values) {
      final isCupertino = _cupertinoPlatforms.contains(platform);
      testWidgets(
        '${variant.key} renders ${isCupertino ? 'Cupertino' : 'Material'} '
        'on ${platform.name}',
        (tester) async {
          const label = Text('Run');
          final expected = isCupertino
              ? variant.value.cupertino(label)
              : variant.value.material(label);
          await tester.pumpWidget(_host(expected, platform: platform));
          final expectedBackground = _background(tester);

          await tester.pumpWidget(
            _host(
              variant.value.adaptive(child: label, onPressed: () {}),
              platform: platform,
            ),
          );
          expect(find.byType(expected.runtimeType), findsOneWidget);
          expect(_background(tester), expectedBackground);
        },
      );
    }
  }

  testWidgets('platform overrides the theme platform', (tester) async {
    await tester.pumpWidget(
      _host(
        AsyncAdaptiveButton(
          platform: TargetPlatform.iOS,
          onPressed: () {},
          child: const Text('Run'),
        ),
        platform: TargetPlatform.android,
      ),
    );
    expect(find.byType(AsyncCupertinoButton), findsOneWidget);
  });

  testWidgets(
    'follows the default platform under CupertinoApp without Material',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: Center(
            child: AsyncAdaptiveButton.filled(
              onPressed: () => calls++,
              child: const Text('Run'),
            ),
          ),
        ),
      );
      expect(find.byType(AsyncCupertinoButton), findsOneWidget);
      await tester.tap(_native);
      expect(calls, 1);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('a theme platform change mid-operation keeps the lock', (
    tester,
  ) async {
    final operation = Completer<void>();
    final handled = <Object>[];
    var calls = 0;
    Widget build(TargetPlatform platform) => _host(
      AsyncAdaptiveButton.filled(
        loadingChild: const Text('Busy'),
        onPressed: () {
          calls++;

          return calls == 1 ? operation.future : null;
        },
        onError: (error, _) => handled.add(error),
        child: const Text('Run'),
      ),
      platform: platform,
    );

    await tester.pumpWidget(build(TargetPlatform.android));
    await tester.tap(_native);
    await tester.pump();
    expect(find.text('Busy'), findsOneWidget);

    await tester.pumpWidget(build(TargetPlatform.iOS));
    await tester.pumpAndSettle();
    expect(find.byType(AsyncCupertinoButton), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
    await tester.tap(_native, warnIfMissed: false);
    expect(calls, 1);

    // The original activation still owns completion and error handling.
    operation.completeError(StateError('failed'));
    await tester.pumpAndSettle();
    expect(handled, hasLength(1));
    expect(find.text('Busy'), findsNothing);
    await tester.tap(_native);
    expect(calls, 2);
  });

  testWidgets('a supplied controller observes work across platforms', (
    tester,
  ) async {
    final controller = AsyncButtonController();
    addTearDown(controller.dispose);
    final operation = Completer<void>();
    Widget build(TargetPlatform platform) => _host(
      AsyncAdaptiveButton(
        platform: platform,
        controller: controller,
        loadingChild: const Text('Busy'),
        onPressed: () => operation.future,
        child: const Text('Run'),
      ),
    );

    await tester.pumpWidget(build(TargetPlatform.iOS));
    await tester.tap(_native);
    await tester.pump();
    expect(controller.isPending, isTrue);

    await tester.pumpWidget(build(TargetPlatform.windows));
    expect(find.byType(AsyncTextButton), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);

    operation.complete();
    await tester.pumpAndSettle();
    expect(controller.isPending, isFalse);
    expect(find.text('Busy'), findsNothing);
  });

  testWidgets('keeps group peers blocked across a platform change', (
    tester,
  ) async {
    final operation = Completer<void>();
    var deletes = 0;
    Widget build(TargetPlatform platform) => _host(
      AsyncButtonGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AsyncAdaptiveButton.filled(
              platform: platform,
              onPressed: () => operation.future,
              child: const Text('Save'),
            ),
            AsyncAdaptiveButton(
              platform: platform,
              onPressed: () => deletes++,
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(build(TargetPlatform.android));
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpWidget(build(TargetPlatform.macOS));
    await tester.tap(find.text('Delete'), warnIfMissed: false);
    expect(deletes, 0);

    operation.complete();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    expect(deletes, 1);
  });

  testWidgets('applies shared colors on both platforms', (tester) async {
    const color = Color(0xFF00897B);
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      await tester.pumpWidget(
        _host(
          AsyncAdaptiveButton(
            platform: platform,
            backgroundColor: color,
            onPressed: () {},
            child: const Text('Run'),
          ),
        ),
      );
      expect(_background(tester), color, reason: platform.name);
    }
  });

  testWidgets('scoped options reach only their own design system', (
    tester,
  ) async {
    const styled = Color(0xFF6A1B9A);
    Widget build(TargetPlatform platform) => _host(
      AsyncAdaptiveButton(
        platform: platform,
        materialStyle: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(styled),
        ),
        cupertinoSizeStyle: cupertino.CupertinoButtonSize.small,
        onPressed: () {},
        child: const Text('Run'),
      ),
    );

    await tester.pumpWidget(build(TargetPlatform.android));
    expect(_background(tester), styled);

    await tester.pumpWidget(build(TargetPlatform.iOS));
    expect(
      tester.widget<cupertino.CupertinoButton>(_native).sizeStyle,
      cupertino.CupertinoButtonSize.small,
    );
    expect(_background(tester), isNot(styled));
  });

  testWidgets('disposing mid-operation leaves completion harmless', (
    tester,
  ) async {
    final operation = Completer<void>();
    await tester.pumpWidget(
      _host(
        AsyncAdaptiveButton(
          onPressed: () => operation.future,
          child: const Text('Run'),
        ),
      ),
    );
    await tester.tap(_native);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    operation.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
