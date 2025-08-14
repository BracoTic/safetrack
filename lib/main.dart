import 'package:flutter/material.dart';
import 'core/services/hive_config.dart';
import 'seed/seed_guard.dart';

import 'views/inicio_screen.dart';
import 'views/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();
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
        '/inicio': (_) => const InicioScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
