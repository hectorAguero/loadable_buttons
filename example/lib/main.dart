import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

/// main is the entry point of the application.
void main() {
  runApp(const MyApp());
}

/// MyApp is a StatelessWidget. This widget is the root of your application.
class MyApp extends StatelessWidget {
  /// Creates a MaterialApp widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
      ),
      home: const _HomePage(),
    );
  }
}

/// HomePage is a StatefulWidget that represents the main application page.
class _HomePage extends StatefulWidget {
  /// Creates a HomePage widget.
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  TransitionAnimationType transitionType = TransitionAnimationType.stack;
  bool _isLongText = false;

  static const clickMeText = 'Click me';
  static const longClickMeText = 'Click me again';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AsyncFloatingActionButton.extended(
            splashFactory: NoSplash.splashFactory,
            transitionType: transitionType,
            onPressed: () async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => _isLongText = !_isLongText);
            },
            icon: const Icon(Icons.ads_click_sharp),
            label: _isLongText
                ? const Text(longClickMeText)
                : const Text(clickMeText),
          ),
          AsyncFloatingActionButton.extended(
            splashFactory: NoSplash.splashFactory,
            onPressed: _switchTransitionAnimationType,
            label: Text(transitionType.name.capitalize()),
            icon: const Icon(Icons.animation),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
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
                    child: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncElevatedButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
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
                    child: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncFilledButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncFilledButton.tonal(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncFilledButton.tonalIcon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                ],
              ),
              Text(
                "AsyncTextButton",
                style: TextTheme.of(context).titleLarge,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncTextButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    child: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncTextButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
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
                    child: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncOutlinedButton.icon(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    label: _isLongText
                        ? const Text(longClickMeText)
                        : const Text(clickMeText),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                ],
              ),
              Text(
                "AsyncIconButton",
                style: TextTheme.of(context).titleLarge,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  AsyncIconButton(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncIconButton.filled(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    iconSize: 32,
                    icon: const Icon(Icons.flutter_dash),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncIconButton.filledTonal(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    iconSize: 48,
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                  AsyncIconButton.outlined(
                    splashFactory: NoSplash.splashFactory,
                    transitionType: transitionType,
                    icon: const Icon(Icons.flutter_dash),
                    iconSize: 64,
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() => _isLongText = !_isLongText);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchTransitionAnimationType() async {
    setState(() {
      transitionType = transitionType == TransitionAnimationType.stack
          ? TransitionAnimationType.animatedSwitcher
          : TransitionAnimationType.stack;
    });
  }
}

/// Extension to capitalize the first letter of a string.
extension StringCapitalization on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
