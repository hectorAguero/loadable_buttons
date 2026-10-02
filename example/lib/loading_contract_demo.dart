import 'dart:async';

import 'package:loadable_buttons/loadable_buttons.dart';
import 'package:material_ui/material_ui.dart';

/// Interactive examples of loading ownership and consumer responsibilities.
class LoadingContractDemo extends StatefulWidget {
  /// Creates the contract demos alongside the timed button gallery.
  const LoadingContractDemo({
    required this.transitionType,
    required this.onRunTimedOperation,
    super.key,
  });

  /// The built-in transition selected for the gallery.
  final TransitionAnimationType transitionType;

  /// The simulated operation using the gallery's duration control.
  final Future<void> Function()? onRunTimedOperation;

  @override
  State<LoadingContractDemo> createState() => _LoadingContractDemoState();
}

class _LoadingContractDemoState extends State<LoadingContractDemo> {
  Completer<void>? _operation;
  bool _externalLoading = false;
  bool _disabled = false;
  bool _selected = false;
  bool _largerContent = false;
  bool _largeText = false;
  int _longPressCount = 0;
  String _result = 'No operation started';

  Future<void> _startOperation() async {
    final operation = Completer<void>();
    setState(() {
      _operation = operation;
      _result = 'Operation pending';
    });
    try {
      await operation.future;
      if (mounted) setState(() => _result = 'Operation completed');
    } finally {
      if (mounted) setState(() => _operation = null);
    }
  }

  void _handleOperationError(Object error, StackTrace _) {
    // This handler explicitly consumes the failure. The demo owns its feedback
    // and checks its lifecycle because error handlers may run after disposal.
    if (mounted) setState(() => _result = 'Handled error: $error');
  }

  void _finishOperation({bool fail = false}) {
    final operation = _operation;
    if (operation == null || operation.isCompleted) return;
    if (fail) {
      operation.completeError(Exception('Simulated save failure'));
    } else {
      operation.complete();
    }
  }

  Future<void> _toggleSelected() async {
    await widget.onRunTimedOperation?.call();
    if (mounted) setState(() => _selected = !_selected);
  }

  @override
  void dispose() {
    // Release this demo's controlled Future when leaving the page.
    // Real operations need their own cancellation policy.
    final operation = _operation;
    if (operation != null && !operation.isCompleted) operation.complete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timedOperation = _disabled ? null : widget.onRunTimedOperation;
    final loadingContent = Semantics(
      label: 'Saving changes',
      excludeSemantics: true,
      child: _largerContent
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Saving changes, please wait…'),
            )
          : const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(),
            ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: _largeText
              ? const TextScaler.linear(2)
              : MediaQuery.textScalerOf(context),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  'Loading contracts',
                  style: TextTheme.of(context).titleLarge,
                ),
                const Text(
                  'Start an operation, toggle external loading on and off, '
                  'then finish or fail it. External loading and the pending '
                  'operation each keep the button locked.',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('External loading'),
                  value: _externalLoading,
                  onChanged: (value) =>
                      setState(() => _externalLoading = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disable demo buttons'),
                  value: _disabled,
                  onChanged: (value) => setState(() => _disabled = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Larger loading content'),
                  value: _largerContent,
                  onChanged: (value) => setState(() => _largerContent = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Large demo text (2×)'),
                  value: _largeText,
                  onChanged: (value) => setState(() => _largeText = value),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AsyncElevatedButton(
                      loading: _externalLoading,
                      transitionType: widget.transitionType,
                      loadingChild: loadingContent,
                      onPressed: _disabled ? null : _startOperation,
                      onError: _handleOperationError,
                      onLongPress: _disabled
                          ? null
                          : () => setState(() => _longPressCount++),
                      child: const Text('Start operation'),
                    ),
                    OutlinedButton(
                      onPressed: _operation == null ? null : _finishOperation,
                      child: const Text('Finish operation'),
                    ),
                    TextButton(
                      onPressed: _operation == null
                          ? null
                          : () => _finishOperation(fail: true),
                      child: const Text('Fail operation'),
                    ),
                  ],
                ),
                Semantics(liveRegion: true, child: Text(_result)),
                Text('Idle long presses: $_longPressCount'),
                const Text(
                  'The favorite and custom-builder buttons use the loading '
                  'duration above. Their labels and selection belong '
                  'to the app.',
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AsyncIconButton.filled(
                      tooltip: 'Toggle favorite',
                      loading: _externalLoading,
                      transitionType: widget.transitionType,
                      loadingChild: const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Updating favorite',
                        ),
                      ),
                      isSelected: WidgetStatePropertyAll(_selected),
                      icon: const Icon(Icons.favorite_border),
                      selectedIcon: const Icon(Icons.favorite),
                      onPressed: timedOperation == null
                          ? null
                          : _toggleSelected,
                    ),
                    Text(
                      _selected ? 'Favorite selected' : 'Favorite unselected',
                    ),
                    AsyncOutlinedButton(
                      loading: _externalLoading,
                      onPressed: timedOperation,
                      transitionType: TransitionAnimationType.customBuilder,
                      // Immediate replacement retains no inactive subtree.
                      // Animated builders must guard any outgoing content.
                      customBuilder: (loading, child, loadingChild) => loading
                          ? loadingChild ?? const Text('Saving changes…')
                          : child,
                      loadingChild: loadingContent,
                      child: const Text('Custom builder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
