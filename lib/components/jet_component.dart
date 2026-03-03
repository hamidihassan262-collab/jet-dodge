import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/skin_model.dart';
import '../game/jet_dodge_game.dart';

class JetComponent extends PositionComponent with HasGameReference<JetDodgeGame> {
  JetSkin skin;
  Vector2 targetPosition;
  double baseSpeed = 350.0;
  double currentSpeedMultiplier = 1.0;
  double currentSizeMultiplier = 1.0;
  bool isShielded = false;
  bool isGhostMode = false;
  double _animTimer = 0;
  double _auraTimer = 0;
  double _rainbowHue = 0;
  final List<_TrailParticle> _trailParticles = [];
  final List<_WingParticle> _wingParticles = [];
  final Random _random = Random();

  JetComponent({required this.skin})
      : targetPosition = Vector2.zero(),
        super(size: Vector2(32, 40), anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    position = game.size / 2;
    targetPosition = position.clone();
  }

  void updateSkin(JetSkin newSkin) {
    skin = newSkin;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    _auraTimer += dt;
    
    if (skin.hasRainbowShift) {
      _rainbowHue = (_rainbowHue + dt * 60) % 360;
    }

    // Move toward target
    final diff = targetPosition - position;
    final dist = diff.length;
    if (dist > 2) {
      final speed = baseSpeed * currentSpeedMultiplier;
      final moveAmount = min(speed * dt, dist);
      position += diff.normalized() * moveAmount;
      
      // Rotate toward movement direction
      angle = atan2(diff.x, -diff.y);
    }

    // Clamp to screen
    final halfW = (size.x * currentSizeMultiplier) / 2;
    final halfH = (size.y * currentSizeMultiplier) / 2;
    position.x = position.x.clamp(halfW, game.size.x - halfW);
    position.y = position.y.clamp(halfH, game.size.y - halfH);

    // Update trail particles
    if (_animTimer > 0.03) {
      _animTimer = 0;
      _trailParticles.add(_TrailParticle(
        position: position.clone(),
        life: skin.trailIntensity * 0.5,
        maxLife: skin.trailIntensity * 0.5,
        color: skin.trailColor,
        size: 3.0 + _random.nextDouble() * 3.0,
      ));
    }
    _trailParticles.removeWhere((p) {
      p.life -= dt;
      return p.life <= 0;
    });

    // Wing particles for legendary+
    if (skin.hasParticleWings && _random.nextDouble() < 0.3) {
      final wingOffset = Vector2(
        (_random.nextDouble() - 0.5) * 20,
        _random.nextDouble() * 10 + 5,
      );
      _wingParticles.add(_WingParticle(
        position: position + wingOffset,
        velocity: Vector2((_random.nextDouble() - 0.5) * 30, _random.nextDouble() * 20 + 10),
        life: 0.8,
        maxLife: 0.8,
        color: skin.accentColor,
        size: 2.0 + _random.nextDouble() * 3.0,
      ));
    }
    _wingParticles.removeWhere((p) {
      p.life -= dt;
      p.position += p.velocity * dt;
      return p.life <= 0;
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    final scale = currentSizeMultiplier;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scale);
    canvas.translate(-centerX, -centerY);

    // Draw trail particles (in world space, so transform back)
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(-angle);
    canvas.translate(-position.x, -position.y);
    
    for (final p in _trailParticles) {
      final alpha = (p.life / p.maxLife * 255).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size * (p.life / p.maxLife), paint);
    }

    for (final p in _wingParticles) {
      final alpha = (p.life / p.maxLife * 255).toInt().clamp(0, 255);
      final paint = Paint()
        ..color = p.color.withAlpha(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size * (p.life / p.maxLife), paint);
    }
    canvas.restore();

    // Energy aura for mythic+
    if (skin.hasEnergyAura) {
      final auraPaint = Paint()
        ..color = skin.accentColor.withAlpha((80 + sin(_auraTimer * 3) * 40).toInt().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(centerX, centerY), 25 + sin(_auraTimer * 2) * 3, auraPaint);
    }

    // Shield indicator
    if (isShielded) {
      final shieldPaint = Paint()
        ..color = const Color(0xFF42A5F5).withAlpha((150 + sin(_auraTimer * 5) * 50).toInt().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset(centerX, centerY), 28, shieldPaint);
    }

    // Ghost mode indicator
    if (isGhostMode) {
      canvas.saveLayer(Rect.fromCenter(center: Offset(centerX, centerY), width: 60, height: 60), Paint()..color = const Color(0x88FFFFFF));
    }

    Color primary = skin.primaryColor;
    Color secondary = skin.secondaryColor;
    Color accent = skin.accentColor;

    if (skin.hasRainbowShift) {
      primary = HSVColor.fromAHSV(1, _rainbowHue, 0.8, 0.9).toColor();
      secondary = HSVColor.fromAHSV(1, (_rainbowHue + 30) % 360, 0.8, 0.7).toColor();
      accent = HSVColor.fromAHSV(1, (_rainbowHue + 60) % 360, 0.6, 1.0).toColor();
    }

    // Draw jet body
    final bodyPaint = Paint()..color = primary;
    final bodyPath = Path()
      ..moveTo(centerX, 2)
      ..lineTo(centerX + 8, centerY + 5)
      ..lineTo(centerX + 5, size.y - 4)
      ..lineTo(centerX, size.y - 8)
      ..lineTo(centerX - 5, size.y - 4)
      ..lineTo(centerX - 8, centerY + 5)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Wings
    final wingPaint = Paint()..color = secondary;
    final leftWing = Path()
      ..moveTo(centerX - 5, centerY + 2)
      ..lineTo(centerX - 16, centerY + 12)
      ..lineTo(centerX - 14, centerY + 14)
      ..lineTo(centerX - 4, centerY + 10)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(centerX + 5, centerY + 2)
      ..lineTo(centerX + 16, centerY + 12)
      ..lineTo(centerX + 14, centerY + 14)
      ..lineTo(centerX + 4, centerY + 10)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // Cockpit
    final cockpitPaint = Paint()..color = accent;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY - 2), width: 6, height: 10),
      cockpitPaint,
    );

    // Engine glow
    if (skin.hasFlameTrail) {
      final flamePaint = Paint()
        ..color = skin.trailColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final flameSize = 4 + sin(_animTimer * 15) * 2;
      canvas.drawCircle(Offset(centerX - 3, size.y - 2), flameSize, flamePaint);
      canvas.drawCircle(Offset(centerX + 3, size.y - 2), flameSize, flamePaint);
    } else {
      final enginePaint = Paint()
        ..color = const Color(0xFFFF6D00)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final engineSize = 2 + sin(_animTimer * 10) * 1;
      canvas.drawCircle(Offset(centerX - 3, size.y - 2), engineSize, enginePaint);
      canvas.drawCircle(Offset(centerX + 3, size.y - 2), engineSize, enginePaint);
    }

    if (isGhostMode) {
      canvas.restore();
    }

    canvas.restore();
  }

  Rect get hitbox {
    final s = currentSizeMultiplier;
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x * s * 0.5,
      height: size.y * s * 0.5,
    );
  }
}

class _TrailParticle {
  Vector2 position;
  double life;
  double maxLife;
  Color color;
  double size;

  _TrailParticle({
    required this.position,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
  });
}

class _WingParticle {
  Vector2 position;
  Vector2 velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  _WingParticle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
  });
}
