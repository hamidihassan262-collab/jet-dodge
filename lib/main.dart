import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/game_data.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Full screen immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize game data
  await GameData.init();

  runApp(const JetDodgeApp());
}

class JetDodgeApp extends StatelessWidget {
  const JetDodgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jet Dodge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          secondary: Color(0xFFBB86FC),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
