import 'package:appzacek/firebase_options.dart';
import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
// --- NUEVO IMPORTE ---
import 'package:appzacek/providers/provider_entregas.dart';
// --- FIN NUEVO IMPORTE ---
import 'package:appzacek/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'splash.dart';
import 'login.dart';
import 'register.dart';
import 'dashboard.dart';
import 'config.dart';
import 'perfil.dart';
import 'class.dart';
import 'retroalimentacio.dart';

// --- NUEVAS PANTALLAS ---
import 'calificar_actividad_page.dart';
import 'ver_entrega_page.dart';
// --- FIN NUEVAS PANTALLAS ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authentication()),
        ChangeNotifierProvider(create: (_) => ProviderClases()),
        ChangeNotifierProvider(create: (_) => ProviderActividades()),
        // --- NUEVO PROVIDER AÑADIDO ---
        ChangeNotifierProvider(create: (_) => ProviderEntregas()),
        // --- FIN NUEVO PROVIDER ---
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Classtech',
        initialRoute: '/Splash',
        routes: {
          '/Splash': (context) => const Splash(),
          '/login': (context) => const Login(),
          '/register': (context) => const Register(),
          '/dashboard': (context) => const Dashboard(),
          '/config': (context) => const Configuracion(),
          '/perfil': (context) => const PerfilScreen(),
          '/class': (context) => const ClasesScreen(),
          '/retroalimentacion': (context) => const RetroalimentacionPage(),

          // --- NUEVAS RUTAS (opcional, pero buena práctica) ---
          '/calificar_actividad': (context) =>
              const CalificarActividadPage(actividadId: ''),
          '/ver_entrega': (context) => const VerEntregaPage(entregaId: ''),
          // --- FIN NUEVAS RUTAS ---
        },
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
