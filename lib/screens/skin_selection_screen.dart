import 'dart:math';
import 'package:flutter/material.dart';
import '../models/skin_model.dart';
import '../utils/game_data.dart';

class SkinSelectionScreen extends StatefulWidget {
  const SkinSelectionScreen({super.key});

  @override
  State<SkinSelectionScreen> createState() => _SkinSelectionScreenState();
}

class _SkinSelectionScreenState extends State<SkinSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedSkinId = GameData.selectedSkinId;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SELECT SKIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Skin preview
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final skin = SkinCatalog.getSkinById(_selectedSkinId);
                  return Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: skin.rarity.color.withAlpha(80), width: 1),
                      color: Colors.black.withAlpha(40),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(120, 160),
                        painter: _SkinPreviewPainter(
                          skin: skin,
                          animValue: _animController.value,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Selected skin info
              Builder(builder: (context) {
                final skin = SkinCatalog.getSkinById(_selectedSkinId);
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        skin.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: skin.rarity.color.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: skin.rarity.color.withAlpha(100)),
                        ),
                        child: Text(
                          skin.rarity.displayName.toUpperCase(),
                          style: TextStyle(
                            color: skin.rarity.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skin.description,
                        style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
                      ),
                      if (skin.rarity.hasParticleEffects) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (skin.hasFlameTrail) _effectBadge('FLAME TRAIL', const Color(0xFFFF6D00)),
                            if (skin.hasEnergyAura) _effectBadge('ENERGY AURA', const Color(0xFFBB86FC)),
                            if (skin.hasParticleWings) _effectBadge('PARTICLE WINGS', const Color(0xFF00E5FF)),
                            if (skin.hasRainbowShift) _effectBadge('RAINBOW SHIFT', const Color(0xFFFF4081)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),

              // Skin grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: SkinCatalog.allSkins.length,
                  itemBuilder: (context, index) {
                    final skin = SkinCatalog.allSkins[index];
                    final isSelected = skin.id == _selectedSkinId;
                    final isEquipped = skin.id == GameData.selectedSkinId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSkinId = skin.id;
                        });
                      },
                      onDoubleTap: () {
                        setState(() {
                          _selectedSkinId = skin.id;
                          GameData.selectedSkinId = skin.id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? skin.rarity.color : const Color(0x22FFFFFF),
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected ? skin.rarity.color.withAlpha(20) : Colors.black.withAlpha(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Mini jet preview
                            CustomPaint(
                              size: const Size(40, 50),
                              painter: _MiniJetPainter(skin: skin),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              skin.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xAAFFFFFF),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: skin.rarity.color,
                              ),
                            ),
                            if (isEquipped)
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  'EQUIPPED',
                                  style: TextStyle(
                                    color: Color(0xFF00FF88),
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Equip button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      GameData.selectedSkinId = _selectedSkinId;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedSkinId == GameData.selectedSkinId
                            ? const Color(0x44FFFFFF)
                            : const Color(0xFF00FF88),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _selectedSkinId == GameData.selectedSkinId
                          ? Colors.transparent
                          : const Color(0x1500FF88),
                    ),
                    child: Text(
                      _selectedSkinId == GameData.selectedSkinId ? 'EQUIPPED' : 'EQUIP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedSkinId == GameData.selectedSkinId
                            ? const Color(0x66FFFFFF)
                            : const Color(0xFF00FF88),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _effectBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withAlpha(80)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

class _SkinPreviewPainter extends CustomPainter {
  final JetSkin skin;
  final double animValue;

  _SkinPreviewPainter({required this.skin, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = 2.5;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    Color primary = skin.primaryColor;
    Color secondary = skin.secondaryColor;
    Color accent = skin.accentColor;

    if (skin.hasRainbowShift) {
      final hue = animValue * 360;
      primary = HSVColor.fromAHSV(1, hue, 0.8, 0.9).toColor();
      secondary = HSVColor.fromAHSV(1, (hue + 30) % 360, 0.8, 0.7).toColor();
      accent = HSVColor.fromAHSV(1, (hue + 60) % 360, 0.6, 1.0).toColor();
    }

    // Energy aura
    if (skin.hasEnergyAura) {
      final auraPaint = Paint()
        ..color = accent.withAlpha((60 + sin(animValue * 6 * pi) * 30).toInt().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset.zero, 18 + sin(animValue * 4 * pi) * 2, auraPaint);
    }

    // Body
    final bodyPaint = Paint()..color = primary;
    final bodyPath = Path()
      ..moveTo(0, -18)
      ..lineTo(8, 2)
      ..lineTo(5, 16)
      ..lineTo(0, 12)
      ..lineTo(-5, 16)
      ..lineTo(-8, 2)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Wings
    final wingPaint = Paint()..color = secondary;
    final leftWing = Path()
      ..moveTo(-5, 0)
      ..lineTo(-16, 10)
      ..lineTo(-14, 12)
      ..lineTo(-4, 8)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    final rightWing = Path()
      ..moveTo(5, 0)
      ..lineTo(16, 10)
      ..lineTo(14, 12)
      ..lineTo(4, 8)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // Cockpit
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -4), width: 6, height: 10),
      Paint()..color = accent,
    );

    // Engine glow
    if (skin.hasFlameTrail) {
      final flameSize = 4 + sin(animValue * 20 * pi) * 2;
      final flamePaint = Paint()
        ..color = skin.trailColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(-3, 18), flameSize, flamePaint);
      canvas.drawCircle(Offset(3, 18), flameSize, flamePaint);
    } else {
      final engineSize = 2 + sin(animValue * 14 * pi) * 1;
      final enginePaint = Paint()
        ..color = const Color(0xFFFF6D00)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(-3, 18), engineSize, enginePaint);
      canvas.drawCircle(Offset(3, 18), engineSize, enginePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniJetPainter extends CustomPainter {
  final JetSkin skin;

  _MiniJetPainter({required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    final bodyPaint = Paint()..color = skin.primaryColor;
    final bodyPath = Path()
      ..moveTo(cx, 4)
      ..lineTo(cx + 6, cy + 3)
      ..lineTo(cx + 4, size.height - 4)
      ..lineTo(cx, size.height - 7)
      ..lineTo(cx - 4, size.height - 4)
      ..lineTo(cx - 6, cy + 3)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Wings
    final wingPaint = Paint()..color = skin.secondaryColor;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 4, cy)
        ..lineTo(cx - 12, cy + 8)
        ..lineTo(cx - 10, cy + 10)
        ..lineTo(cx - 3, cy + 7)
        ..close(),
      wingPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 4, cy)
        ..lineTo(cx + 12, cy + 8)
        ..lineTo(cx + 10, cy + 10)
        ..lineTo(cx + 3, cy + 7)
        ..close(),
      wingPaint,
    );

    // Cockpit
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 4, height: 7),
      Paint()..color = skin.accentColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
