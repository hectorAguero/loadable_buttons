import 'package:example/loading_contract_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

/// main is the entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The example application for loading buttons.
class MyApp extends StatefulWidget {
  /// Creates a MaterialApp widget.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _ExampleTheme _theme = _ExampleTheme.black;

  void _changeTheme(_ExampleTheme? theme) {
    if (theme == null) return;
    setState(() => _theme = theme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _theme.color,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
      ),
      home: Builder(
        builder: (context) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _HomePage(theme: _theme, onThemeChanged: _changeTheme),
          );
        },
      ),
    );
  }
}

/// HomePage is a StatefulWidget that represents the main application page.
class _HomePage extends StatefulWidget {
  /// Creates a HomePage widget.
  const _HomePage({required this.theme, required this.onThemeChanged});

  final _ExampleTheme theme;
  final ValueChanged<_ExampleTheme?> onThemeChanged;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  TransitionAnimationType transitionType = TransitionAnimationType.stack;
  bool _isLongText = false;
  Duration? _loadingDuration = const Duration(seconds: 1);
  String? _durationError;

  static const double _maximumSeconds = 60.0;

  static const clickMeText = 'Click me';
  static const longClickMeText = 'Click me again';

  String get _buttonLabel =>
      transitionType == TransitionAnimationType.animatedSwitcher && _isLongText
          ? longClickMeText
          : clickMeText;

  Future<void> _runDemo() async {
    final duration = _loadingDuration;
    if (duration == null) return;
    await Future<void>.delayed(duration);
    if (mounted && transitionType == TransitionAnimationType.animatedSwitcher) {
      setState(() => _isLongText = !_isLongText);
    }
  }

  void _setDuration(String value) {
    final seconds = double.tryParse(value);
    final valid =
        seconds != null &&
        seconds.isFinite &&
        seconds >= 0 &&
        seconds <= _maximumSeconds;
    setState(() {
      _loadingDuration =
          valid
              ? Duration(
                milliseconds:
                    (seconds * Duration.millisecondsPerSecond).round(),
              )
              : null;
      _durationError = valid ? null : 'Enter 0–60 seconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = _loadingDuration == null ? null : _runDemo;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Loadable buttons'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 12,
        children: [
          AsyncFloatingActionButton(
            tooltip: 'Floating action button demo',
            splashFactory: NoSplash.splashFactory,
            transitionType: transitionType,
            onPressed: onPressed,
            child: const Icon(Icons.refresh),
          ),
          AsyncFloatingActionButton.extended(
            splashFactory: NoSplash.splashFactory,
            transitionType: transitionType,
            onPressed: onPressed,
            icon: const Icon(Icons.ads_click_sharp),
            label: Text(_buttonLabel),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 168),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _ExampleControls(
                transitionType: transitionType,
                onTransitionChanged: _setTransitionType,
                theme: widget.theme,
                onThemeChanged: widget.onThemeChanged,
                onDurationChanged: _setDuration,
                durationError: _durationError,
              ),
              LoadingContractDemo(
                transitionType: transitionType,
                onRunTimedOperation: onPressed,
              ),
              const SizedBox(height: 8),
              Text(
                "AsyncElevatedButton",
                style: TextTheme.of(context).titleLarge,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncElevatedButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: Text(_buttonLabel),
                    onPressed: onPressed,
                  ),
                  AsyncElevatedButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: Text(_buttonLabel),
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                ],
              ),
              Text(
                "AsyncFilledButton",
                style: TextTheme.of(context).titleLarge,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncFilledButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: Text(_buttonLabel),
                    onPressed: onPressed,
                  ),
                  AsyncFilledButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: Text(_buttonLabel),
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                  AsyncFilledButton.tonal(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: Text(_buttonLabel),
                    onPressed: onPressed,
                  ),
                  AsyncFilledButton.tonalIcon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: Text(_buttonLabel),
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                ],
              ),
              Text("AsyncTextButton", style: TextTheme.of(context).titleLarge),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncTextButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: Text(_buttonLabel),
                    onPressed: onPressed,
                  ),
                  AsyncTextButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: Text(_buttonLabel),
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                ],
              ),
              Text(
                "AsyncOutlinedButton",
                style: TextTheme.of(context).titleLarge,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncOutlinedButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: Text(_buttonLabel),
                    onPressed: onPressed,
                  ),
                  AsyncOutlinedButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: Text(_buttonLabel),
                    icon: const Icon(Icons.add),
                    onPressed: onPressed,
                  ),
                ],
              ),
              Text("AsyncIconButton", style: TextTheme.of(context).titleLarge),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncIconButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    onPressed: onPressed,
                  ),
                  AsyncIconButton.filled(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    iconSize: 32,
                    icon: const Icon(Icons.flutter_dash),
                    onPressed: onPressed,
                  ),
                  AsyncIconButton.filledTonal(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    iconSize: 48,
                    onPressed: onPressed,
                  ),
                  AsyncIconButton.outlined(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    iconSize: 64,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setTransitionType(TransitionAnimationType? transition) {
    if (transition == null) return;
    setState(() {
      transitionType = transition;
      _isLongText = false;
    });
  }
}

enum _ExampleTheme {
  black('Black', Colors.black),
  teal('Teal', Colors.teal),
  blue('Blue', Colors.blue),
  purple('Purple', Colors.purple),
  green('Green', Colors.green),
  orange('Orange', Colors.orange),
  red('Red', Colors.red),
  pink('Pink', Colors.pink);

  const _ExampleTheme(this.label, this.color);

  final String label;
  final Color color;
}

class _ExampleControls extends StatelessWidget {
  const _ExampleControls({
    required this.transitionType,
    required this.onTransitionChanged,
    required this.theme,
    required this.onThemeChanged,
    required this.onDurationChanged,
    required this.durationError,
  });

  static const double _controlWidth = 220.0;

  final TransitionAnimationType transitionType;
  final ValueChanged<TransitionAnimationType?> onTransitionChanged;
  final _ExampleTheme theme;
  final ValueChanged<_ExampleTheme?> onThemeChanged;
  final ValueChanged<String> onDurationChanged;
  final String? durationError;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final width =
          constraints.maxWidth < _controlWidth
              ? constraints.maxWidth
              : _controlWidth;

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: width,
            child: _ControlDropdown(
              label: 'Animation mode',
              value: transitionType,
              onChanged: onTransitionChanged,
              items: const [
                DropdownMenuItem(
                  value: TransitionAnimationType.stack,
                  child: Text('Stack'),
                ),
                DropdownMenuItem(
                  value: TransitionAnimationType.animatedSwitcher,
                  child: Text('Animated switcher'),
                ),
              ],
            ),
          ),
          SizedBox(
            width: width,
            child: _ControlDropdown(
              label: 'Theme',
              value: theme,
              onChanged: onThemeChanged,
              items: [
                for (final option in _ExampleTheme.values)
                  DropdownMenuItem(
                    value: option,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: option.color, size: 16),
                        const SizedBox(width: 8),
                        Text(option.label),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: width,
            child: TextFormField(
              initialValue: '1',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Loading duration',
                suffixText: 'seconds',
                border: const OutlineInputBorder(),
                errorText: durationError,
              ),
              onChanged: onDurationChanged,
            ),
          ),
        ],
      );
    },
  );
}

class _ControlDropdown<T extends Object> extends StatelessWidget {
  const _ControlDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        items: items,
        isDense: true,
        isExpanded: true,
        onChanged: onChanged,
      ),
    ),
  );
}
