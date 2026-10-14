// Renders README animations frame by frame. Run `bash tool/screenshots/render.sh`.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

const Duration _frame = Duration(milliseconds: 40);
const Duration _operation = Duration(milliseconds: 1600);
const double _pixelRatio = 2;

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = await File(path).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> _operationDelay() => Future<void>.delayed(_operation);

Future<void> _record(
  WidgetTester tester,
  String name,
  Size size,
  Widget scene,
  Future<void> Function() start,
) async {
  tester.view
    ..physicalSize = size * _pixelRatio
    ..devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.reset);
  // Tests draw shadows as outlines by default; render real elevation.
  debugDisableShadows = false;
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: boundaryKey, child: scene));
  final directory = Directory('build/screenshots/$name')
    ..createSync(recursive: true);
  var index = 0;

  Future<void> capture() async {
    final boundary = boundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('Missing screenshot boundary');
    }
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return data;
    });
    if (bytes == null) throw StateError('Frame $index was not captured');
    File(
      '${directory.path}/${index.toString().padLeft(3, '0')}.png',
    ).writeAsBytesSync(bytes.buffer.asUint8List());
    index++;
  }

  Future<void> frames(int count) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(_frame);
      await capture();
    }
  }

  await frames(12);
  await start();
  await frames(48);
  await frames(14);
  debugDisableShadows = true;
}

Future<void> _tapEach(WidgetTester tester, List<Finder> targets) async {
  for (final target in targets) {
    await tester.tap(target);
    await tester.pump(_frame);
  }
}

Widget _materialApp(Widget body) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(colorSchemeSeed: Colors.indigo),
  home: Scaffold(body: Center(child: body)),
);

void main() {
  setUpAll(() async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
    final materialFonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
    await _loadFont('Roboto', [
      '$materialFonts/Roboto-Regular.ttf',
      '$materialFonts/Roboto-Medium.ttf',
    ]);
    await _loadFont('MaterialIcons', [
      '$materialFonts/MaterialIcons-Regular.otf',
    ]);
    // SF Pro ships with macOS; elsewhere Cupertino frames fall back to Roboto.
    final sfPro = File('/System/Library/Fonts/SFNS.ttf').existsSync()
        ? '/System/Library/Fonts/SFNS.ttf'
        : '$materialFonts/Roboto-Regular.ttf';
    await _loadFont('CupertinoSystemText', [sfPro]);
    await _loadFont('CupertinoSystemDisplay', [sfPro]);
  });

  testWidgets('material', (tester) async {
    await _record(
      tester,
      'material',
      const Size(420, 260),
      _materialApp(
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            const AsyncFilledButton(
              onPressed: _operationDelay,
              child: Text('Filled'),
            ),
            const AsyncFilledButton.tonal(
              onPressed: _operationDelay,
              child: Text('Tonal'),
            ),
            const AsyncElevatedButton(
              onPressed: _operationDelay,
              child: Text('Elevated'),
            ),
            const AsyncOutlinedButton(
              onPressed: _operationDelay,
              child: Text('Outlined'),
            ),
            const AsyncTextButton(
              onPressed: _operationDelay,
              child: Text('Text'),
            ),
            AsyncFilledButton.icon(
              onPressed: _operationDelay,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
            const AsyncIconButton.filled(
              onPressed: _operationDelay,
              icon: Icon(Icons.favorite_border),
            ),
          ],
        ),
      ),
      () => _tapEach(tester, [
        find.text('Filled'),
        find.text('Tonal'),
        find.text('Elevated'),
        find.text('Outlined'),
        find.text('Text'),
        find.text('Save'),
        find.byIcon(Icons.favorite_border),
      ]),
    );
  });

  testWidgets('cupertino', (tester) async {
    await _record(
      tester,
      'cupertino',
      const Size(420, 260),
      const cupertino.CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: cupertino.CupertinoPageScaffold(
          backgroundColor: cupertino.CupertinoColors.systemGroupedBackground,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                AsyncCupertinoButton.filled(
                  onPressed: _operationDelay,
                  child: Text('Filled'),
                ),
                AsyncCupertinoButton.tinted(
                  onPressed: _operationDelay,
                  child: Text('Tinted'),
                ),
                AsyncCupertinoButton(
                  onPressed: _operationDelay,
                  child: Text('Plain'),
                ),
              ],
            ),
          ),
        ),
      ),
      () => _tapEach(tester, [
        find.text('Filled'),
        find.text('Tinted'),
        find.text('Plain'),
      ]),
    );
  });

  testWidgets('adaptive', (tester) async {
    Widget column(String title, TargetPlatform platform) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        AsyncAdaptiveButton.filled(
          platform: platform,
          onPressed: _operationDelay,
          child: Text('Filled ${platform.name}'),
        ),
        AsyncAdaptiveButton.tinted(
          platform: platform,
          onPressed: _operationDelay,
          child: Text('Tinted ${platform.name}'),
        ),
        AsyncAdaptiveButton(
          platform: platform,
          onPressed: _operationDelay,
          child: Text('Default ${platform.name}'),
        ),
      ],
    );

    await _record(
      tester,
      'adaptive',
      const Size(460, 280),
      _materialApp(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            column('Android', TargetPlatform.android),
            column('iOS', TargetPlatform.iOS),
          ],
        ),
      ),
      () => _tapEach(tester, [
        for (final variant in ['Filled', 'Tinted', 'Default'])
          for (final platform in ['android', 'iOS'])
            find.text('$variant $platform'),
      ]),
    );
  });

  testWidgets('group', (tester) async {
    await _record(
      tester,
      'group',
      const Size(420, 160),
      _materialApp(
        AsyncButtonGroup(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const AsyncFilledButton(
                onPressed: _operationDelay,
                child: Text('Save'),
              ),
              const AsyncOutlinedButton(
                onPressed: _operationDelay,
                child: Text('Delete'),
              ),
              AsyncTextButton(
                excludeFromGroup: true,
                onPressed: () {},
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      () async {
        await tester.tap(find.text('Save'));
        await tester.pump(_frame);
        // Delete is blocked while Save runs; this tap does nothing.
        await tester.tap(find.text('Delete'), warnIfMissed: false);
      },
    );
  });
}
