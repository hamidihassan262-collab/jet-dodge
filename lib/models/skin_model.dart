import 'dart:ui';

enum SkinRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
  iridescent,
}

extension SkinRarityExtension on SkinRarity {
  String get displayName {
    switch (this) {
      case SkinRarity.common:
        return 'Common';
      case SkinRarity.uncommon:
        return 'Uncommon';
      case SkinRarity.rare:
        return 'Rare';
      case SkinRarity.epic:
        return 'Epic';
      case SkinRarity.legendary:
        return 'Legendary';
      case SkinRarity.mythic:
        return 'Mythic';
      case SkinRarity.iridescent:
        return 'Iridescent';
    }
  }

  Color get color {
    switch (this) {
      case SkinRarity.common:
        return const Color(0xFF9E9E9E);
      case SkinRarity.uncommon:
        return const Color(0xFF4CAF50);
      case SkinRarity.rare:
        return const Color(0xFF2196F3);
      case SkinRarity.epic:
        return const Color(0xFF9C27B0);
      case SkinRarity.legendary:
        return const Color(0xFFFF9800);
      case SkinRarity.mythic:
        return const Color(0xFFE91E63);
      case SkinRarity.iridescent:
        return const Color(0xFF00BCD4);
    }
  }

  bool get hasParticleEffects {
    return index >= SkinRarity.legendary.index;
  }

  int get sortOrder => index;
}

class JetSkin {
  final String id;
  final String name;
  final SkinRarity rarity;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color trailColor;
  final double trailIntensity;
  final bool hasFlameTrail;
  final bool hasEnergyAura;
  final bool hasParticleWings;
  final bool hasRainbowShift;
  final String description;

  const JetSkin({
    required this.id,
    required this.name,
    required this.rarity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.trailColor,
    this.trailIntensity = 1.0,
    this.hasFlameTrail = false,
    this.hasEnergyAura = false,
    this.hasParticleWings = false,
    this.hasRainbowShift = false,
    this.description = '',
  });
}

class SkinCatalog {
  static const List<JetSkin> allSkins = [
    // Common (3)
    JetSkin(
      id: 'ghost',
      name: 'Ghost',
      rarity: SkinRarity.common,
      primaryColor: Color(0xFFBDBDBD),
      secondaryColor: Color(0xFF9E9E9E),
      accentColor: Color(0xFFE0E0E0),
      trailColor: Color(0x80FFFFFF),
      description: 'Standard issue stealth fighter',
    ),
    JetSkin(
      id: 'shadow',
      name: 'Shadow',
      rarity: SkinRarity.common,
      primaryColor: Color(0xFF424242),
      secondaryColor: Color(0xFF212121),
      accentColor: Color(0xFF616161),
      trailColor: Color(0x80000000),
      description: 'Dark ops night fighter',
    ),
    JetSkin(
      id: 'steel',
      name: 'Steel Wing',
      rarity: SkinRarity.common,
      primaryColor: Color(0xFF78909C),
      secondaryColor: Color(0xFF546E7A),
      accentColor: Color(0xFF90A4AE),
      trailColor: Color(0x8090A4AE),
      description: 'Reinforced steel alloy frame',
    ),
    // Uncommon (2)
    JetSkin(
      id: 'viper',
      name: 'Viper',
      rarity: SkinRarity.uncommon,
      primaryColor: Color(0xFF388E3C),
      secondaryColor: Color(0xFF1B5E20),
      accentColor: Color(0xFF66BB6A),
      trailColor: Color(0x8066BB6A),
      description: 'Venomous green tactical fighter',
    ),
    JetSkin(
      id: 'desert_hawk',
      name: 'Desert Hawk',
      rarity: SkinRarity.uncommon,
      primaryColor: Color(0xFFD4A056),
      secondaryColor: Color(0xFFB07B2E),
      accentColor: Color(0xFFE8C97A),
      trailColor: Color(0x80E8C97A),
      description: 'Sand-swept desert patrol craft',
    ),
    // Rare (2)
    JetSkin(
      id: 'frostbite',
      name: 'Frostbite',
      rarity: SkinRarity.rare,
      primaryColor: Color(0xFF42A5F5),
      secondaryColor: Color(0xFF1565C0),
      accentColor: Color(0xFF90CAF9),
      trailColor: Color(0x8090CAF9),
      description: 'Ice-cold precision interceptor',
    ),
    JetSkin(
      id: 'crimson',
      name: 'Crimson Blade',
      rarity: SkinRarity.rare,
      primaryColor: Color(0xFFE53935),
      secondaryColor: Color(0xFFB71C1C),
      accentColor: Color(0xFFEF9A9A),
      trailColor: Color(0x80EF5350),
      description: 'Blood-red combat elite',
    ),
    // Epic (1)
    JetSkin(
      id: 'phantom',
      name: 'Phantom',
      rarity: SkinRarity.epic,
      primaryColor: Color(0xFF7B1FA2),
      secondaryColor: Color(0xFF4A148C),
      accentColor: Color(0xFFCE93D8),
      trailColor: Color(0x80CE93D8),
      description: 'Phase-shifting stealth prototype',
    ),
    // Legendary (1)
    JetSkin(
      id: 'solar_flare',
      name: 'Solar Flare',
      rarity: SkinRarity.legendary,
      primaryColor: Color(0xFFFF8F00),
      secondaryColor: Color(0xFFE65100),
      accentColor: Color(0xFFFFCC02),
      trailColor: Color(0xCCFFAB00),
      trailIntensity: 1.5,
      hasFlameTrail: true,
      description: 'Burns with the fury of a star',
    ),
    // Mythic (1)
    JetSkin(
      id: 'nebula',
      name: 'Nebula',
      rarity: SkinRarity.mythic,
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFF880E4F),
      accentColor: Color(0xFFF48FB1),
      trailColor: Color(0xCCF06292),
      trailIntensity: 2.0,
      hasFlameTrail: true,
      hasEnergyAura: true,
      description: 'Born from cosmic dust and starlight',
    ),
    // Iridescent (2)
    JetSkin(
      id: 'aurora',
      name: 'Aurora',
      rarity: SkinRarity.iridescent,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF00B8D4),
      accentColor: Color(0xFF84FFFF),
      trailColor: Color(0xCC18FFFF),
      trailIntensity: 2.5,
      hasFlameTrail: true,
      hasEnergyAura: true,
      hasParticleWings: true,
      hasRainbowShift: true,
      description: 'Channels the northern lights itself',
    ),
    JetSkin(
      id: 'void_walker',
      name: 'Void Walker',
      rarity: SkinRarity.iridescent,
      primaryColor: Color(0xFF1A0033),
      secondaryColor: Color(0xFF000000),
      accentColor: Color(0xFFBB86FC),
      trailColor: Color(0xCCBB86FC),
      trailIntensity: 2.5,
      hasFlameTrail: true,
      hasEnergyAura: true,
      hasParticleWings: true,
      hasRainbowShift: true,
      description: 'Tears through the fabric of spacetime',
    ),
  ];

  static JetSkin getSkinById(String id) {
    return allSkins.firstWhere((s) => s.id == id, orElse: () => allSkins[0]);
  }
}
