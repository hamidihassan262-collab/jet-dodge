import 'dart:ui';

enum PowerUpType {
  shield,
  doubleTime,
  doublePoints,
  erasure,
  speed,
  magneticField,
  ghostMode,
  emp,
  timeWarp,
  miniaturize,
}

class PowerUpConfig {
  final PowerUpType type;
  final String name;
  final String description;
  final double duration;
  final Color color;
  final String icon;
  final double spawnWeight;

  const PowerUpConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.duration,
    required this.color,
    required this.icon,
    this.spawnWeight = 1.0,
  });

  static const List<PowerUpConfig> allPowerUps = [
    PowerUpConfig(
      type: PowerUpType.shield,
      name: 'Shield',
      description: 'Temporary invincibility for 5 seconds',
      duration: 5.0,
      color: Color(0xFF42A5F5),
      icon: 'shield',
      spawnWeight: 0.8,
    ),
    PowerUpConfig(
      type: PowerUpType.doubleTime,
      name: 'Double Time',
      description: 'Time runs 2x faster for 15 seconds',
      duration: 15.0,
      color: Color(0xFFFFEB3B),
      icon: 'fast_forward',
      spawnWeight: 0.7,
    ),
    PowerUpConfig(
      type: PowerUpType.doublePoints,
      name: 'Double Points',
      description: 'Score multiplied by 2 for 15 seconds',
      duration: 15.0,
      color: Color(0xFFFF9800),
      icon: 'stars',
      spawnWeight: 0.9,
    ),
    PowerUpConfig(
      type: PowerUpType.erasure,
      name: 'Erasure',
      description: 'Destroys all missiles on screen',
      duration: 0.0,
      color: Color(0xFFE91E63),
      icon: 'delete_sweep',
      spawnWeight: 0.5,
    ),
    PowerUpConfig(
      type: PowerUpType.speed,
      name: 'Speed Boost',
      description: '1.5x jet speed for 10 seconds',
      duration: 10.0,
      color: Color(0xFF00E676),
      icon: 'bolt',
      spawnWeight: 0.85,
    ),
    PowerUpConfig(
      type: PowerUpType.magneticField,
      name: 'Magnetic Field',
      description: 'Deflects nearby missiles for 8 seconds',
      duration: 8.0,
      color: Color(0xFF7C4DFF),
      icon: 'radar',
      spawnWeight: 0.4,
    ),
    PowerUpConfig(
      type: PowerUpType.ghostMode,
      name: 'Ghost Mode',
      description: 'Phase through missiles for 4 seconds',
      duration: 4.0,
      color: Color(0x99FFFFFF),
      icon: 'visibility_off',
      spawnWeight: 0.35,
    ),
    PowerUpConfig(
      type: PowerUpType.emp,
      name: 'EMP Blast',
      description: 'Slows all missiles by 50% for 10 seconds',
      duration: 10.0,
      color: Color(0xFF00BCD4),
      icon: 'flash_on',
      spawnWeight: 0.6,
    ),
    PowerUpConfig(
      type: PowerUpType.timeWarp,
      name: 'Time Warp',
      description: 'Everything slows except you for 6 seconds',
      duration: 6.0,
      color: Color(0xFFAA00FF),
      icon: 'hourglass_empty',
      spawnWeight: 0.3,
    ),
    PowerUpConfig(
      type: PowerUpType.miniaturize,
      name: 'Miniaturize',
      description: 'Shrink to half size for 8 seconds',
      duration: 8.0,
      color: Color(0xFF76FF03),
      icon: 'compress',
      spawnWeight: 0.55,
    ),
  ];

  static PowerUpConfig getConfig(PowerUpType type) {
    return allPowerUps.firstWhere((p) => p.type == type);
  }
}
