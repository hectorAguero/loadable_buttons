/// Enum to define the type of loading animation.
enum TransitionAnimationType {
  /// Fades loading content over idle content retained in the layout.
  ///
  /// Larger loading content can expand the button within its constraints.
  /// Idle content is inactive while loading, even if partially visible.
  stack,

  /// Fades between idle and loading content.
  ///
  /// Outgoing content remains in the layout until its fade ends, with pointer
  /// input, focus, and semantics excluded in both directions.
  animatedSwitcher,

  /// Uses the supplied custom builder to present the loading state.
  ///
  /// The builder owns sizing, interaction, focus, and semantics.
  customBuilder,
}
