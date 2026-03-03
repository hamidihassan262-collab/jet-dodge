import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ExplosionComponent extends PositionComponent {
  double _age = 0;
  final double _duration = 1.5;
  final List<_ExplosionParticle> _particles = [];
  final List<_ExplosionRing> _rings = [];
  final Random _random = Random();
  bool _isDone = false;

  ExplosionComponent({required Vector2 pos})
      : super(position: pos, size: Vector2(200, 200), anchor: Anchor.center) {
    // Create explosion particles
    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 200;
      _particles.add(_ExplosionParticle(
        position: Vector2.zero(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        life: 0.5 + _random.nextDouble() * 1.0,
        maxLife: 0.5 + _random.nextDouble() * 1.0,
        color: _randomFireColor(),
        size: 2 + _random.nextDouble() * 6,
      ));
    }
    // Debris particles
    for (int i = 0; i < 15; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30 + _random.nextDouble() * 150;
      _particles.add(_ExplosionParticle(
        position: Vector2.zero(),
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        life: 0.8 + _random.nextDouble() * 0.7,
        maxLife: 0.8 + _random.nextDouble() * 0.7,
        color: const Color(0xFF424242),
        size: 1 + _random.nextDouble() * 3,
      ));
    }
    // Shockwave rings
    _rings.add(_ExplosionRing(radius: 0, maxRadius: 80, life: 0.6, maxLife: 0.6, color: const Color(0xFFFF6D00)));
    _rings.add(_ExplosionRing(radius: 0, maxRadius: 120, life: 0.8, maxLife: 0.8, color: const Color(0xFFFF0000)));
    _rings.add(_ExplosionRing(radius: 0, maxRadius: 50, life: 0.4, maxLife: 0.4, color: const Color(0xFFFFFFFF)));
  }

  Color _randomFireColor() {
    final colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF4500),
      const Color(0xFFFF6D00),
      const Color(0xFFFFAB00),
      const Color(0xFFFFD600),
      const Color(0xFFFFFFFF),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  bool get isDone => _isDone;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (_age > _duration) {
      _isDone = true;
      removeFromParent();
      return;
    }

    for (final p in _particles) {
      p.life -= dt;
      p.position += p.velocity * dt;
      p.velocity *= 0.95;
    }
    _particles.removeWhere((p) => p.life <= 0);

    for (final r in _rings) {
      r.life -= dt;
      r.radius = r.maxRadius * (1.0 - r.life / r.maxLife);
    }
    _rings.removeWhere((r) => r.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Draw rings
    for (final r in _rings) {
      final alpha = (r.life / r.maxLife * 200).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = r.color.withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (r.life / r.maxLife)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(cx, cy), r.radius, paint);
    }

    // Flash at start
    if (_age < 0.15) {
      final flashAlpha = ((1.0 - _age / 0.15) * 200).toInt().clamp(0, 255);
      final flashPaint = Paint()
        ..color = Colors.white.withAlpha(flashAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(cx, cy), 40 * (1.0 - _age / 0.15), flashPaint);
    }

    // Draw particles
    for (final p in _particles) {
      if (p.life <= 0) continue;
      final alpha = (p.life / p.maxLife * 255).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(cx + p.position.x, cy + p.position.y),
        p.size * (p.life / p.maxLife),
        paint,
      );
    }
  }
}

class _ExplosionParticle {
  Vector2 position;
  Vector2 velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  _ExplosionParticle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
  });
}

class _ExplosionRing {
  double radius;
  double maxRadius;
  double life;
  double maxLife;
  Color color;

  _ExplosionRing({
    required this.radius,
    required this.maxRadius,
    required this.life,
    required this.maxLife,
    required this.color,
  });
}
