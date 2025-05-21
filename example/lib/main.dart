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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AsyncFloatingActionButton(
            onPressed: () => Future.delayed(const Duration(seconds: 2)),
            child: const Text('Click me', textAlign: TextAlign.center),
          ),
          AsyncFloatingActionButton.extended(
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
                    transitionType: transitionType,
                    child: const Text('Click me'),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncElevatedButton.icon(
                    transitionType: transitionType,
                    label: const Text('Click me'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
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
                    transitionType: transitionType,
                    child: const Text('Click me'),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncFilledButton.icon(
                    transitionType: transitionType,
                    label: const Text('Click me'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncFilledButton.tonal(
                    transitionType: transitionType,
                    child: const Text('Click me'),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncFilledButton.tonalIcon(
                    transitionType: transitionType,
                    label: const Text('Click me'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
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
                    transitionType: transitionType,
                    child: const Text('Click me'),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncTextButton.icon(
                    transitionType: transitionType,
                    label: const Text('Click me'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
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
                    transitionType: transitionType,
                    child: const Text('Click me'),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncOutlinedButton.icon(
                    transitionType: transitionType,
                    label: const Text('Click me'),
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
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
                    transitionType: transitionType,
                    icon: const Icon(Icons.ads_click),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncIconButton.filled(
                    transitionType: transitionType,
                    icon: const Icon(Icons.abc),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncIconButton.filledTonal(
                    transitionType: transitionType,
                    icon: const Icon(Icons.abc),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
                    },
                  ),
                  AsyncIconButton.outlined(
                    transitionType: transitionType,
                    icon: const Icon(Icons.abc),
                    onPressed: () async {
                      await Future<void>.delayed(const Duration(seconds: 2));
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

  void _switchTransitionAnimationType() {
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
