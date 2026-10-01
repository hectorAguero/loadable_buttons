import 'dart:async';

import 'package:flutter/material.dart';

/// Package-internal loading state, intentionally absent from the public barrel.
///
/// Each button keeps its own State and native Material variant wiring.
mixin AsyncButtonState<ButtonWidget extends StatefulWidget>
    on State<ButtonWidget> {
  bool _internalLoading = false;

  /// The current loading flag supplied by the consumer.
  bool get externalLoading;

  /// The current callback supplied by the consumer.
  FutureOr<void> Function()? get asyncOnPressed;

  /// External updates never clear an operation that is still pending.
  bool get isLoading => _internalLoading || externalLoading;

  /// Locks synchronously and releases only the operation's own loading state.
  Future<void> handlePressed() async {
    if (asyncOnPressed == null || isLoading) return;
    setState(() => _internalLoading = true);

    try {
      await asyncOnPressed?.call();
    } finally {
      // Consumer exceptions propagate even when the button has been disposed.
      if (mounted) setState(() => _internalLoading = false);
    }
  }
}

/// Package-internal default indicator, resolved inside the Material button.
class DefaultLoadingIndicator extends StatelessWidget {
  /// Keeps each family's foreground source and optional semantics explicit.
  const DefaultLoadingIndicator({
    this.style,
    this.themeStyleOf,
    this.color,
    this.loadingSemanticsLabel,
    super.key,
  });

  static const double _defaultStrokeWidth = 3.0;

  /// The explicit button style.
  final ButtonStyle? style;

  /// Looks up the family-specific theme using the indicator's own context.
  final ButtonStyle? Function(BuildContext context)? themeStyleOf;

  /// The explicit FAB foreground color.
  final Color? color;

  /// Elevated's optional accessibility label.
  final String? loadingSemanticsLabel;

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        // Resolve each source before applying precedence, in the normal state.
        color: color ??
            style?.foregroundColor?.resolve(<WidgetState>{}) ??
            themeStyleOf
                ?.call(context)
                ?.foregroundColor
                ?.resolve(<WidgetState>{}) ??
            IconTheme.of(context).color ??
            DefaultTextStyle.of(context).style.color,
        strokeWidth: _defaultStrokeWidth,
        semanticsLabel: loadingSemanticsLabel,
        strokeCap: StrokeCap.round,
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      );
}
