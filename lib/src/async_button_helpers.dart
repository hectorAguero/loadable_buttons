import 'dart:async';

import 'package:loadable_buttons/src/loading_transition.dart';
import 'package:material_ui/material_ui.dart';

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
/// Each button keeps its own State and native Material variant wiring.
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

/// Presents stack content in Material's full button layer, including padding.
///
/// The native button keeps control of padding, alignment, sizing, state, and
/// inherited styles. Loading content shares its paint, hit-test, and semantics
/// bounds instead of being translated outside the idle content's layout.
mixin StackLoadingButton on ButtonStyleButton {
  @override
  Widget? get child {
    final content = super.child;

    return content is LoadingTransition &&
            content.transitionType == TransitionAnimationType.stack
        ? content.child
        : content;
  }

  @override
  ButtonStyle? get style {
    final originalStyle = super.style;
    final content = super.child;
    if (content is! LoadingTransition ||
        content.transitionType != TransitionAnimationType.stack) {
      return originalStyle;
    }

    return (originalStyle ?? const ButtonStyle()).copyWith(
      backgroundBuilder: (context, states, child) {
        final backgroundBuilder =
            originalStyle?.backgroundBuilder ??
            themeStyleOf(context)?.backgroundBuilder ??
            defaultStyleOf(context).backgroundBuilder;

        final transition = LoadingTransition(
          child: child ?? const SizedBox.shrink(),
          loadingChild: content.loadingChild,
          isLoading: content.isLoading,
          transitionType: content.transitionType,
          animationDuration: content.animationDuration,
          minimumChildOpacity: content.minimumChildOpacity,
          animateChildSize: content.animateChildSize,
          preserveChildConstraints: true,
        );

        return backgroundBuilder?.call(context, states, transition) ??
            transition;
      },
    );
  }
}

/// Keeps Material's original clipping policy when adding the loading layer.
Clip resolveButtonClipBehavior({
  required Clip? clipBehavior,
  required ButtonStyle? style,
  required ButtonStyle? themeStyle,
}) =>
    clipBehavior ??
    ((style?.backgroundBuilder ?? themeStyle?.backgroundBuilder) != null ||
            (style?.foregroundBuilder ?? themeStyle?.foregroundBuilder) != null
        ? Clip.antiAlias
        : Clip.none);

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
    // WidgetState is available in Flutter 3.22. Resolve each foreground
    // in the normal state before applying precedence.
    color:
        color ??
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
