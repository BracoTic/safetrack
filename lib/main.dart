import 'package:flutter/material.dart';
import 'core/services/hive_config.dart';
import 'core/utils/default_data.dart';

// Vistas
import 'views/inicio_screen.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive y datos, adaptado para Web y otros
  await limpiarHive();
  await initHive(); // Solo hace algo en no-Web
  await borrarYAgregarDatosPorDefecto(); // Adaptado multiplataforma

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
