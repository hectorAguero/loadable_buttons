import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/rendering.dart' show RendererBinding;
import 'package:flutter/services.dart' show MouseCursorSession;
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/material.dart';
import 'package:material_ui/material_ui.dart';

typedef _AsyncBuilder =
    Widget Function({
      required Widget child,
      required VoidCallback? onPressed,
      bool loading,
      ButtonStyle? style,
      EdgeInsetsGeometry? padding,
      Size? minimumSize,
      AlignmentGeometry? alignment,
      Color? backgroundColor,
      Color? foregroundColor,
      Color? disabledBackgroundColor,
      Color? disabledForegroundColor,
      MouseCursor? mouseCursor,
    });

typedef _AsyncIconBuilder =
    Widget Function({
      required Widget label,
      required VoidCallback? onPressed,
      Widget? icon,
      bool loading,
      ButtonStyle? style,
      EdgeInsetsGeometry? padding,
      Size? minimumSize,
      AlignmentGeometry? alignment,
      Color? backgroundColor,
      Color? foregroundColor,
      Color? disabledBackgroundColor,
      Color? disabledForegroundColor,
      MouseCursor? mouseCursor,
    });

typedef _NativeBuilder =
    Widget Function({
      required Widget child,
      required VoidCallback? onPressed,
      ButtonStyle? style,
    });

typedef _NativeIconBuilder =
    Widget Function({
      required Widget label,
      required VoidCallback? onPressed,
      Widget? icon,
      ButtonStyle? style,
    });

typedef _Buttons = ({_AsyncBuilder asyncButton, _NativeBuilder nativeButton});

final _buttons = <String, _Buttons>{
  'Elevated': (
    asyncButton: AsyncElevatedButton.new,
    nativeButton: ElevatedButton.new,
  ),
  'Filled': (
    asyncButton: AsyncFilledButton.new,
    nativeButton: FilledButton.new,
  ),
  'Filled.tonal': (
    asyncButton: AsyncFilledButton.tonal,
    nativeButton: FilledButton.tonal,
  ),
  'Outlined': (
    asyncButton: AsyncOutlinedButton.new,
    nativeButton: OutlinedButton.new,
  ),
  'Text': (asyncButton: AsyncTextButton.new, nativeButton: TextButton.new),
  for (final icon in <Widget?>[const Icon(Icons.save), null]) ...{
    'Elevated.icon icon=$icon': _withIcon(
      AsyncElevatedButton.icon,
      ElevatedButton.icon,
      icon,
    ),
    'Filled.icon icon=$icon': _withIcon(
      AsyncFilledButton.icon,
      FilledButton.icon,
      icon,
    ),
    'Filled.tonalIcon icon=$icon': _withIcon(
      AsyncFilledButton.tonalIcon,
      FilledButton.tonalIcon,
      icon,
    ),
    'Outlined.icon icon=$icon': _withIcon(
      AsyncOutlinedButton.icon,
      OutlinedButton.icon,
      icon,
    ),
    'Text.icon icon=$icon': _withIcon(
      AsyncTextButton.icon,
      TextButton.icon,
      icon,
    ),
  },
};

const Key _nativeKey = ValueKey('native');
const Key _asyncKey = ValueKey('async');
const _padding = EdgeInsetsDirectional.fromSTEB(30, 8, 46, 12);
const _minimumSize = Size(240, 72);

const _style = ButtonStyle(
  backgroundColor: WidgetStateProperty.fromMap({
    WidgetState.disabled: Colors.grey,
    WidgetState.any: Colors.blue,
  }),
  foregroundColor: WidgetStateProperty.fromMap({
    WidgetState.disabled: Colors.black,
    WidgetState.any: Colors.white,
  }),
  iconColor: WidgetStateProperty.fromMap({
    WidgetState.disabled: null,
    WidgetState.any: Colors.cyan,
  }),
  overlayColor: WidgetStateProperty.fromMap({
    WidgetState.pressed: Colors.red,
    WidgetState.hovered: Colors.orange,
    WidgetState.focused: Colors.yellow,
  }),
  padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
  minimumSize: WidgetStatePropertyAll(Size(80, 40)),
  alignment: Alignment.centerLeft,
  shape: WidgetStatePropertyAll(StadiumBorder()),
  side: WidgetStatePropertyAll(BorderSide(color: Colors.pink, width: 2)),
  elevation: WidgetStatePropertyAll(3),
  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
  splashFactory: NoSplash.splashFactory,
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.padded,
  mouseCursor: WidgetStateProperty.fromMap({
    WidgetState.disabled: SystemMouseCursors.forbidden,
    WidgetState.any: SystemMouseCursors.help,
  }),
);

