import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/jet_component.dart';
import '../components/missile_component.dart';
import '../components/powerup_component.dart';
import '../components/explosion_component.dart';
import '../models/skin_model.dart';
import '../models/powerup_model.dart';
import '../utils/game_data.dart';
import '../utils/audio_manager.dart';

enum GameState { playing, paused, gameOver }

class JetDodgeGame extends FlameGame with PanDetector, TapDetector, HasCollisionDetection {
  late JetComponent jet;
  final List<MissileComponent> missiles = [];
  final List<PowerUpComponent> powerups = [];
  final Random _random = Random();

  GameState gameState = GameState.playing;
  double survivalTime = 0;
  double _score = 0;
  int displayScore = 0;
  double _missileSpawnTimer = 0;
  double _powerupSpawnTimer = 0;
  double _difficultyTimer = 0;
  int _missileLevel = 1;
  double _missileSpawnInterval = 2.0;
  double _missileBaseSpeed = 120;
  double _missileHomingStrength = 2.0;

  final Map<PowerUpType, double> activePowerUps = {};
  double _scoreMultiplier = 1.0;
  double _timeMultiplier = 1.0;
  bool _isShielded = false;
  bool _isGhostMode = false;

  int _missilesDodged = 0;
  int _closeCalls = 0;
  int _powerupsCollected = 0;
  bool _usedPowerup = false;

  double _edgeRedIntensity = 0;

  final List<_CloudParticle> _clouds = [];
  double _radarSweepAngle = 0;

  Vector2? cursorPosition;

  VoidCallback? onGameOver;
  Function(String)? onAchievementUnlocked;

  final double _magneticFieldRadius = 80;

