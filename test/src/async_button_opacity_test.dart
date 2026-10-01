import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/async_button_fixture.dart';

void main() {
  for (final name in ['Icon', 'Floating action']) {
    testWidgets('$name paints minimumChildOpacity and restores idle content',
        (tester) async {
      final builder = asyncButtonBuilders[name];
      if (builder == null) fail('Missing $name fixture');
      const boundaryKey = ValueKey('capture');
      const contentKey = ValueKey('painted content');
      Widget host(bool loading, double opacity) => RepaintBoundary(
            key: boundaryKey,
            child: buttonHost(builder(
              child: const SizedBox(
                key: contentKey,
                width: 16,
                height: 16,
                child: ColoredBox(color: Colors.red),
              ),
              onPressed: () {},
              loading: loading,
              minimumChildOpacity: opacity,
              loadingChild: const SizedBox.shrink(),
            )),
          );
      Future<int> paintedGreen() async {
        final boundary =
            tester.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
        final position = tester.getCenter(find.byKey(contentKey)) -
            tester.getTopLeft(find.byKey(boundaryKey));
        final green = await tester.runAsync(() async {
          final image = await boundary.toImage();
          try {
            final pixels =
                await image.toByteData(format: ui.ImageByteFormat.rawRgba);
            if (pixels == null) fail('No rendered pixels');

            return pixels.getUint8(
                (position.dy.floor() * image.width + position.dx.floor()) * 4 +
                    1);
          } finally {
            image.dispose();
          }
        });
        if (green == null) fail('Pixel capture did not complete');

        return green;
      }

      await tester.pumpWidget(host(false, 0.3));
      await tester.pumpAndSettle();
      final idle = await paintedGreen();
      await tester.pumpWidget(host(true, 0.3));
      await tester.pumpAndSettle();
      final faint = await paintedGreen();
      await tester.pumpWidget(host(true, 0.0));
      await tester.pumpAndSettle();
      final background = await paintedGreen();
      // Compare the painted blend, independent of the transition widgets.
      expect(idle, lessThan(background));
      expect(faint, closeTo(idle * 0.3 + background * 0.7, 2));
      await tester.pumpWidget(host(false, 0.3));
      await tester.pumpAndSettle();
      expect(await paintedGreen(), idle);
    });
  }
}
