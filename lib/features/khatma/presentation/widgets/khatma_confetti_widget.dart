import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Multi-color celebration confetti overlay matching Reference Screenshot 26.
///
/// Pure Flutter implementation with zero external packages.
/// Uses [CustomPainter] and an [AnimationController] to animate 45 particles
/// (rectangles, ribbons, and circles) with gravity, tumbling rotation, and fade-out.
class KhatmaConfettiWidget extends StatefulWidget {
  final Duration duration;

  const KhatmaConfettiWidget({
    super.key,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<KhatmaConfettiWidget> createState() => KhatmaConfettiWidgetState();
}

class KhatmaConfettiWidgetState extends State<KhatmaConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<_ConfettiParticle> _particles = const [];
  final math.Random _random = math.Random();

  // Palette extracted from Screenshot 26:
  static const List<Color> _palette = [
    Color(0xFFE53935), // Crimson Red
    Color(0xFF007430), // Islamic Green
    Color(0xFF1E88E5), // Sky Blue
    Color(0xFFFB8C00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFFFFB300), // Amber / Gold
    Color(0xFF00897B), // Teal
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers a fresh confetti explosion.
  void play() {
    if (!mounted) return;
    _generateParticles();
    _controller.forward(from: 0.0);
  }

  /// Stops and clears confetti.
  void stop() {
    if (!mounted) return;
    _controller.stop();
    _controller.reset();
  }

  void _generateParticles() {
    final list = <_ConfettiParticle>[];
    const count = 48;

    for (int i = 0; i < count; i++) {
      final color = _palette[i % _palette.length];
      final shape = _ConfettiShape.values[i % _ConfettiShape.values.length];

      // Normalized start positions concentrated around upper-center
      final startXFraction = 0.2 + (_random.nextDouble() * 0.6);
      final startYFraction = 0.1 + (_random.nextDouble() * 0.25);

      final velocityX = (_random.nextDouble() - 0.5) * 220;
      final velocityY = 180 + (_random.nextDouble() * 320);
      final flutterAmplitude = 15 + (_random.nextDouble() * 25);
      final flutterFrequency = 4 + (_random.nextDouble() * 6);
      final rotationSpeed = (_random.nextDouble() - 0.5) * 12;
      final size = shape == _ConfettiShape.circle
          ? (4.0 + _random.nextDouble() * 4.0)
          : (8.0 + _random.nextDouble() * 6.0);

      list.add(
        _ConfettiParticle(
          color: color,
          shape: shape,
          startXFraction: startXFraction,
          startYFraction: startYFraction,
          velocityX: velocityX,
          velocityY: velocityY,
          flutterAmplitude: flutterAmplitude,
          flutterFrequency: flutterFrequency,
          initialRotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: rotationSpeed,
          size: size,
        ),
      );
    }

    setState(() {
      _particles = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isAnimating && _controller.isDismissed) {
            return const SizedBox.shrink();
          }

          return RepaintBoundary(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(
                progress: _controller.value,
                particles: _particles,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ConfettiShape { rectangle, ribbon, circle }

class _ConfettiParticle {
  final Color color;
  final _ConfettiShape shape;
  final double startXFraction;
  final double startYFraction;
  final double velocityX;
  final double velocityY;
  final double flutterAmplitude;
  final double flutterFrequency;
  final double initialRotation;
  final double rotationSpeed;
  final double size;

  const _ConfettiParticle({
    required this.color,
    required this.shape,
    required this.startXFraction,
    required this.startYFraction,
    required this.velocityX,
    required this.velocityY,
    required this.flutterAmplitude,
    required this.flutterFrequency,
    required this.initialRotation,
    required this.rotationSpeed,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    // Fade out smoothly during the final 25% of the animation
    final opacity = progress > 0.75 ? ((1.0 - progress) / 0.25).clamp(0.0, 1.0) : 1.0;
    if (opacity <= 0.0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final originX = p.startXFraction * size.width;
      final originY = p.startYFraction * size.height;

      // Trajectory with flutter and gravity
      final flutter = math.sin(progress * p.flutterFrequency * math.pi) * p.flutterAmplitude;
      final currentX = originX + (p.velocityX * progress) + flutter;
      final currentY = originY + (p.velocityY * progress) + (0.5 * 300 * progress * progress);

      final rotation = p.initialRotation + (p.rotationSpeed * progress);
      final tumbleScaleX = math.cos(rotation * 1.5).abs().clamp(0.2, 1.0);

      paint.color = p.color.withOpacity(opacity);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);
      canvas.scale(tumbleScaleX, 1.0);

      switch (p.shape) {
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case _ConfettiShape.rectangle:
          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 1.5,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1.5)), paint);
          break;
        case _ConfettiShape.ribbon:
          final ribbon = Rect.fromCenter(
            center: Offset.zero,
            width: p.size * 0.45,
            height: p.size * 2.0,
          );
          canvas.drawRRect(RRect.fromRectAndRadius(ribbon, const Radius.circular(1.0)), paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
