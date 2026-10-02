import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show MouseCursorSession;
import 'package:flutter_test/flutter_test.dart';
import 'package:loadable_buttons/loadable_buttons.dart';
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
      InteractiveInkFeatureFactory? splashFactory,
    });

typedef _AsyncLabelBuilder =
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
      InteractiveInkFeatureFactory? splashFactory,
    });

typedef _NativeBuilder =
    Widget Function({
      required Widget child,
      required VoidCallback? onPressed,
      ButtonStyle? style,
    });

typedef _NativeLabelBuilder =
    Widget Function({
      required Widget label,
      required VoidCallback? onPressed,
      Widget? icon,
      ButtonStyle? style,
    });

typedef _Variant = ({
  _AsyncBuilder asyncButton,
  _NativeBuilder nativeButton,
  bool hasIcon,
});

typedef _StateColors = ({Color? enabled, Color? disabled});

typedef _ColorCase = ({_StateColors background, _StateColors foreground});

enum _ButtonState { enabled, disabled, loading }

const _label = 'Save changes';
const _icon = Icon(Icons.save);

final _variants = <String, _Variant>{
  'Elevated': (
    asyncButton: AsyncElevatedButton.new,
    nativeButton: ElevatedButton.new,
    hasIcon: false,
  ),
  'Elevated.icon': (
    asyncButton: _asyncLabel(AsyncElevatedButton.icon),
    nativeButton: _nativeLabel(ElevatedButton.icon),
    hasIcon: true,
  ),
  'Elevated.icon without icon': (
    asyncButton: _asyncLabel(AsyncElevatedButton.icon, icon: null),
    nativeButton: ElevatedButton.new,
    hasIcon: false,
  ),
  'Filled': (
    asyncButton: AsyncFilledButton.new,
    nativeButton: FilledButton.new,
    hasIcon: false,
  ),
  'Filled.icon': (
    asyncButton: _asyncLabel(AsyncFilledButton.icon),
    nativeButton: _nativeLabel(FilledButton.icon),
    hasIcon: true,
  ),
  'Filled.icon without icon': (
    asyncButton: _asyncLabel(AsyncFilledButton.icon, icon: null),
    nativeButton: FilledButton.new,
    hasIcon: false,
  ),
  'Filled.tonal': (
    asyncButton: AsyncFilledButton.tonal,
    nativeButton: FilledButton.tonal,
    hasIcon: false,
  ),
  'Filled.tonalIcon': (
    asyncButton: _asyncLabel(AsyncFilledButton.tonalIcon),
    nativeButton: _nativeLabel(FilledButton.tonalIcon),
    hasIcon: true,
  ),
  'Filled.tonalIcon without icon': (
    asyncButton: _asyncLabel(AsyncFilledButton.tonalIcon, icon: null),
    nativeButton: FilledButton.tonal,
    hasIcon: false,
  ),
  'Outlined': (
    asyncButton: AsyncOutlinedButton.new,
    nativeButton: OutlinedButton.new,
    hasIcon: false,
  ),
  'Outlined.icon': (
    asyncButton: _asyncLabel(AsyncOutlinedButton.icon),
    nativeButton: _nativeLabel(OutlinedButton.icon),
    hasIcon: true,
  ),
  'Outlined.icon without icon': (
    asyncButton: _asyncLabel(AsyncOutlinedButton.icon, icon: null),
    nativeButton: OutlinedButton.new,
    hasIcon: false,
  ),
  'Text': (
    asyncButton: AsyncTextButton.new,
    nativeButton: TextButton.new,
    hasIcon: false,
  ),
  'Text.icon': (
    asyncButton: _asyncLabel(AsyncTextButton.icon),
    nativeButton: _nativeLabel(TextButton.icon),
    hasIcon: true,
  ),
  'Text.icon without icon': (
    asyncButton: _asyncLabel(AsyncTextButton.icon, icon: null),
    nativeButton: TextButton.new,
    hasIcon: false,
  ),
};

