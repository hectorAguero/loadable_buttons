# Callback error policy

This contract defines the v2 `onError` API before implementation, addressing
[#35](https://github.com/hectorAguero/loadable_buttons/issues/35).

Every button family and constructor accepts an optional `AsyncButtonErrorHandler`
with the signature `FutureOr<void> Function(Object error, StackTrace stackTrace)`.
The policy covers synchronous throws from `onPressed` and failures of the Future
it returns. It does not intercept `onLongPress`, builders, or unreturned/unawaited
application Futures.

- Without a handler, the original error propagates with its original stack trace.
  Native button activation accepts a synchronous callback, so an unhandled
  failure reaches the caller's zone through the package's handler Future.
- Supplying `onError` explicitly consumes the callback error when the handler
  completes successfully. The package does not also log or report that error.
  Applications may report it or rethrow it from their handler.
- Handlers may be synchronous or asynchronous. Internal loading and the
  synchronous reentry lock stay active until both `onPressed` and any handler
  finish. Completion clears only internal loading; external `loading` remains
  independent. Controllers must use this same policy if added later.
- A handler is called exactly once for each failed activation, receiving the
  original error and stack trace. A handler failure propagates with its own stack
  trace and does not invoke `onError` again. Internal loading still clears.
- An activation captures its callback and error handler when it starts. Rebuilds
  may change them for subsequent activations, but not for work already in flight.
- Disposal does not cancel the callback or suppress error handling or propagation.
  An already captured handler still runs after disposal. The package never calls
  `setState` after disposal and supplies no `BuildContext`. Applications must
  check their own lifecycle before accessing captured state or context.

The package introduces no persistent error state, Snackbar, dialog, retry policy,
or cancellation policy. Material and Cupertino buttons share this contract. Future adaptive buttons and
shared controllers must preserve it.
