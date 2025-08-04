import 'dart:math';
import 'package:flutter/material.dart';
import 'particle_config.dart';

/// Represents the properties of an individual particle.
///
/// Each particle has unique characteristics like position, size, color,
/// and animation properties that make the overall effect look natural.
class ParticleData {
  /// Initial horizontal position as a percentage (0.0 to 1.0)
  final double initialX;

  /// Initial vertical position as a percentage (0.0 to 1.0)
  final double initialY;

  /// Size of the particle in logical pixels
  final double size;

  /// Movement speed multiplier for this particle
  final double velocity;

  /// Rotation speed in radians per animation cycle
  final double rotationSpeed;

  /// Phase offset for animation timing to create variety
  final double animationOffset;

  /// Color of this specific particle
  final Color color;

  /// Optional image path for image-based particles
  final String? imagePath;

  const ParticleData({
    required this.initialX,
    required this.initialY,
    required this.size,
    required this.velocity,
    required this.rotationSpeed,
    required this.animationOffset,
    required this.color,
    this.imagePath,
  });

  /// Generates a random particle with properties based on the given configuration.
  ///
  /// Uses a seeded random generator to ensure consistent results across rebuilds
  /// while still providing natural-looking variation between particles.
  static ParticleData generate(int index, ParticleConfig config) {
    final random = Random(index);

    return ParticleData(
      initialX: random.nextDouble(),
      initialY: random.nextDouble(),
      size: config.minSize +
          random.nextDouble() * (config.maxSize - config.minSize),
      velocity: 0.5 + random.nextDouble() * 0.5,
      rotationSpeed: (random.nextDouble() - 0.5) * 4,
      animationOffset: random.nextDouble() * 2 * pi,
      color: _generateParticleColor(config, random),
      imagePath: config.imagePath,
    );
  }

  /// Generates a color for the particle based on the configuration.
  static Color _generateParticleColor(ParticleConfig config, Random random) {
    // Use specific color if provided
    if (config.particleColor != null) {
      return config.particleColor!;
    }

    // Use gradient colors if provided
    if (config.gradientColors != null && config.gradientColors!.isNotEmpty) {
      final index = random.nextInt(config.gradientColors!.length);
      return config.gradientColors![index];
    }

    // Default to white
    return Colors.white;
  }
}