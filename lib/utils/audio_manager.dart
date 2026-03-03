import 'game_data.dart';

class AudioManager {
  static bool _initialized = false;
  
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  static void playExplosion() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('explosion');
  }

  static void playPowerup() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('powerup');
  }

  static void playMissileLaunch() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('missile');
  }

  static void playButtonClick() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('click');
  }

  static void playAchievement() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('achievement');
  }

  static void playCloseCall() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('closecall');
  }

  static void playShieldHit() {
    if (!GameData.soundEnabled) return;
    _playSynthSound('shield');
  }

  // Since we can't bundle audio files easily, we'll use visual feedback
  // In production, replace with actual audio files
  static void _playSynthSound(String type) {
    // Placeholder - in production, use FlameAudio.play('$type.mp3')
    // For now, sounds are handled visually
  }
}
