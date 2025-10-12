import 'package:appzacek/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';
import 'register.dart';
import 'dashboard.dart';
import 'config.dart';
import 'perfil.dart';
import 'class.dart';
import 'retroalimentacio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classtech',
      initialRoute: '/Splash',
      routes: {
        '/Splash': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/dashboard': (context) => const Dashboard(),
        '/config': (context) => const Configuracion(),
        '/perfil': (context) => const PerfilScreen(tipoUsuario: "profesor"),
        '/class': (context) => const ClasesScreen(),
        '/retroalimentacion': (context) => const RetroalimentacionPage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppTheme.primaryColor,
      ),
    );
  }
}