const _StateColors _themeBackground = (
  enabled: Color(0xFF100000),
  disabled: Color(0xFF200000),
);
const _StateColors _themeForeground = (
  enabled: Color(0xFF001000),
  disabled: Color(0xFF002000),
);
const _StateColors _styleBackground = (
  enabled: Color(0xFF300000),
  disabled: Color(0xFF400000),
);
const _StateColors _styleForeground = (
  enabled: Color(0xFF003000),
  disabled: Color(0xFF004000),
);
const _StateColors _shortcutBackground = (
  enabled: Color(0xFF500000),
  disabled: Color(0xFF600000),
);
const _StateColors _shortcutForeground = (
  enabled: Color(0xFF005000),
  disabled: Color(0xFF006000),
);

void main() {
  for (final MapEntry(key: name, value: variant) in _variants.entries) {
    group(name, () {
      _colorPrecedenceTests(variant);
      _layoutTests(variant);
      _untouchedStyleTests(variant);
      _mouseCursorTests(variant);
    });
  }
}

void _colorPrecedenceTests(_Variant variant) {
  // Partial style resolvers return null for enabled states, which must still
  // reach the family theme instead of being replaced by a shallow merge.
  final styles = <String, _ColorCase?>{
    'no style': null,
    'partial style': (
      background: (enabled: null, disabled: _styleBackground.disabled),
      foreground: (enabled: null, disabled: _styleForeground.disabled),
    ),
    'full style': (background: _styleBackground, foreground: _styleForeground),
  };
  final shortcutCases = <String, _ColorCase>{
    'no shortcuts': (
      background: (enabled: null, disabled: null),
      foreground: (enabled: null, disabled: null),
    ),
    'enabled shortcuts': (
      background: (enabled: _shortcutBackground.enabled, disabled: null),
      foreground: (enabled: _shortcutForeground.enabled, disabled: null),
    ),
    'disabled shortcuts': (
      background: (enabled: null, disabled: _shortcutBackground.disabled),
      foreground: (enabled: null, disabled: _shortcutForeground.disabled),
    ),
    'all color shortcuts': (
      background: _shortcutBackground,
      foreground: _shortcutForeground,
    ),
  };

  for (final MapEntry(key: styleName, value: style) in styles.entries) {
    for (final MapEntry(key: shortcutName, value: shortcuts)
        in shortcutCases.entries) {
      testWidgets('$shortcutName with $styleName resolve per state', (
        tester,
      ) async {
        for (final state in _ButtonState.values) {
          await _pumpButtons(
            tester,
            asyncButton: variant.asyncButton(
              child: const Text(_label),
              onPressed: state == _ButtonState.disabled ? null : () {},
              loading: state == _ButtonState.loading,
              style: style == null
                  ? null
                  : ButtonStyle(
                      backgroundColor: _stateProperty(style.background),
                      foregroundColor: _stateProperty(style.foreground),
                    ),
              backgroundColor: shortcuts.background.enabled,
              foregroundColor: shortcuts.foreground.enabled,
              disabledBackgroundColor: shortcuts.background.disabled,
              disabledForegroundColor: shortcuts.foreground.disabled,
            ),
            themeStyle: ButtonStyle(
              backgroundColor: _stateProperty(_themeBackground),
              foregroundColor: _stateProperty(_themeForeground),
            ),
          );

          Color? expected(
            _StateColors shortcut,
            _StateColors? supplied,
            _StateColors theme, {
            required bool disabled,
          }) => disabled
              ? shortcut.disabled ?? supplied?.disabled ?? theme.disabled
              : shortcut.enabled ?? supplied?.enabled ?? theme.enabled;

          final disabled = state != _ButtonState.enabled;
          final background = expected(
            shortcuts.background,
            style?.background,
            _themeBackground,
            disabled: disabled,
          );
          final foreground = expected(
            shortcuts.foreground,
            style?.foreground,
            _themeForeground,
            disabled: disabled,
          );
          expect(
            _buttonMaterial(tester, _asyncKey).color,
            background,
            reason: '$state background',
          );

          if (state == _ButtonState.loading) {
            // The default indicator resolves the idle foreground, so loading
            // still reflects the combined enabled shortcut and supplied style.
            expect(
              tester
                  .widget<CircularProgressIndicator>(
                    find.byType(CircularProgressIndicator),
                  )
                  .color,
              expected(
                shortcuts.foreground,
                style?.foreground,
                _themeForeground,
                disabled: false,
              ),
            );
            continue;
          }

          expect(
            _textColor(tester, find.text(_label)),
            foreground,
            reason: '$state label',
          );
          if (variant.hasIcon) {
            expect(
              _textColor(
                tester,
                find.descendant(
                  of: find.byIcon(Icons.save),
                  matching: find.byType(RichText),
                ),
              ),
              foreground,
              reason: '$state icon',
            );
          }
        }
      });
    }
  }
}

