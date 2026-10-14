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

/// Observes and requests loading for one async button.
///
/// [loading] is a manual request owned by the application. [isPending] reports
/// the attached button's own `onPressed` and `onError` work, and only that
/// operation can clear it. A button's effective loading combines its `loading`
/// parameter, [loading], and its pending operation; setting [loading] to false
/// never cancels or unlocks unfinished work.
///
/// The caller owns the controller and must dispose it. Buttons add and remove
/// listeners but never dispose it. Attach a controller to one button at a time;
/// it can move between buttons, and a pending operation keeps locking any
/// button that uses this controller until that operation finishes.
class AsyncButtonController extends ChangeNotifier {
  /// Creates a controller with an optional initial manual [loading] request.
  AsyncButtonController({this._loading = false});

  bool _loading;
  int _pendingOperations = 0;
  int _attachedButtons = 0;
  bool _disposed = false;

  /// Whether the application requests loading, independent of pending work.
  ///
  /// Changing this value notifies listeners and rebuilds the attached button.
  bool get loading => _loading;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  /// Whether an operation started by a button with this controller is pending.
  ///
  /// True from activation until `onPressed` and any `onError` finish, even if
  /// the button is disposed or switches to another controller meanwhile.
  bool get isPending => _pendingOperations > 0;

  /// Whether [loading] is requested or an operation [isPending].
  ///
  /// The button's own `loading` parameter is not included; the application
  /// already owns that value.
  bool get isLoading => _loading || isPending;

  void _attach(VoidCallback listener) {
    // Report instead of throwing so a misused controller cannot leave the
    // button half-mounted.
    assert(() {
      if (_attachedButtons > 0) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError(
              'An AsyncButtonController can be attached to only one button '
              'at a time.',
            ),
            library: 'loadable_buttons',
          ),
        );
      }

      return true;
    }());
    _attachedButtons++;
    addListener(listener);
  }

  void _detach(VoidCallback listener) {
    _attachedButtons--;
    removeListener(listener);
  }

  void _beginOperation() {
    _pendingOperations++;
    if (_pendingOperations == 1) notifyListeners();
  }

  void _endOperation() {
    _pendingOperations--;
    // Operations outlive their button and may finish after the owner disposes.
    if (_pendingOperations == 0 && !_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Package-internal loading state, intentionally absent from the public barrel.
///
/// Each button keeps its own State and native design-library variant wiring.
mixin AsyncButtonState<ButtonWidget extends StatefulWidget>
    on State<ButtonWidget> {
  bool _internalLoading = false;
  AsyncButtonController? _controller;

  /// The current loading flag supplied by the consumer.
  bool get externalLoading;

  /// The current callback supplied by the consumer.
  FutureOr<void> Function()? get asyncOnPressed;

  /// The optional error handler supplied by the consumer.
  AsyncButtonErrorHandler? get asyncOnError;

  /// The optional controller supplied by the consumer.
  AsyncButtonController? get asyncController;

  /// External updates never clear an operation that is still pending.
  bool get isLoading =>
      _internalLoading || externalLoading || (_controller?.isLoading ?? false);

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant ButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (asyncController == _controller) return;
    _detachController();
    _attachController();
  }

  // Detaching on deactivation lets another button adopt the controller in the
  // same frame, such as when an ancestor switches button types.
  @override
  void activate() {
    super.activate();
    _attachController();
  }

  @override
  void deactivate() {
    _detachController();
    super.deactivate();
  }

  void _attachController() {
    final controller = asyncController;
    controller?._attach(_handleControllerChanged);
    _controller = controller;
  }

  void _detachController() {
    _controller?._detach(_handleControllerChanged);
    _controller = null;
  }

  void _handleControllerChanged() => setState(() {});

  /// Locks synchronously and releases only the operation's own loading state.
  Future<void> handlePressed() async {
    final callback = asyncOnPressed;
    if (!mounted || callback == null || isLoading) return;
    final errorHandler = asyncOnError;
    // The operation releases the controller it started with, even if the
    // button switches controllers or is disposed before it finishes.
    final controller = _controller;
    setState(() => _internalLoading = true);
    controller?._beginOperation();

    try {
      await callback();
    } on Object catch (error, stackTrace) {
      if (errorHandler == null) rethrow;
      await errorHandler(error, stackTrace);
    } finally {
      controller?._endOperation();
      // Consumer exceptions propagate even when the button has been disposed.
      if (mounted) setState(() => _internalLoading = false);
    }
  }
}
