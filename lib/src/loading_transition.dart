import 'package:material_ui/material_ui.dart';

/// The type of animation between idle and loading content.
enum TransitionAnimationType {
  /// Fades loading content over idle content retained in the layout.
  ///
  /// Larger loading content can expand the button within its constraints.
  /// Smaller loading content normally fits within the retained idle size.
  /// Text scaling and parent constraints still affect layout; this is not a
  /// fixed-size guarantee.
  /// Idle content is inactive while loading, even if partially visible.
  stack,

  /// Fades between idle and loading content.
  ///
  /// Outgoing content remains in the layout until its fade ends, with pointer
  /// input, focus, and semantics excluded in both directions.
  /// The shared layout animates its resize, including the shrink after outgoing
  /// content is removed.
  animatedSwitcher,

  /// Uses the supplied custom builder to present the loading state.
  ///
  /// The builder owns sizing, interaction, focus, and semantics.
  /// It receives effective loading, idle content, and the supplied nullable
  /// loading content without a default spinner. Retained inactive or outgoing
  /// content must be isolated by the builder.
  customBuilder,
}

/// Internal presentation shared by the built-in button transitions.
class LoadingTransition extends StatelessWidget {
  /// Creates a stack or switcher transition with inactive content isolated.
  const LoadingTransition({
    required this.child,
    required this.loadingChild,
    required this.isLoading,
    required this.transitionType,
    required this.animationDuration,
    required this.minimumChildOpacity,
    this.animateChildSize = true,
    this.preserveChildConstraints = false,
    super.key,
  }) : assert(transitionType != TransitionAnimationType.customBuilder);

  /// The idle content.
  final Widget child;

  /// The resolved loading content.
  final Widget loadingChild;

  /// Whether the loading content is current.
  final bool isLoading;

  /// The built-in transition to use.
  final TransitionAnimationType transitionType;

  /// The duration of the transition.
  final Duration animationDuration;

  /// The idle content's visual opacity while loading.
  final double minimumChildOpacity;

  /// Whether stack content uses animated sizing, as on Material text buttons.
  final bool animateChildSize;

  /// Keeps native full-button constraints when wrapping its background layer.
  final bool preserveChildConstraints;

  @override
  Widget build(BuildContext context) {
    if (transitionType == TransitionAnimationType.stack) {
      final idleContent = _InactiveContent(active: !isLoading, child: child);

      return Stack(
        alignment: Alignment.center,
        fit: preserveChildConstraints ? StackFit.passthrough : StackFit.loose,
        children: [
          AnimatedOpacity(
            opacity: isLoading ? minimumChildOpacity : 1.0,
            duration: animationDuration,
            child: animateChildSize
                ? AnimatedSize(duration: animationDuration, child: idleContent)
                : idleContent,
          ),
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: animationDuration,
            child: Visibility(
              visible: isLoading,
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: _InactiveContent(active: isLoading, child: loadingChild),
              ),
            ),
          ),
        ],
      );
    }

    // Animate the shared layout, including its shrink when an outgoing entry
    // is removed. Per-entry size animations start fresh with each keyed child.
    return AnimatedSize(
      duration: animationDuration,
      child: AnimatedSwitcher(
        duration: animationDuration,
        child: KeyedSubtree(
          key: ValueKey(isLoading),
          child: isLoading ? loadingChild : child,
        ),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        // Re-evaluate outgoing content here instead of retaining an idle guard
        // captured by transitionBuilder. Preserve each switcher entry's key.
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          children: [
            for (final previousChild in previous)
              _InactiveContent(
                key: previousChild.key,
                active: false,
                child: previousChild,
              ),
            if (current != null)
              _InactiveContent(key: current.key, active: true, child: current),
          ],
        ),
      ),
    );
  }
}

class _InactiveContent extends StatelessWidget {
  const _InactiveContent({
    required this.active,
    required this.child,
    super.key,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !active,
    child: ExcludeFocus(
      excluding: !active,
      child: ExcludeSemantics(excluding: !active, child: child),
    ),
  );
}