void _layoutTests(_Variant variant) {
  const shortcutPadding = EdgeInsetsDirectional.fromSTEB(36, 8, 12, 4);
  const shortcutMinimumSize = Size(220, 72);
  const shortcutAlignment = AlignmentDirectional.topStart;
  const suppliedStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.all(2)),
    minimumSize: WidgetStatePropertyAll(Size(100, 40)),
    alignment: Alignment.bottomRight,
  );

  for (final direction in TextDirection.values) {
    for (final compact in [false, true]) {
      for (final style in [null, suppliedStyle]) {
        testWidgets('layout shortcuts match native style: $direction '
            'compact=$compact style=${style != null}', (tester) async {
          await _pumpButtons(
            tester,
            direction: direction,
            theme: compact
                ? ThemeData(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  )
                : null,
            nativeButton: variant.nativeButton(
              child: const Text(_label),
              onPressed: () {},
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(shortcutPadding),
                minimumSize: WidgetStatePropertyAll(shortcutMinimumSize),
                alignment: shortcutAlignment,
              ),
            ),
            asyncButton: variant.asyncButton(
              child: const Text(_label),
              onPressed: () {},
              style: style,
              padding: shortcutPadding,
              minimumSize: shortcutMinimumSize,
              alignment: shortcutAlignment,
            ),
          );

          expect(
            _layout(tester, _asyncKey, hasIcon: variant.hasIcon),
            _layout(tester, _nativeKey, hasIcon: variant.hasIcon),
          );
        });
      }
    }
  }
}

void _untouchedStyleTests(_Variant variant) {
  final suppliedStyle = ButtonStyle(
    elevation: const WidgetStatePropertyAll(5),
    shape: const WidgetStatePropertyAll(
      BeveledRectangleBorder(
        side: BorderSide(color: Color(0xFF0000FF), width: 2),
      ),
    ),
    overlayColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.pressed) ? const Color(0x3300FF00) : null,
    ),
    splashFactory: InkRipple.splashFactory,
  );

  for (final style in [null, suppliedStyle]) {
    testWidgets('shortcuts keep native feedback and shape: '
        'style=${style != null}', (tester) async {
      await _pumpButtons(
        tester,
        nativeButton: variant.nativeButton(
          child: const Text(_label),
          onPressed: () {},
          style: style,
        ),
        asyncButton: variant.asyncButton(
          child: const Text(_label),
          onPressed: () {},
          style: style,
          backgroundColor: _shortcutBackground.enabled,
          foregroundColor: _shortcutForeground.enabled,
          disabledBackgroundColor: _shortcutBackground.disabled,
          disabledForegroundColor: _shortcutForeground.disabled,
          mouseCursor: SystemMouseCursors.grab,
        ),
      );

      final nativeMaterial = _buttonMaterial(tester, _nativeKey);
      final asyncMaterial = _buttonMaterial(tester, _asyncKey);
      expect(asyncMaterial.shape, nativeMaterial.shape);
      expect(asyncMaterial.elevation, nativeMaterial.elevation);
      expect(asyncMaterial.shadowColor, nativeMaterial.shadowColor);
      expect(
        asyncMaterial.textStyle?.fontSize,
        nativeMaterial.textStyle?.fontSize,
      );
      expect(
        asyncMaterial.textStyle?.fontWeight,
        nativeMaterial.textStyle?.fontWeight,
      );

      final nativeInk = _buttonInk(tester, _nativeKey);
      final asyncInk = _buttonInk(tester, _asyncKey);
      expect(asyncInk.splashFactory, nativeInk.splashFactory);
      for (final state in [
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      ]) {
        expect(
          asyncInk.overlayColor?.resolve({state}),
          nativeInk.overlayColor?.resolve({state}),
          reason: '$state overlay',
        );
      }
    });
  }

  testWidgets('shortcuts keep splashFactory without a style', (tester) async {
    await _pumpButtons(
      tester,
      asyncButton: variant.asyncButton(
        child: const Text(_label),
        onPressed: () {},
        backgroundColor: _shortcutBackground.enabled,
        splashFactory: NoSplash.splashFactory,
      ),
    );

    expect(
      _buttonInk(tester, _asyncKey).splashFactory,
      NoSplash.splashFactory,
    );
  });
}

