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

/// Observes and requests loading for an async button.
///
/// [loading] is a manual request owned by the application. [isPending] reports
/// `onPressed` and `onError` work started by a button using this controller,
/// and only that operation can clear it. A button's effective loading combines
/// its `loading` parameter, [loading], and [isPending]; setting [loading] to
/// false never cancels or unlocks unfinished work.
///
/// The caller owns the controller and must dispose it. Buttons add and remove
/// listeners but never dispose it. Use a controller for one logical button. It
/// can move between button widgets, including while an animated switch or
/// route transition briefly shows both; every button using it reflects the
/// same state, and pending work locks each of them until it finishes.
///
/// Pending work stays on the controller it started with. If a button switches
/// to another controller mid-operation, the new controller reports idle while
/// the button stays locked; keep the same controller to observe that work.
class AsyncButtonController extends ChangeNotifier {
  /// Creates a controller with an optional initial manual [loading] request.
  AsyncButtonController({this._loading = false});

  bool _loading;
  int _pendingOperations = 0;
  bool _disposed = false;

  /// Whether the application requests loading, independent of pending work.
  ///
  /// Changing this value notifies listeners. Buttons using this controller
  /// rebuild only when that changes their effective loading.
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
  bool _controllerLoading = false;
  _AsyncButtonGroupCoordinator? _group;

  /// The current loading flag supplied by the consumer.
  bool get externalLoading;

  /// The current callback supplied by the consumer.
  FutureOr<void> Function()? get asyncOnPressed;

  /// The optional error handler supplied by the consumer.
  AsyncButtonErrorHandler? get asyncOnError;

  /// The optional controller supplied by the consumer.
  AsyncButtonController? get asyncController;

  /// Whether the consumer exempts this button from its [AsyncButtonGroup].
  bool get excludeFromGroup;

  /// External updates never clear an operation that is still pending.
  bool get isLoading =>
      _internalLoading || externalLoading || _controllerLoading;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant ButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lookUpGroup();
    if (asyncController == _controller) return;
    _detachController();
    _attachController();
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController() {
    final controller = asyncController;
    controller?.addListener(_handleControllerChanged);
    _controller = controller;
    _controllerLoading = controller?.isLoading ?? false;
  }

  void _detachController() {
    _controller?.removeListener(_handleControllerChanged);
    _controller = null;
    _controllerLoading = false;
  }

  // Rebuild only when the controller changes this button's effective state.
  void _handleControllerChanged() {
    final controllerLoading = _controller?.isLoading ?? false;
    if (controllerLoading == _controllerLoading) return;
    setState(() => _controllerLoading = controllerLoading);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lookUpGroup();
  }

  // Excluded buttons skip the dependency, so group changes do not rebuild
  // them. Re-run when excludeFromGroup changes.
  void _lookUpGroup() {
    _group = excludeFromGroup
        ? null
        : context
              .dependOnInheritedWidgetOfExactType<_AsyncButtonGroupScope>()
              ?.notifier;
  }

  /// Whether activation is blocked: this button is loading, or a peer in its
  /// [AsyncButtonGroup] has a pending operation. Peers are disabled natively
  /// without showing loading content.
  bool get isLocked => isLoading || (_group?._isBlocking(this) ?? false);

  /// Returns [handler] while [callback] is supplied and activation is allowed.
  ///
  /// Every family wires native `onPressed` and `onLongPress` through this, so
  /// loading and group blocking share one enablement policy.
  VoidCallback? unlockedHandler(Object? callback, VoidCallback handler) =>
      isLocked || callback == null ? null : handler;

  /// Locks synchronously and releases only the operation's own loading state.
  Future<void> handlePressed() async {
    final callback = asyncOnPressed;
    // isLocked reads the group live, so a peer activated earlier in the same
    // frame has already claimed it and this activation is refused here.
    if (!mounted || callback == null || isLocked) return;
    // The operation releases the group it claimed, even after disposal or
    // group removal; a group holds one claim, so it cannot release another.
    await _runOperation(callback, _group?.._claim(this));
  }

  Future<void> _runOperation(
    FutureOr<void> Function() callback,
    _AsyncButtonGroupCoordinator? group,
  ) async {
    final errorHandler = asyncOnError;
    // The operation releases the controller it started with, even if the
    // button switches controllers or is disposed before it finishes.
    final controller = _controller;
    try {
      // Begin before locking so a disposed controller cannot strand the lock.
      controller?._beginOperation();
    } on Object {
      group?._release(this);
      rethrow;
    }
    setState(() => _internalLoading = true);

    try {
      await callback();
    } on Object catch (error, stackTrace) {
      if (errorHandler == null) rethrow;
      await errorHandler(error, stackTrace);
    } finally {
      controller?._endOperation();
      // Release before unlocking, so this button is never unlocked while it
      // still holds the group's claim.
      group?._release(this);
      // Consumer exceptions propagate even when the button has been disposed.
      if (mounted) setState(() => _internalLoading = false);
    }
  }
}

/// Allows one pending operation at a time among descendant async buttons.
///
/// When a member's `onPressed` starts, that button shows loading as usual and
/// every other member is disabled natively, blocking pointer, keyboard, and
/// accessibility activation without showing loading content. Members recover
/// when the operation and any `onError` finish. Buttons outside a group, and
/// members with `excludeFromGroup: true` such as a Cancel action, are never
/// blocked and never block others.
///
/// The nearest group applies; nested groups coordinate their own members
/// independently. Only activations claim a group: a `loading` parameter or
/// [AsyncButtonController.loading] request affects only its own button. An
/// operation keeps its claim if its button is disposed, and it never releases
/// a newer operation's claim. Removing the group releases its members. The
/// group coordinates availability only; application code owns cancellation.
///
/// A claim belongs to the group where activation started. A button moved into
/// another group mid-operation keeps loading but does not claim the new group,
/// so that group's members stay available. A Future that never completes keeps
/// its group blocked: give real work a timeout, or rebuild the group with a new
/// [Key] to start a fresh one.
class AsyncButtonGroup extends StatefulWidget {
  /// Creates a group coordinating the async buttons below [child].
  const AsyncButtonGroup({required this.child, super.key});

  /// The subtree whose async buttons share this group.
  final Widget child;

  /// Whether a member operation is pending in the nearest group.
  ///
  /// Returns false without a group. Registers a dependency, so [context]
  /// rebuilds when this changes; use it to disable non-async widgets as well.
  static bool isActiveOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_AsyncButtonGroupScope>()
          ?.notifier
          ?._isActive ??
      false;

  @override
  State<AsyncButtonGroup> createState() => _AsyncButtonGroupState();
}

class _AsyncButtonGroupState extends State<AsyncButtonGroup> {
  final _coordinator = _AsyncButtonGroupCoordinator();

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _AsyncButtonGroupScope(notifier: _coordinator, child: widget.child);
}

class _AsyncButtonGroupScope
    extends InheritedNotifier<_AsyncButtonGroupCoordinator> {
  const _AsyncButtonGroupScope({
    required super.notifier,
    required super.child,
  });
}

class _AsyncButtonGroupCoordinator extends ChangeNotifier {
  State? _activeButton;
  bool _disposed = false;

  bool get _isActive => _activeButton != null;

  bool _isBlocking(State button) =>
      _isActive && !identical(_activeButton, button);

  void _claim(State button) {
    assert(!_isActive, 'Members check isLocked before claiming.');
    _activeButton = button;
    notifyListeners();
  }

  void _release(State button) {
    assert(identical(_activeButton, button), 'Only the claimant releases.');
    _activeButton = null;
    // Operations outlive the group and may finish after it is removed.
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
