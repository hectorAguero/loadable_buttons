import 'dart:async';

import 'package:flutter/widgets.dart';

/// A handler that consumes an activation error when it completes successfully.
///
/// Receives the original [error] and [stackTrace] from `onPressed`. May return
/// a Future; the button stays loading and locked until that Future completes.
/// A thrown error or failed Future propagates with its own stack trace and is
/// not passed back to this handler. Without a handler, the callback's original
/// error and stack trace propagate.
///
/// Each activation captures its handler before calling `onPressed`. Disposal
/// does not cancel either callback. No context is supplied; check your own
/// lifecycle before using captured state or context. Only returned or awaited
/// Futures are tracked. Long-press and presentation callbacks are not covered.
typedef AsyncButtonErrorHandler =
    FutureOr<void> Function(Object error, StackTrace stackTrace);

/// Package-internal loading state, intentionally absent from the public barrel.
///
/// Each button keeps its own State and native design-library variant wiring.
mixin AsyncButtonState<ButtonWidget extends StatefulWidget>
    on State<ButtonWidget> {
  bool _internalLoading = false;

  /// The current loading flag supplied by the consumer.
  bool get externalLoading;

  /// The current callback supplied by the consumer.
  FutureOr<void> Function()? get asyncOnPressed;

  /// The optional error handler supplied by the consumer.
  AsyncButtonErrorHandler? get asyncOnError;

  /// External updates never clear an operation that is still pending.
  bool get isLoading => _internalLoading || externalLoading;

  /// Locks synchronously and releases only the operation's own loading state.
  Future<void> handlePressed() async {
    final callback = asyncOnPressed;
    if (!mounted || callback == null || isLoading) return;
    final errorHandler = asyncOnError;
    setState(() => _internalLoading = true);

    try {
      await callback();
    } on Object catch (error, stackTrace) {
      if (errorHandler == null) rethrow;
      await errorHandler(error, stackTrace);
    } finally {
      // Consumer exceptions propagate even when the button has been disposed.
      if (mounted) setState(() => _internalLoading = false);
    }
  }
}
