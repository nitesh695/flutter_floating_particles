/// Defines the direction of particle movement animation.
enum ParticleDirection {
  /// Particles fall from top to bottom (like snow, rain, or falling leaves)
  topToBottom,

  /// Particles rise from bottom to top (like fire ashes, bubbles, or smoke)
  bottomToTop,

  /// Particles move from left to right across the screen
  leftToRight,

  /// Particles move from right to left across the screen
  rightToLeft,

  /// Particles move diagonally from top-left to bottom-right
  diagonal,
}