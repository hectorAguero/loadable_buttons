import 'package:flutter/material.dart';

import 'package:loadable_buttons/src/transition_animation_type.dart';

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

  @override
  Widget build(BuildContext context) {
    if (transitionType == TransitionAnimationType.stack) {
      final idleContent = _InactiveContent(active: !isLoading, child: child);

      return Stack(
        alignment: Alignment.center,
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
              child: _InactiveContent(active: isLoading, child: loadingChild),
            ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      child: KeyedSubtree(
        key: ValueKey(isLoading),
        child: isLoading ? loadingChild : child,
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: AnimatedSize(duration: animationDuration, child: child),
      ),
      // Re-evaluate outgoing content here instead of retaining an idle guard
      // captured by transitionBuilder. Preserve each switcher entry's key.
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        children: [
          for (final previousChild in previousChildren)
            _InactiveContent(
              key: previousChild.key,
              active: false,
              child: previousChild,
            ),
          if (currentChild != null)
            _InactiveContent(
              key: currentChild.key,
              active: true,
              child: currentChild,
            ),
        ],
      ),
    );
  }
}

class _InactiveContent extends StatelessWidget {
  const _InactiveContent(
      {required this.active, required this.child, super.key});

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