  JetDodgeGame();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initGame();
  }

  void _initGame() {
    final skin = SkinCatalog.getSkinById(GameData.selectedSkinId);
    jet = JetComponent(skin: skin);
    add(jet);

    for (int i = 0; i < 15; i++) {
      _clouds.add(_CloudParticle(
        position: Vector2(_random.nextDouble() * size.x, _random.nextDouble() * size.y),
        size: 30 + _random.nextDouble() * 80,
        speed: 5 + _random.nextDouble() * 15,
        alpha: 0.05 + _random.nextDouble() * 0.15,
      ));
    }
  }

  void resetGame() {
    for (final m in List.from(missiles)) {
      m.removeFromParent();
    }
    missiles.clear();
    for (final p in List.from(powerups)) {
      p.removeFromParent();
    }
    powerups.clear();
    jet.removeFromParent();

    gameState = GameState.playing;
    survivalTime = 0;
    _score = 0;
    displayScore = 0;
    _missileSpawnTimer = 0;
    _powerupSpawnTimer = 0;
    _difficultyTimer = 0;
    _missileLevel = 1;
    _missileSpawnInterval = 2.0;
    _missileBaseSpeed = 120;
    _missileHomingStrength = 2.0;
    activePowerUps.clear();
    _scoreMultiplier = 1.0;
    _timeMultiplier = 1.0;
    _isShielded = false;
    _isGhostMode = false;
    _missilesDodged = 0;
    _closeCalls = 0;
    _powerupsCollected = 0;
    _usedPowerup = false;
    _edgeRedIntensity = 0;

    _initGame();
  }

  @override
  void update(double dt) {
    if (gameState != GameState.playing) return;
    super.update(dt);

    final effectiveDt = dt * _timeMultiplier;
    survivalTime += effectiveDt;

    final basePointsPerSecond = 10.0;
    final timeBonus = 1.0 + (survivalTime / 60.0) * 0.5;
    final totalMult = _scoreMultiplier * GameData.totalMultiplier * timeBonus;
    _score += basePointsPerSecond * effectiveDt * totalMult;
    displayScore = _score.floor();

    _edgeRedIntensity = (survivalTime / 300.0).clamp(0.0, 1.0);
    _radarSweepAngle = (_radarSweepAngle + dt * 2) % (2 * pi);

    for (final cloud in _clouds) {
      cloud.position.y += cloud.speed * dt;
      if (cloud.position.y > size.y + cloud.size) {
        cloud.position.y = -cloud.size;
        cloud.position.x = _random.nextDouble() * size.x;
      }
    }

    _difficultyTimer += effectiveDt;
    if (_difficultyTimer > 30) {
      _difficultyTimer = 0;
      _missileLevel = (_missileLevel + 1).clamp(1, 5);
      _missileSpawnInterval = (_missileSpawnInterval * 0.85).clamp(0.3, 2.0);
      _missileBaseSpeed = (_missileBaseSpeed + 15).clamp(120, 350);
      _missileHomingStrength = (_missileHomingStrength + 0.3).clamp(2.0, 6.0);
    }

    _missileSpawnTimer += effectiveDt;
    if (_missileSpawnTimer >= _missileSpawnInterval) {
      _missileSpawnTimer = 0;
      _spawnMissile();
    }

    _powerupSpawnTimer += effectiveDt;
    if (_powerupSpawnTimer >= 8.0) {
      _powerupSpawnTimer = 0;
      if (_random.nextDouble() < 0.7) {
        _spawnPowerUp();
      }
    }

    final expiredPowerUps = <PowerUpType>[];
    activePowerUps.forEach((type, remaining) {
      activePowerUps[type] = remaining - dt;
      if (activePowerUps[type]! <= 0) {
        expiredPowerUps.add(type);
      }
    });
    for (final type in expiredPowerUps) {
      _deactivatePowerUp(type);
      activePowerUps.remove(type);
    }

    final jetHitbox = jet.hitbox;
    for (final missile in List.from(missiles)) {
      if (missile.isExpired) {
        missiles.remove(missile);
        _missilesDodged++;
        continue;
      }

      if (activePowerUps.containsKey(PowerUpType.magneticField)) {
        final dist = (missile.position - jet.position).length;
        if (dist < _magneticFieldRadius) {
          final pushDir = (missile.position - jet.position).normalized();
          missile.position += pushDir * 200 * dt;
        }
      }

      final dist = (missile.position - jet.position).length;
      if (dist < 25.0 && dist > 15) {
        _closeCalls++;
        AudioManager.playCloseCall();
      }

      if (jetHitbox.overlaps(missile.hitbox)) {
        if (_isShielded) {
          missile.removeFromParent();
          missiles.remove(missile);
          AudioManager.playShieldHit();
          add(ExplosionComponent(pos: missile.position.clone()));
        } else if (_isGhostMode) {
          // Phase through
        } else {
          _handleDeath();
          return;
        }
      }
    }

    for (final powerup in List.from(powerups)) {
      if (powerup.isExpired || powerup.isCollected) {
        powerups.remove(powerup);
        continue;
      }
      if (jetHitbox.overlaps(powerup.hitbox)) {
        _collectPowerUp(powerup);
      }
    }
  }

  void _spawnMissile() {
    Vector2 spawnPos;
    final side = _random.nextInt(4);
    switch (side) {
      case 0:
        spawnPos = Vector2(_random.nextDouble() * size.x, -20);
        break;
      case 1:
        spawnPos = Vector2(_random.nextDouble() * size.x, size.y + 20);
        break;
      case 2:
        spawnPos = Vector2(-20, _random.nextDouble() * size.y);
        break;
      default:
        spawnPos = Vector2(size.x + 20, _random.nextDouble() * size.y);
        break;
    }

    final missile = MissileComponent(
      startPosition: spawnPos,
      level: _missileLevel,
      speed: _missileBaseSpeed + _random.nextDouble() * 30,
      homingStrength: _missileHomingStrength,
    );

    if (activePowerUps.containsKey(PowerUpType.emp)) {
      missile.applySlow(0.5);
    }
    if (activePowerUps.containsKey(PowerUpType.timeWarp)) {
      missile.applySlow(0.3);
    }

    missiles.add(missile);
    add(missile);
    AudioManager.playMissileLaunch();
  }

  void _spawnPowerUp() {
    final totalWeight = PowerUpConfig.allPowerUps.fold<double>(0, (sum, p) => sum + p.spawnWeight);
    var roll = _random.nextDouble() * totalWeight;
    PowerUpType selectedType = PowerUpType.shield;
    for (final config in PowerUpConfig.allPowerUps) {
      roll -= config.spawnWeight;
      if (roll <= 0) {
        selectedType = config.type;
        break;
      }
    }

    final margin = 50.0;
    final spawnPos = Vector2(
      margin + _random.nextDouble() * (size.x - margin * 2),
      margin + _random.nextDouble() * (size.y - margin * 2),
    );

    final powerup = PowerUpComponent(type: selectedType, spawnPosition: spawnPos);
    powerups.add(powerup);
    add(powerup);
  }

  void _collectPowerUp(PowerUpComponent powerup) {
    powerup.collect();
    powerup.removeFromParent();
    powerups.remove(powerup);
    _powerupsCollected++;
    _usedPowerup = true;
    AudioManager.playPowerup();

    GameData.addPowerupType(powerup.type.name);
    final config = PowerUpConfig.getConfig(powerup.type);

    switch (powerup.type) {
      case PowerUpType.erasure:
        for (final m in List.from(missiles)) {
          add(ExplosionComponent(pos: m.position.clone()));
          m.removeFromParent();
        }
        missiles.clear();
        GameData.totalErasuresUsed = GameData.totalErasuresUsed + 1;
        break;
      default:
        activePowerUps[powerup.type] = config.duration;
        _activatePowerUp(powerup.type);
        break;
    }
  }

  void _activatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        _isShielded = true;
        jet.isShielded = true;
        break;
      case PowerUpType.doubleTime:
        _timeMultiplier = 2.0;
        break;
      case PowerUpType.doublePoints:
        _scoreMultiplier = 2.0;
        break;
      case PowerUpType.speed:
        jet.currentSpeedMultiplier = 1.5;
        break;
      case PowerUpType.ghostMode:
        _isGhostMode = true;
        jet.isGhostMode = true;
        break;
      case PowerUpType.emp:
        for (final m in missiles) {
          m.applySlow(0.5);
        }
        break;
      case PowerUpType.timeWarp:
        for (final m in missiles) {
          m.applySlow(0.3);
        }
        break;
      case PowerUpType.miniaturize:
        jet.currentSizeMultiplier = 0.5;
        break;
      case PowerUpType.magneticField:
        break;
      case PowerUpType.erasure:
        break;
    }
  }

  void _deactivatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        _isShielded = false;
        jet.isShielded = false;
        break;
      case PowerUpType.doubleTime:
        _timeMultiplier = 1.0;
        break;
      case PowerUpType.doublePoints:
        _scoreMultiplier = 1.0;
        break;
      case PowerUpType.speed:
        jet.currentSpeedMultiplier = 1.0;
        break;
      case PowerUpType.ghostMode:
        _isGhostMode = false;
        jet.isGhostMode = false;
        break;
      case PowerUpType.emp:
        for (final m in missiles) {
          m.removeSlow();
        }
        break;
      case PowerUpType.timeWarp:
        for (final m in missiles) {
          m.removeSlow();
        }
        break;
      case PowerUpType.miniaturize:
        jet.currentSizeMultiplier = 1.0;
        break;
      case PowerUpType.magneticField:
        break;
      case PowerUpType.erasure:
        break;
    }
  }

  void _handleDeath() {
    gameState = GameState.gameOver;
    AudioManager.playExplosion();
    add(ExplosionComponent(pos: jet.position.clone()));

    final finalScore = displayScore;
    GameData.totalGamesPlayed = GameData.totalGamesPlayed + 1;
    GameData.totalPoints = GameData.totalPoints + finalScore;
    GameData.totalTimePlayed = GameData.totalTimePlayed + survivalTime;
    GameData.totalPowerupsCollected = GameData.totalPowerupsCollected + _powerupsCollected;
    GameData.totalMissilesDodged = GameData.totalMissilesDodged + _missilesDodged;
    GameData.totalCloseCalls = GameData.totalCloseCalls + _closeCalls;

    if (finalScore > GameData.highScore) {
      GameData.highScore = finalScore;
    }
    if (survivalTime > GameData.longestSurvival) {
      GameData.longestSurvival = survivalTime;
    }

    GameData.addLeaderboardEntry({
      'score': finalScore,
      'time': survivalTime,
      'date': DateTime.now().toIso8601String(),
    });

    GameData.updateDailyStreak();
    _checkAchievements();
    onGameOver?.call();
  }

  void _checkAchievements() {
    final checks = <String, bool>{
      'survive_30s': survivalTime >= 30,
      'survive_60s': survivalTime >= 60,
      'survive_120s': survivalTime >= 120,
      'survive_180s': survivalTime >= 180,
      'survive_300s': survivalTime >= 300,
      'survive_600s': survivalTime >= 600,
      'points_500': displayScore >= 500,
      'points_2000': displayScore >= 2000,
      'points_5000': displayScore >= 5000,
      'points_10000': displayScore >= 10000,
      'points_25000': displayScore >= 25000,
      'total_points_100k': GameData.totalPoints >= 100000,
      'powerups_10': GameData.totalPowerupsCollected >= 10,
      'powerups_50': GameData.totalPowerupsCollected >= 50,
      'powerups_200': GameData.totalPowerupsCollected >= 200,
      'all_powerups': GameData.powerupTypesCollected.length >= 10,
      'erasure_20': GameData.totalErasuresUsed >= 20,
      'games_5': GameData.totalGamesPlayed >= 5,
      'games_25': GameData.totalGamesPlayed >= 25,
      'games_50': GameData.totalGamesPlayed >= 50,
      'games_100': GameData.totalGamesPlayed >= 100,
      'games_500': GameData.totalGamesPlayed >= 500,
      'games_1000': GameData.totalGamesPlayed >= 1000,
      'close_call_10': GameData.totalCloseCalls >= 10,
      'close_call_50': GameData.totalCloseCalls >= 50,
      'no_powerup_60s': !_usedPowerup && survivalTime >= 60,
      'dodge_100': _missilesDodged >= 100,
      'daily_streak_7': GameData.dailyStreak >= 7,
      'daily_streak_30': GameData.dailyStreak >= 30,
    };

    final unlocked = GameData.unlockedAchievements;
    checks.forEach((id, condition) {
      if (condition && !unlocked.contains(id)) {
        GameData.unlockAchievement(id);
        AudioManager.playAchievement();
        onAchievementUnlocked?.call(id);
      }
    });
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (gameState != GameState.playing) return;
    cursorPosition = info.eventPosition.global;
    jet.targetPosition = info.eventPosition.global;
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (gameState != GameState.playing) return;
    cursorPosition = info.eventPosition.global;
    jet.targetPosition = info.eventPosition.global;
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (gameState != GameState.playing) return;
    cursorPosition = info.eventPosition.global;
    jet.targetPosition = info.eventPosition.global;
  }

  @override
  void render(Canvas canvas) {
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E), Color(0xFF16213E)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    for (final cloud in _clouds) {
      final cloudPaint = Paint()
        ..color = Colors.white.withAlpha((cloud.alpha * 255).toInt().clamp(0, 255))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cloud.size * 0.5);
      canvas.drawCircle(
        Offset(cloud.position.x, cloud.position.y),
        cloud.size * 0.4,
        cloudPaint,
      );
    }

    _drawRadar(canvas);
    super.render(canvas);

    if (_edgeRedIntensity > 0) {
      _drawEdgeRed(canvas);
    }

    _drawActivePowerUps(canvas);

    if (cursorPosition != null && gameState == GameState.playing) {
      _drawCursor(canvas, cursorPosition!);
    }

    _drawHUD(canvas);
  }

  void _drawRadar(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    final radarRadius = min(size.x, size.y) * 0.4;

    for (int i = 1; i <= 4; i++) {
      final r = radarRadius * (i / 4);
      final paint = Paint()
        ..color = const Color(0x1500FF88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    final linePaint = Paint()
      ..color = const Color(0x0D00FF88)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(cx - radarRadius, cy), Offset(cx + radarRadius, cy), linePaint);
    canvas.drawLine(Offset(cx, cy - radarRadius), Offset(cx, cy + radarRadius), linePaint);

    final sweepEnd = Offset(
      cx + cos(_radarSweepAngle) * radarRadius,
      cy + sin(_radarSweepAngle) * radarRadius,
    );
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [const Color(0x3300FF88), const Color(0x0000FF88)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radarRadius))
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, cy), sweepEnd, sweepPaint);

    final sweepArc = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: _radarSweepAngle - 0.5,
        endAngle: _radarSweepAngle,
        colors: [const Color(0x0000FF88), const Color(0x2000FF88)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radarRadius))
      ..style = PaintingStyle.fill;
    final arcPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radarRadius),
        _radarSweepAngle - 0.5,
        0.5,
        false,
      )
      ..close();
    canvas.drawPath(arcPath, sweepArc);

    for (final missile in missiles) {
      final relX = (missile.position.x - cx) / size.x * radarRadius * 2;
      final relY = (missile.position.y - cy) / size.y * radarRadius * 2;
      if (relX.abs() < radarRadius && relY.abs() < radarRadius) {
        final blipPaint = Paint()
          ..color = const Color(0xAAFF0000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(Offset(cx + relX, cy + relY), 2, blipPaint);
      }
    }
  }

  void _drawEdgeRed(Canvas canvas) {
    final intensity = _edgeRedIntensity;
    final edgeWidth = 40.0 + intensity * 60.0;
    final alpha = (intensity * 120).toInt().clamp(0, 255);

    final topGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.fromARGB(alpha, 255, 0, 0), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.x, edgeWidth));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, edgeWidth), topGrad);

    final bottomGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color.fromARGB(alpha, 255, 0, 0), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, size.y - edgeWidth, size.x, edgeWidth));
    canvas.drawRect(Rect.fromLTWH(0, size.y - edgeWidth, size.x, edgeWidth), bottomGrad);

    final leftGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color.fromARGB(alpha, 255, 0, 0), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, edgeWidth, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, edgeWidth, size.y), leftGrad);

    final rightGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [Color.fromARGB(alpha, 255, 0, 0), Colors.transparent],
      ).createShader(Rect.fromLTWH(size.x - edgeWidth, 0, edgeWidth, size.y));
    canvas.drawRect(Rect.fromLTWH(size.x - edgeWidth, 0, edgeWidth, size.y), rightGrad);
  }

  void _drawCursor(Canvas canvas, Vector2 pos) {
    final cursorPaint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(pos.x, pos.y), 15, cursorPaint);

    final dotPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.x, pos.y), 2, dotPaint);
  }

  void _drawActivePowerUps(Canvas canvas) {
    double yOffset = size.y - 120;
    activePowerUps.forEach((type, remaining) {
      final config = PowerUpConfig.getConfig(type);
      final barWidth = 120.0;
      final progress = config.duration > 0 ? (remaining / config.duration).clamp(0.0, 1.0) : 0.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(10, yOffset, barWidth, 16), const Radius.circular(8)),
        Paint()..color = Colors.black.withAlpha(120),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(10, yOffset, barWidth * progress, 16), const Radius.circular(8)),
        Paint()..color = config.color.withAlpha(180),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: config.name,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(14, yOffset + 2));

      yOffset -= 22;
    });
  }

  void _drawHUD(Canvas canvas) {
    final scoreTp = TextPainter(
      text: TextSpan(
        text: '$displayScore',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [Shadow(color: Color(0x80000000), blurRadius: 4, offset: Offset(1, 1))],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scoreTp.paint(canvas, Offset(size.x / 2 - scoreTp.width / 2, 50));

    final minutes = (survivalTime / 60).floor();
    final seconds = (survivalTime % 60).floor();
    final timeTp = TextPainter(
      text: TextSpan(
        text: '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Color(0xCC00FF88),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    timeTp.paint(canvas, Offset(size.x / 2 - timeTp.width / 2, 82));

    if (GameData.totalMultiplier > 1.0) {
      final multTp = TextPainter(
        text: TextSpan(
          text: 'x${GameData.totalMultiplier.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xCCFFD700),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      multTp.paint(canvas, Offset(size.x / 2 - multTp.width / 2, 100));
    }

    final levelTp = TextPainter(
      text: TextSpan(
        text: 'THREAT LVL $_missileLevel',
        style: TextStyle(
          color: Color.lerp(const Color(0xCC00FF88), const Color(0xCCFF0000), (_missileLevel - 1) / 4)!,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    levelTp.paint(canvas, Offset(size.x - levelTp.width - 15, 50));
  }
}

class _CloudParticle {
  Vector2 position;
  double size;
  double speed;
  double alpha;

  _CloudParticle({
    required this.position,
    required this.size,
    required this.speed,
    required this.alpha,
  });
}