void _mouseCursorTests(_Variant variant) {
  const suppliedStyle = ButtonStyle(
    mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.help),
  );
  const stateCursor = WidgetStateMouseCursor.fromMap({
    WidgetState.disabled: SystemMouseCursors.forbidden,
    WidgetState.any: SystemMouseCursors.grab,
  });
  const themeStyle = ButtonStyle(
    mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.alias),
  );
  const cases =
      <
        ({
          String name,
          ButtonStyle? style,
          ButtonStyle? themeStyle,
          MouseCursor? cursor,
        })
      >[
        (name: 'native default', style: null, themeStyle: null, cursor: null),
        (
          name: 'supplied style',
          style: suppliedStyle,
          themeStyle: null,
          cursor: null,
        ),
        (
          name: 'plain shortcut over style',
          style: suppliedStyle,
          themeStyle: null,
          cursor: SystemMouseCursors.grab,
        ),
        (
          name: 'state shortcut',
          style: suppliedStyle,
          themeStyle: null,
          cursor: stateCursor,
        ),
        (
          name: 'nullable shortcut over style',
          style: suppliedStyle,
          themeStyle: themeStyle,
          cursor: _NullableStateCursor(),
        ),
        (
          name: 'nullable shortcut over theme',
          style: null,
          themeStyle: themeStyle,
          cursor: _NullableStateCursor(),
        ),
        (
          name: 'nullable shortcut over native default',
          style: null,
          themeStyle: null,
          cursor: _NullableStateCursor(),
        ),
      ];

  for (final cursorCase in cases) {
    testWidgets('${cursorCase.name} mouse cursor', (tester) async {
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 1,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      for (final state in _ButtonState.values) {
        final onPressed = state == _ButtonState.disabled ? null : () {};
        await _pumpButtons(
          tester,
          // Loading disables the outer native button.
          nativeButton: variant.nativeButton(
            child: const Text(_label),
            onPressed: state == _ButtonState.enabled ? onPressed : null,
            style: cursorCase.style,
          ),
          asyncButton: variant.asyncButton(
            child: const Text(_label),
            onPressed: onPressed,
            loading: state == _ButtonState.loading,
            style: cursorCase.style,
            mouseCursor: cursorCase.cursor,
          ),
          themeStyle: cursorCase.themeStyle,
        );

        Future<MouseCursor?> hoveredCursor(Key key) async {
          await gesture.moveTo(tester.getCenter(_buttonFinder(key)));
          await tester.pump();
          final cursor = RendererBinding.instance.mouseTracker
              .debugDeviceActiveCursor(1);
          await gesture.moveTo(Offset.zero);
          await tester.pump();

          return cursor;
        }

        // Null shortcut results follow the native style, theme, and default
        // resolution for the same state.
        final cursor = cursorCase.cursor;
        final expected =
            (cursor == null
                ? null
                : WidgetStateProperty.resolveAs<MouseCursor?>(cursor, {
                    if (state != _ButtonState.enabled) WidgetState.disabled,
                    WidgetState.hovered,
                  })) ??
            await hoveredCursor(_nativeKey);
        expect(
          await hoveredCursor(_asyncKey),
          expected,
          reason: '$state cursor',
        );
      }
    });
  }
}