void main() {
  for (final entry in _buttons.entries) {
    testWidgets('${entry.key} shortcuts preserve native layout and feedback', (
      tester,
    ) async {
      // Native ButtonStyle is the independent reference for density, tap
      // targets, RTL, text scaling, icon padding, and untouched presentation.
      final style = _style.copyWith(
        backgroundBuilder: (_, _, child) => Padding(
          padding: const EdgeInsets.all(3),
          child: child,
        ),
        foregroundBuilder: (_, _, child) => Padding(
          padding: const EdgeInsets.all(5),
          child: child,
        ),
      );
      final reference = style.copyWith(
        padding: const WidgetStatePropertyAll(_padding),
        minimumSize: const WidgetStatePropertyAll(_minimumSize),
        alignment: AlignmentDirectional.centerEnd,
        backgroundColor: const WidgetStateProperty.fromMap({
          WidgetState.disabled: Colors.purple,
          WidgetState.any: Colors.green,
        }),
        foregroundColor: const WidgetStateProperty.fromMap({
          WidgetState.disabled: Colors.pink,
          WidgetState.any: Colors.amber,
        }),
      );
      for (final direction in TextDirection.values) {
        for (final state in ['enabled', 'disabled', 'loading']) {
          final onPressed = state == 'disabled' ? null : () {};
          await tester.pumpWidget(
            _host(
              entry.value.asyncButton(
                child: const Text('Save'),
                onPressed: onPressed,
                loading: state == 'loading',
                style: style,
                padding: _padding,
                minimumSize: _minimumSize,
                alignment: AlignmentDirectional.centerEnd,
                backgroundColor: Colors.green,
                foregroundColor: Colors.amber,
                disabledBackgroundColor: Colors.purple,
                disabledForegroundColor: Colors.pink,
              ),
              nativeButton: entry.value.nativeButton(
                child: const Text('Save'),
                onPressed: state == 'enabled' ? () {} : null,
                style: reference,
              ),
              direction: direction,
              scale: 2,
            ),
          );
          await tester.pump(kThemeAnimationDuration);
          expect(
            _appearance(tester, _asyncKey),
            _appearance(tester, _nativeKey),
          );
          final ink = tester.widget<InkWell>(
            _within(_asyncKey, find.byType(InkWell)),
          );
          for (final interaction in [
            WidgetState.pressed,
            WidgetState.hovered,
            WidgetState.focused,
          ]) {
            expect(
              ink.overlayColor?.resolve({interaction}),
              _style.overlayColor?.resolve({interaction}),
            );
          }
          expect(ink.splashFactory, NoSplash.splashFactory);
          if (state == 'loading') {
            expect(
              tester
                  .widget<CircularProgressIndicator>(
                    find.byType(CircularProgressIndicator),
                  )
                  .color,
              Colors.amber,
            );
            // Stack content covers the full native button, including the
            // asymmetric shortcut padding and directional alignment.
            expect(
              tester.getCenter(find.byType(CircularProgressIndicator)),
              tester.getCenter(_within(_asyncKey, find.byType(Material))),
            );
          }
        }
      }
    });

    testWidgets('${entry.key} color overrides preserve the other state', (
      tester,
    ) async {
      const theme = ButtonStyle(
        backgroundColor: WidgetStateProperty.fromMap({
          WidgetState.disabled: Colors.brown,
          WidgetState.any: Colors.teal,
        }),
        foregroundColor: WidgetStateProperty.fromMap({
          WidgetState.disabled: Colors.indigo,
          WidgetState.any: Colors.lime,
        }),
        iconColor: WidgetStatePropertyAll(Colors.orange),
      );
      final partialStyle = ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? null : Colors.blue,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? null : Colors.white,
        ),
      );
      for (final source in ['style', 'partial style', 'theme', 'native']) {
        final style = source == 'style'
            ? _style
            : source == 'partial style'
            ? partialStyle
            : const ButtonStyle();
        for (final enabledOverride in [true, false]) {
          for (final disabled in [false, true]) {
            final onPressed = disabled ? null : () {};
            final overridden = enabledOverride != disabled;
            await tester.pumpWidget(
              _host(
                entry.value.asyncButton(
                  child: const Text('Save'),
                  onPressed: onPressed,
                  style: style,
                  backgroundColor: enabledOverride ? Colors.green : null,
                  foregroundColor: enabledOverride ? Colors.amber : null,
                  disabledBackgroundColor: enabledOverride
                      ? null
                      : Colors.purple,
                  disabledForegroundColor: enabledOverride ? null : Colors.pink,
                ),
                nativeButton: entry.value.nativeButton(
                  child: const Text('Save'),
                  onPressed: onPressed,
                  style: overridden
                      ? style.copyWith(
                          backgroundColor: WidgetStatePropertyAll(
                            disabled ? Colors.purple : Colors.green,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            disabled ? Colors.pink : Colors.amber,
                          ),
                        )
                      : style,
                ),
                themeStyle: source == 'native' ? null : theme,
              ),
            );
            await tester.pump(kThemeAnimationDuration);
            expect(
              _appearance(tester, _asyncKey),
              _appearance(tester, _nativeKey),
            );
          }
        }
      }
    });

    testWidgets(
      '${entry.key} cursor resolves shortcut, style, theme, default',
      (
        tester,
      ) async {
        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );
        await mouse.addPointer();
        addTearDown(mouse.removePointer);
        for (final source in ['style', 'theme', 'native']) {
          for (final disabled in [false, true]) {
            for (final cursor in <MouseCursor>[
              SystemMouseCursors.text,
              WidgetStateMouseCursor.clickable,
              const _PartialCursor(),
            ]) {
              await tester.pumpWidget(
                _host(
                  entry.value.asyncButton(
                    child: const Text('Save'),
                    onPressed: disabled ? null : () {},
                    style: source == 'style' ? _style : null,
                    mouseCursor: cursor,
                  ),
                  themeStyle: source == 'theme'
                      ? const ButtonStyle(
                          mouseCursor: WidgetStatePropertyAll(
                            SystemMouseCursors.move,
                          ),
                        )
                      : null,
                ),
              );
              await tester.pump(kThemeAnimationDuration);
              await mouse.moveTo(tester.getCenter(find.text('Save')));
              await tester.pump();
              final expected = cursor is _PartialCursor
                  ? disabled
                        ? source == 'style'
                              ? SystemMouseCursors.forbidden
                              : source == 'theme'
                              ? SystemMouseCursors.move
                              : SystemMouseCursors.basic
                        : SystemMouseCursors.precise
                  : cursor == WidgetStateMouseCursor.clickable
                  ? disabled
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click
                  : SystemMouseCursors.text;
              expect(
                RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(
                  1,
                ),
                expected,
              );
            }
          }
        }
      },
    );
  }
}

