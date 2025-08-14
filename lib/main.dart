import 'package:flutter/material.dart';
import 'core/services/hive_config.dart';
// ⚠️ Ya NO importes default_data.dart aquí para no sembrar siempre.
// import 'core/utils/default_data.dart';
import 'seed/seed_guard.dart'; // ← el guard que creaste

// Vistas
import 'views/inicio_screen.dart';
import 'views/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive (registros de adapters, etc.)
  await initHive();

  // Siembra/seed solo si hace falta (primera vez) o cuando lo fuerces en debug.
  await initDatosPorDefectoSiHaceFalta();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/inicio',
      routes: {
        '/inicio': (context) => const InicioScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
