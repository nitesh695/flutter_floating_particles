import 'package:flutter/material.dart';
import '../models/particle_config.dart';
import '../models/particle_data.dart';
import '../painters/particle_painter.dart';

/// The main widget that wraps any child widget with particle effects.
///
/// This widget creates an animated overlay of particles that move across
/// the screen according to the provided configuration. The child widget
/// remains fully interactive while particles animate in the background.
///
/// Example usage:
/// ```dart
/// ParticleEffects(
///   config: ParticleConfig.snow,
///   child: Scaffold(
///     body: YourContent(),
///   ),
/// )
/// ```
class ParticleEffects extends StatefulWidget {
  /// The child widget to wrap with particle effects
  final Widget child;

  /// Configuration defining the particle animation behavior
  final ParticleConfig config;

  /// Whether the particle animation is currently enabled
  final bool isEnabled;

  /// Callback triggered when animation completes a cycle (optional)
  final VoidCallback? onAnimationComplete;

  const ParticleEffects({
    Key? key,
    required this.child,
    this.config = const ParticleConfig(),
    this.isEnabled = true,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<ParticleEffects> createState() => _ParticleEffectsState();
}

class _ParticleEffectsState extends State<ParticleEffects>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<ParticleData> _particles = [];
  bool _isInitialized = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupAnimation();
    _generateParticles();
    _isInitialized = true;
  }

  /// Sets up the animation controller and animation curve.
  void _setupAnimation() {
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    if (widget.isEnabled) {
      _animationController.repeat();
    }
  }

  /// Generates all particles based on the current configuration.
  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < widget.config.particleCount; i++) {
      _particles.add(ParticleData.generate(i, widget.config));
    }
  }

  @override
  void didUpdateWidget(ParticleEffects oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Regenerate particles if configuration changed
    if (oldWidget.config != widget.config) {
      _generateParticles();

      // Update animation duration if it changed
      if (oldWidget.config.animationDuration != widget.config.animationDuration) {
        _animationController.duration = widget.config.animationDuration;
      }
    }

    // Handle enable/disable state changes
    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Child widget (the content being wrapped)
        widget.child,

        // Particle overlay
        if (widget.isEnabled && _isInitialized)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(
                      particles: _particles,
                      animation: _animation,
                      config: widget.config,
                      screenSize: MediaQuery.of(context).size,
                      startTime: _startTime,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// A simplified version of ParticleEffects for basic use cases.
///
/// This widget provides common presets and simplified configuration
/// for users who want quick particle effects without detailed customization.
class SimpleParticleEffects extends StatelessWidget {
  /// The child widget to wrap with particle effects
  final Widget child;

  /// Predefined effect type
  final ParticleEffectType effectType;

  /// Intensity of the effect (0.1 to 2.0, where 1.0 is normal)
  final double intensity;

  /// Whether the effect is enabled
  final bool isEnabled;

  const SimpleParticleEffects({
    Key? key,
    required this.child,
    this.effectType = ParticleEffectType.snow,
    this.intensity = 1.0,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getConfigForType(effectType, intensity);

    return ParticleEffects(
      config: config,
      isEnabled: isEnabled,
      child: child,
    );
  }

  /// Returns the appropriate configuration for the given effect type.
  ParticleConfig _getConfigForType(ParticleEffectType type, double intensity) {
    ParticleConfig baseConfig;

    switch (type) {
      case ParticleEffectType.snow:
        baseConfig = ParticleConfig.snow;
        break;
      case ParticleEffectType.rain:
        baseConfig = ParticleConfig.rain;
        break;
      case ParticleEffectType.fireAshes:
        baseConfig = ParticleConfig.fireAshes;
        break;
      case ParticleEffectType.bubbles:
        baseConfig = ParticleConfig.bubbles;
        break;
      case ParticleEffectType.stars:
        baseConfig = ParticleConfig.stars;
        break;
      case ParticleEffectType.hearts:
        baseConfig = ParticleConfig.hearts;
        break;
      case ParticleEffectType.confetti:
        baseConfig = ParticleConfig.confetti;
        break;
      case ParticleEffectType.fallingLeaves:
        baseConfig = ParticleConfig.fallingLeaves;
        break;
    }

    // Apply intensity scaling
    return ParticleConfig(
      particleType: baseConfig.particleType,
      direction: baseConfig.direction,
      particleCount: (baseConfig.particleCount * intensity).round().clamp(1, 500),
      minSize: baseConfig.minSize * intensity.clamp(0.5, 2.0),
      maxSize: baseConfig.maxSize * intensity.clamp(0.5, 2.0),
      animationDuration: Duration(
        milliseconds: (baseConfig.animationDuration.inMilliseconds / intensity)
            .round()
            .clamp(2000, 60000),
      ),
      particleColor: baseConfig.particleColor,
      imagePath: baseConfig.imagePath,
      customParticle: baseConfig.customParticle,
      minOpacity: baseConfig.minOpacity,
      maxOpacity: baseConfig.maxOpacity,
      enableGlow: baseConfig.enableGlow,
      glowRadius: baseConfig.glowRadius * intensity.clamp(0.5, 2.0),
      enableRotation: baseConfig.enableRotation,
      velocityMultiplier: baseConfig.velocityMultiplier * intensity.clamp(0.5, 3.0),
      enableSizeVariation: baseConfig.enableSizeVariation,
      enableOpacityAnimation: baseConfig.enableOpacityAnimation,
      gradientColors: baseConfig.gradientColors,
      enableBlur: baseConfig.enableBlur,
      blurSigma: baseConfig.blurSigma,
    );
  }
}

/// Predefined particle effect types for SimpleParticleEffects.
enum ParticleEffectType {
  snow,
  rain,
  fireAshes,
  bubbles,
  stars,
  hearts,
  confetti,
  fallingLeaves,
}