_AsyncBuilder _asyncLabel(_AsyncLabelBuilder builder, {Widget? icon = _icon}) =>
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
      splashFactory,
    }) => builder(
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
      splashFactory: splashFactory,
    );

_NativeBuilder _nativeLabel(_NativeLabelBuilder builder) =>
    ({required child, required onPressed, style}) => builder(
      label: child,
      icon: _icon,
      onPressed: onPressed,
      style: style,
    );

WidgetStateProperty<Color?> _stateProperty(_StateColors colors) =>
    WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? colors.disabled
          : colors.enabled,
    );

const Key _nativeKey = ValueKey('native');
const Key _asyncKey = ValueKey('async');

Future<void> _pumpButtons(
  WidgetTester tester, {
  required Widget asyncButton,
  Widget? nativeButton,
  ThemeData? theme,
  ButtonStyle? themeStyle,
  TextDirection direction = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Directionality(
          textDirection: direction,
          child: ElevatedButtonTheme(
            data: ElevatedButtonThemeData(style: themeStyle),
            child: FilledButtonTheme(
              data: FilledButtonThemeData(style: themeStyle),
              child: OutlinedButtonTheme(
                data: OutlinedButtonThemeData(style: themeStyle),
                child: TextButtonTheme(
                  data: TextButtonThemeData(style: themeStyle),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (nativeButton != null)
                          KeyedSubtree(key: _nativeKey, child: nativeButton),
                        KeyedSubtree(key: _asyncKey, child: asyncButton),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Material animates text and icon colors between states.
  await tester.pump(kThemeChangeDuration);
}

Finder _buttonFinder(Key key) => find.descendant(
  of: find.byKey(key),
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
);

Material _buttonMaterial(WidgetTester tester, Key key) => tester.widget(
  find
      .descendant(of: _buttonFinder(key), matching: find.byType(Material))
      .first,
);

InkWell _buttonInk(WidgetTester tester, Key key) => tester.widget(
  find.descendant(of: _buttonFinder(key), matching: find.byType(InkWell)).first,
);

Color? _textColor(WidgetTester tester, Finder finder) =>
    tester.renderObject<RenderParagraph>(finder).text.style?.color;

({Size size, Offset labelInset, Offset? iconInset}) _layout(
  WidgetTester tester,
  Key key, {
  required bool hasIcon,
}) {
  final rect = tester.getRect(_buttonFinder(key));
  Finder within(Finder matching) =>
      find.descendant(of: find.byKey(key), matching: matching);

  return (
    size: rect.size,
    labelInset: tester.getTopLeft(within(find.text(_label))) - rect.topLeft,
    iconInset: hasIcon
        ? tester.getTopLeft(within(find.byIcon(Icons.save))) - rect.topLeft
        : null,
  );
}

/// Resolves to null outside enabled states and fails if used unresolved.
class _NullableStateCursor extends MouseCursor
    implements WidgetStateProperty<MouseCursor?> {
  const _NullableStateCursor();

  @override
  MouseCursor? resolve(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled) ? null : SystemMouseCursors.precise;

  @override
  MouseCursorSession createSession(int device) =>
      throw UnsupportedError('Resolve this cursor before creating a session');

  @override
  String get debugDescription => '_NullableStateCursor';
}
