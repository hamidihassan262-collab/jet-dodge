import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/jet_dodge_game.dart';

class MissileComponent extends PositionComponent with HasGameReference<JetDodgeGame> {
  final int level;
  double speed;
  double homingStrength;
  double _age = 0;
  final double _maxAge = 15.0;
  final List<_MissileTrail> _trail = [];
  bool _isExpired = false;
  double _slowMultiplier = 1.0;

  MissileComponent({
    required Vector2 startPosition,
    this.level = 1,
    this.speed = 120,
    this.homingStrength = 2.0,
  }) : super(
          position: startPosition,
          size: Vector2(8, 16),
          anchor: Anchor.center,
        );

  bool get isExpired => _isExpired;

  void applySlow(double multiplier) {
    _slowMultiplier = multiplier;
  }

  void removeSlow() {
    _slowMultiplier = 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (_age > _maxAge) {
      _isExpired = true;
      removeFromParent();
      return;
    }

    // Get jet position and home toward it
    final jet = game.jet;
    final diff = jet.position - position;
    final targetAngle = atan2(diff.y, diff.x);
    
    // Smooth rotation toward target
    double currentAngle = angle - pi / 2;
    double angleDiff = targetAngle - currentAngle;
    while (angleDiff > pi) { angleDiff -= 2 * pi; }
    while (angleDiff < -pi) { angleDiff += 2 * pi; }
    
    final effectiveHoming = homingStrength * _slowMultiplier;
    currentAngle += angleDiff * min(effectiveHoming * dt, 1.0);
    angle = currentAngle + pi / 2;

    // Move forward
    final effectiveSpeed = speed * _slowMultiplier;
    position.x += cos(currentAngle) * effectiveSpeed * dt;
    position.y += sin(currentAngle) * effectiveSpeed * dt;

    // Add trail
    if (_trail.length < 20) {
      _trail.add(_MissileTrail(
        position: position.clone(),
        life: 0.4,
        maxLife: 0.4,
      ));
    }
    _trail.removeWhere((t) {
      t.life -= dt;
      return t.life <= 0;
    });

    // Remove if way off screen
    final margin = 200.0;
    if (position.x < -margin || position.x > game.size.x + margin ||
        position.y < -margin || position.y > game.size.y + margin) {
      _isExpired = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centerX = size.x / 2;
    final centerY = size.y / 2;
    
    // Missile grows and gets redder with age
    final ageRatio = (_age / _maxAge).clamp(0.0, 1.0);
    final sizeScale = 1.0 + ageRatio * 1.5;
    final redAmount = (0.3 + ageRatio * 0.7).clamp(0.0, 1.0);

    // Draw trail
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(-angle);
    canvas.translate(-position.x, -position.y);
    for (final t in _trail) {
      final alpha = (t.life / t.maxLife * 150).toInt().clamp(0, 255);
      final trailPaint = Paint()
        ..color = Color.fromARGB(alpha, 255, (100 * (1 - redAmount)).toInt(), 0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      final trailSize = 3.0 * (t.life / t.maxLife) * sizeScale;
      canvas.drawCircle(Offset(t.position.x, t.position.y), trailSize, trailPaint);
    }
    canvas.restore();

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(sizeScale);
    canvas.translate(-centerX, -centerY);

    // Missile body color based on level
    Color bodyColor;
    Color tipColor;
    switch (level) {
      case 1:
        bodyColor = Color.lerp(const Color(0xFF666666), const Color(0xFFFF0000), redAmount)!;
        tipColor = const Color(0xFFFF6D00);
        break;
      case 2:
        bodyColor = Color.lerp(const Color(0xFF8B4513), const Color(0xFFFF0000), redAmount)!;
        tipColor = const Color(0xFFFF4500);
        break;
      case 3:
        bodyColor = Color.lerp(const Color(0xFF2E2E2E), const Color(0xFFCC0000), redAmount)!;
        tipColor = const Color(0xFFFF0000);
        break;
      case 4:
        bodyColor = Color.lerp(const Color(0xFF1A1A2E), const Color(0xFFBB0000), redAmount)!;
        tipColor = const Color(0xFFDD0000);
        break;
      default:
        bodyColor = Color.lerp(const Color(0xFF0D0D0D), const Color(0xFF990000), redAmount)!;
        tipColor = const Color(0xFFCC0000);
        break;
    }

    // Missile body
    final bodyPaint = Paint()..color = bodyColor;
    final bodyPath = Path()
      ..moveTo(centerX, 0)
      ..lineTo(centerX + 3, 4)
      ..lineTo(centerX + 3, size.y - 3)
      ..lineTo(centerX, size.y)
      ..lineTo(centerX - 3, size.y - 3)
      ..lineTo(centerX - 3, 4)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Warhead tip
    final tipPaint = Paint()..color = tipColor;
    canvas.drawCircle(Offset(centerX, 3), 3, tipPaint);

    // Fins
    final finPaint = Paint()..color = bodyColor.withAlpha(200);
    // Left fin
    final leftFin = Path()
      ..moveTo(centerX - 3, size.y - 5)
      ..lineTo(centerX - 6, size.y)
      ..lineTo(centerX - 3, size.y - 2)
      ..close();
    canvas.drawPath(leftFin, finPaint);
    // Right fin
    final rightFin = Path()
      ..moveTo(centerX + 3, size.y - 5)
      ..lineTo(centerX + 6, size.y)
      ..lineTo(centerX + 3, size.y - 2)
      ..close();
    canvas.drawPath(rightFin, finPaint);

    // Glow effect for higher levels
    if (level >= 3) {
      final glowPaint = Paint()
        ..color = tipColor.withAlpha((60 + sin(_age * 8) * 30).toInt().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(centerX, centerY), 8, glowPaint);
    }

    canvas.restore();
  }

  Rect get hitbox {
    final ageRatio = (_age / _maxAge).clamp(0.0, 1.0);
    final sizeScale = 1.0 + ageRatio * 1.5;
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x * sizeScale * 0.6,
      height: size.y * sizeScale * 0.6,
    );
  }
}

class _MissileTrail {
  Vector2 position;
  double life;
  double maxLife;

  _MissileTrail({
    required this.position,
    required this.life,
    required this.maxLife,
  });
}
