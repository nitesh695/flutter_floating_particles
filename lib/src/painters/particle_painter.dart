import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/particle_config.dart';
import '../models/particle_data.dart';
import '../models/particle_type.dart';
import '../models/direction.dart';

/// Custom painter responsible for rendering all particles on the canvas.
///
/// This painter efficiently draws hundreds of particles using Flutter's
/// CustomPainter API, providing smooth 60fps animations.
class ParticlePainter extends CustomPainter {
  /// List of all particles to render
  final List<ParticleData> particles;

  /// Current animation progress (0.0 to 1.0)
  final Animation<double> animation;

  /// Configuration defining how particles should look and behave
  final ParticleConfig config;

  /// Screen dimensions for positioning calculations
  final Size screenSize;

  /// Start time for time-based animation
  final DateTime startTime;

  const ParticlePainter({
    required this.particles,
    required this.animation,
    required this.config,
    required this.screenSize,
    required this.startTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each particle
    for (final particle in particles) {
      _drawParticle(canvas, size, particle);
    }
  }

  /// Draws a single particle at its current animation position.
  void _drawParticle(Canvas canvas, Size size, ParticleData particle) {
    // Use time-based animation for continuous movement
    final currentTime = DateTime.now();
    final elapsedTime = currentTime.difference(startTime).inMilliseconds;
    final timeProgress = (elapsedTime / config.animationDuration.inMilliseconds) % 1.0;

    final position = _calculatePosition(size, particle, timeProgress);
    final opacity = _calculateOpacity(particle, timeProgress);
    final rotation = config.enableRotation ?
    timeProgress * 2 * pi * particle.rotationSpeed : 0.0;

    // Skip drawing if particle is completely transparent
    if (opacity <= 0.0) {
      return;
    }

    canvas.save();
    canvas.translate(position.dx, position.dy);

    if (config.enableRotation) {
      canvas.rotate(rotation);
    }

    final paint = Paint()
      ..color = particle.color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Apply glow effect if enabled
    if (config.enableGlow) {
      paint.maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        config.glowRadius,
      );
    }

    // Apply blur effect if enabled
    if (config.enableBlur) {
      paint.imageFilter = ImageFilter.blur(
        sigmaX: config.blurSigma,
        sigmaY: config.blurSigma,
      );
    }

    _drawParticleShape(canvas, particle, paint);

    canvas.restore();
  }

  /// Calculates the current position of a particle based on time progress.
  Offset _calculatePosition(Size size, ParticleData particle, double timeProgress) {
    double x, y;

    // Calculate particle-specific progress with offset for staggered animation
    final particleProgress = (timeProgress + particle.animationOffset) % 1.0;
    final adjustedProgress = particleProgress * particle.velocity * config.velocityMultiplier;

    switch (config.direction) {
      case ParticleDirection.topToBottom:
        x = particle.initialX * size.width;
        // Particles continuously fall from top to bottom
        y = -100 + (adjustedProgress * (size.height + 200));
        // Add natural horizontal drift
        x += 30 * sin(adjustedProgress * 2 * pi + particle.animationOffset);
        break;

      case ParticleDirection.bottomToTop:
        x = particle.initialX * size.width;
        y = size.height + 100 - (adjustedProgress * (size.height + 200));
        x += 20 * sin(adjustedProgress * 3 * pi + particle.animationOffset);
        break;

      case ParticleDirection.leftToRight:
        x = -100 + (adjustedProgress * (size.width + 200));
        y = particle.initialY * size.height;
        y += 15 * cos(adjustedProgress * 2 * pi + particle.animationOffset);
        break;

      case ParticleDirection.rightToLeft:
        x = size.width + 100 - (adjustedProgress * (size.width + 200));
        y = particle.initialY * size.height;
        y += 15 * cos(adjustedProgress * 2 * pi + particle.animationOffset);
        break;

      case ParticleDirection.diagonal:
        x = adjustedProgress * size.width;
        y = adjustedProgress * size.height;
        break;
    }

    return Offset(x, y);
  }

  /// Calculates the current opacity of a particle.
  double _calculateOpacity(ParticleData particle, double timeProgress) {
    if (!config.enableOpacityAnimation) {
      return config.maxOpacity;
    }

    // Use time-based progress for continuous animation
    final particleProgress = (timeProgress + particle.animationOffset) % 1.0;

    // Create smooth opacity animation using sine wave
    final baseOpacity = config.minOpacity +
        (config.maxOpacity - config.minOpacity) *
            (0.5 + 0.5 * sin(particleProgress * 4 * pi + particle.animationOffset));

    return baseOpacity.clamp(0.0, 1.0);
  }

  /// Draws the actual shape of the particle.
  void _drawParticleShape(Canvas canvas, ParticleData particle, Paint paint) {
    switch (config.particleType) {
      case ParticleType.circle:
        canvas.drawCircle(
          Offset.zero,
          particle.size / 2,
          paint,
        );
        break;

      case ParticleType.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
        break;

      case ParticleType.star:
        _drawStar(canvas, particle.size, paint);
        break;

      case ParticleType.heart:
        _drawHeart(canvas, particle.size, paint);
        break;

      case ParticleType.image:
      // Image drawing would require loading and caching images
      // For now, fallback to circle
        canvas.drawCircle(
          Offset.zero,
          particle.size / 2,
          paint,
        );
        break;

      case ParticleType.custom:
      // Custom particle drawing - users can extend this
      // For now, fallback to circle
        canvas.drawCircle(
          Offset.zero,
          particle.size / 2,
          paint,
        );
        break;
    }
  }

  /// Draws a star shape with the given size and paint.
  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * pi) / 5 - pi / 2; // Start from top
      final r = i % 2 == 0 ? radius : innerRadius;
      final x = r * cos(angle);
      final y = r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  /// Draws a heart shape with the given size and paint.
  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final scale = size / 16; // Scale factor for heart shape

    // Heart shape coordinates (scaled)
    path.moveTo(0, 4 * scale);
    path.cubicTo(-8 * scale, -4 * scale, -8 * scale, 4 * scale, 0, 8 * scale);
    path.cubicTo(8 * scale, 4 * scale, 8 * scale, -4 * scale, 0, 4 * scale);

    canvas.drawPath(path, paint);
  }

  // /// Checks if a particle is visible within the screen bounds.
  // bool _isParticleVisible(Offset position, Size screenSize, double particleSize) {
  //   final margin = particleSize * 2; // Add margin for glow effects
  //   return position.dx >= -margin &&
  //       position.dx <= screenSize.width + margin &&
  //       position.dy >= -margin &&
  //       position.dy <= screenSize.height + margin;
  // }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    // Always repaint for continuous time-based animation
    return true;
  }
}