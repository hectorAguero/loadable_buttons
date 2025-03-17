import 'package:flutter/material.dart';
import 'package:loadable_buttons/loadable_buttons.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AsyncElevatedButton(
          child: Text('Click me'),
          onPressed: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
        ),
      ),
    );
  }
}
