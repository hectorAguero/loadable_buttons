/// Enum to define the type of loading animation.
enum TransitionAnimationType {
  /// Stack loading animation, it allow to mantain the size of the button
  /// based on the biggest child.
  stack,

  /// AnimatedSwitcher loading animation, it uses AnimatedSwitcher to
  /// animate the loading animation, which replace the child and loadingChild.
  animatedSwitcher,

  /// Custom builder loading animation, it uses a custom builder to
  /// animate the loading animation, which replace the child and loadingChild.
  customBuilder,
}