// A supported MouseCursor that resolves null for one state, exercising the
// supplied-style fallback before Material's own theme/default resolution.
class _PartialCursor extends MouseCursor
    implements WidgetStateProperty<MouseCursor?> {
  const _PartialCursor();

  @override
  MouseCursor? resolve(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled) ? null : SystemMouseCursors.precise;

  @override
  MouseCursorSession createSession(int device) =>
      throw UnsupportedError('Resolve this cursor before creating a session');

  @override
  String get debugDescription => 'Partial cursor';
}

_Buttons _withIcon(
  _AsyncIconBuilder asyncButton,
  _NativeIconBuilder nativeButton,
  Widget? icon,
) => (
  asyncButton:
      ({
        required child,
        required onPressed,
        loading = false,
        style,
        padding,
        minimumSize,
        alignment,
        backgroundColor,
        foregroundColor,
        disabledBackgroundColor,
        disabledForegroundColor,
        mouseCursor,
      }) => asyncButton(
        label: child,
        icon: icon,
        onPressed: onPressed,
        loading: loading,
        style: style,
        padding: padding,
        minimumSize: minimumSize,
        alignment: alignment,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        disabledForegroundColor: disabledForegroundColor,
        mouseCursor: mouseCursor,
      ),
  nativeButton: ({required child, required onPressed, style}) => nativeButton(
    label: child,
    icon: icon,
    onPressed: onPressed,
    style: style,
  ),
);

Widget _host(
  Widget button, {
  Widget? nativeButton,
  ButtonStyle? themeStyle,
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) => MaterialApp(
  theme: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(style: themeStyle),
    filledButtonTheme: FilledButtonThemeData(style: themeStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: themeStyle),
    textButtonTheme: TextButtonThemeData(style: themeStyle),
  ),
  home: Scaffold(
    body: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Directionality(
        textDirection: direction,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nativeButton != null)
                KeyedSubtree(key: _nativeKey, child: nativeButton),
              KeyedSubtree(key: _asyncKey, child: button),
            ],
          ),
        ),
      ),
    ),
  ),
);

Finder _within(Key key, Finder matching) =>
    find.descendant(of: find.byKey(key), matching: matching);

({
  Color? background,
  TextStyle text,
  Color? icon,
  ShapeBorder? shape,
  double elevation,
  Size size,
  Offset labelInset,
})
_appearance(WidgetTester tester, Key key) {
  final label = _within(key, find.text('Save'));
  final material = tester.widget<Material>(_within(key, find.byType(Material)));
  final buttonRect = tester.getRect(
    _within(
      key,
      find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    ),
  );
  final icon = _within(key, find.byIcon(Icons.save));

  return (
    background: material.color,
    text: DefaultTextStyle.of(tester.element(label)).style,
    icon: icon.evaluate().isEmpty
        ? null
        : IconTheme.of(tester.element(icon)).color,
    shape: material.shape,
    elevation: material.elevation,
    size: buttonRect.size,
    labelInset: tester.getTopLeft(label) - buttonRect.topLeft,
  );
}
