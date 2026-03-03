import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/powerup_model.dart';
import '../game/jet_dodge_game.dart';

class PowerUpComponent extends PositionComponent with HasGameReference<JetDodgeGame> {
  final PowerUpType type;
  double _age = 0;
  final double _lifetime = 8.0;
  bool _collected = false;

  PowerUpComponent({
    required this.type,
    required Vector2 spawnPosition,
  }) : super(
          position: spawnPosition,
          size: Vector2(30, 30),
          anchor: Anchor.center,
        );

  bool get isCollected => _collected;
  bool get isExpired => _age > _lifetime;

  void collect() {
    _collected = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age > _lifetime && !_collected) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_collected) return;

    final config = PowerUpConfig.getConfig(type);
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final pulse = 1.0 + sin(_age * 4) * 0.1;
    final fadeAlpha = _age > _lifetime - 2.0
        ? (((_lifetime - _age) / 2.0) * 255).toInt().clamp(0, 255)
        : 255;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(pulse);
    canvas.translate(-centerX, -centerY);

    // Outer glow
    final glowPaint = Paint()
      ..color = config.color.withAlpha((80 * fadeAlpha / 255).toInt())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(centerX, centerY), 18, glowPaint);

    // Background circle
    final bgPaint = Paint()
      ..color = config.color.withAlpha((180 * fadeAlpha / 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 13, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(fadeAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), 13, borderPaint);

    // Icon representation (simple shapes for each powerup)
    final iconPaint = Paint()
      ..color = Colors.white.withAlpha(fadeAlpha)
      ..style = PaintingStyle.fill;

    _drawPowerUpIcon(canvas, centerX, centerY, iconPaint);

    canvas.restore();
  }

  void _drawPowerUpIcon(Canvas canvas, double cx, double cy, Paint paint) {
    switch (type) {
      case PowerUpType.shield:
        // Shield shape
        final path = Path()
          ..moveTo(cx, cy - 7)
          ..lineTo(cx + 6, cy - 3)
          ..lineTo(cx + 5, cy + 4)
          ..lineTo(cx, cy + 7)
          ..lineTo(cx - 5, cy + 4)
          ..lineTo(cx - 6, cy - 3)
          ..close();
        canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
      case PowerUpType.doubleTime:
        // Fast forward arrows
        final path = Path()
          ..moveTo(cx - 5, cy - 5)
          ..lineTo(cx, cy)
          ..lineTo(cx - 5, cy + 5);
        canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 2);
        final path2 = Path()
          ..moveTo(cx + 1, cy - 5)
          ..lineTo(cx + 6, cy)
          ..lineTo(cx + 1, cy + 5);
        canvas.drawPath(path2, paint);
        break;
      case PowerUpType.doublePoints:
        // x2 text
        final tp = TextPainter(
          text: TextSpan(text: 'x2', style: TextStyle(color: paint.color, fontSize: 10, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
        break;
      case PowerUpType.erasure:
        // X mark
        canvas.drawLine(Offset(cx - 5, cy - 5), Offset(cx + 5, cy + 5), paint..style = PaintingStyle.stroke..strokeWidth = 2.5);
        canvas.drawLine(Offset(cx + 5, cy - 5), Offset(cx - 5, cy + 5), paint);
        break;
      case PowerUpType.speed:
        // Lightning bolt
        final path = Path()
          ..moveTo(cx + 2, cy - 7)
          ..lineTo(cx - 3, cy)
          ..lineTo(cx + 1, cy)
          ..lineTo(cx - 2, cy + 7)
          ..lineTo(cx + 3, cy)
          ..lineTo(cx - 1, cy)
          ..close();
        canvas.drawPath(path, paint..style = PaintingStyle.fill);
        break;
      case PowerUpType.magneticField:
        // Magnetic field circles
        canvas.drawCircle(Offset(cx, cy), 6, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawCircle(Offset(cx, cy), 3, paint);
        break;
      case PowerUpType.ghostMode:
        // Ghost shape
        final path = Path()
          ..moveTo(cx, cy - 7)
          ..quadraticBezierTo(cx + 7, cy - 7, cx + 7, cy)
          ..lineTo(cx + 7, cy + 5)
          ..lineTo(cx + 4, cy + 3)
          ..lineTo(cx, cy + 6)
          ..lineTo(cx - 4, cy + 3)
          ..lineTo(cx - 7, cy + 5)
          ..lineTo(cx - 7, cy)
          ..quadraticBezierTo(cx - 7, cy - 7, cx, cy - 7);
        canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
      case PowerUpType.emp:
        // EMP wave
        canvas.drawCircle(Offset(cx, cy), 4, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawCircle(Offset(cx, cy), 7, paint..strokeWidth = 1);
        canvas.drawCircle(Offset(cx, cy), 2, paint..style = PaintingStyle.fill);
        break;
      case PowerUpType.timeWarp:
        // Hourglass
        final path = Path()
          ..moveTo(cx - 5, cy - 7)
          ..lineTo(cx + 5, cy - 7)
          ..lineTo(cx + 1, cy)
          ..lineTo(cx + 5, cy + 7)
          ..lineTo(cx - 5, cy + 7)
          ..lineTo(cx - 1, cy)
          ..close();
        canvas.drawPath(path, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        break;
      case PowerUpType.miniaturize:
        // Shrink arrows
        canvas.drawLine(Offset(cx - 6, cy - 6), Offset(cx - 2, cy - 2), paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawLine(Offset(cx + 6, cy - 6), Offset(cx + 2, cy - 2), paint);
        canvas.drawLine(Offset(cx - 6, cy + 6), Offset(cx - 2, cy + 2), paint);
        canvas.drawLine(Offset(cx + 6, cy + 6), Offset(cx + 2, cy + 2), paint);
        break;
    }
  }

  Rect get hitbox {
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: 30,
      height: 30,
    );
  }
}
