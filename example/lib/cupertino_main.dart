import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:loadable_buttons/cupertino.dart';

/// Runs the Cupertino example without a Material ancestor.
void main() => runApp(const CupertinoButtonExample());

/// Demonstrates native Cupertino variants and independent loading control.
class CupertinoButtonExample extends StatefulWidget {
  /// Creates the Cupertino example application.
  const CupertinoButtonExample({super.key});

  @override
  State<CupertinoButtonExample> createState() => _CupertinoButtonExampleState();
}

class _CupertinoButtonExampleState extends State<CupertinoButtonExample> {
  bool _externalLoading = false;
  bool _disabled = false;
  int _longPresses = 0;
  String _result = 'Ready';

  Future<void> _save() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _result = 'Saved');
  }

  Future<void> _fail() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    throw StateError('Demo save failed');
  }

  void _handleError(Object _, StackTrace _) {
    if (!mounted) return;
    setState(() => _result = 'Save failed. You can retry.');
  }

  void _longPress() => setState(() => _longPresses++);

  @override
  Widget build(BuildContext context) => CupertinoApp(
    debugShowCheckedModeBanner: false,
    home: CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Async Cupertino buttons'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CupertinoListTile(
              title: const Text('External loading'),
              trailing: CupertinoSwitch(
                value: _externalLoading,
                onChanged: (value) => setState(() => _externalLoading = value),
              ),
            ),
            CupertinoListTile(
              title: const Text('Disable buttons'),
              trailing: CupertinoSwitch(
                value: _disabled,
                onChanged: (value) => setState(() => _disabled = value),
              ),
            ),
            const SizedBox(height: 24),
            AsyncCupertinoButton(
              onPressed: _disabled ? null : _save,
              onLongPress: _disabled ? null : _longPress,
              loading: _externalLoading,
              loadingSemanticsLabel: 'Saving changes',
              child: const Text('Save (or long press)'),
            ),
            const SizedBox(height: 16),
            AsyncCupertinoButton.filled(
              onPressed: _disabled ? null : _save,
              loading: _externalLoading,
              transitionType: TransitionAnimationType.animatedSwitcher,
              loadingSemanticsLabel: 'Saving changes',
              child: const Text('Filled save'),
            ),
            const SizedBox(height: 16),
            AsyncCupertinoButton.tinted(
              onPressed: _disabled ? null : _fail,
              onError: _handleError,
              loading: _externalLoading,
              loadingChild: const Text('Trying to save…'),
              child: const Text('Tinted handled error'),
            ),
            const SizedBox(height: 24),
            Semantics(liveRegion: true, child: Text(_result)),
            Text('Long presses: $_longPresses'),
            const SizedBox(height: 16),
            const Text(
              'Start a save, then toggle external loading. Clearing the switch '
              'keeps the button locked until its operation finishes. '
              'Leaving it on keeps loading after completion.',
            ),
          ],
        ),
      ),
    ),
  );
}
