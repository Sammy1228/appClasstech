import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import '../Utils/responsive.dart';
import '../providers/provider_autenticacion.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  //Método para cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final remember = prefs.getBool('remember_me') ?? false;

    setState(() {
      _emailCtrl.text = savedEmail;
      _passwordCtrl.text = savedPassword;
      _rememberMe = remember;
    });
  }

  //Método para guardar credenciales si el checkbox está seleccionado
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailCtrl.text.trim());
      await prefs.setString('saved_password', _passwordCtrl.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // 1. Fondo superior con texto
              Column(
                mainAxisSize:
                    MainAxisSize.min, // Ocupa solo el espacio necesario
                children: [
                  SizedBox(
                    height:
                        responsive.screenHeight *
                        (responsive.isPortrait ? 0.15 : 0.08),
                  ),
                  Center(
                    child: Text(
                      "¡Bienvenido!\nIniciar Sesión",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // ✅ CAMBIO: Añadido clamp
                        fontSize: responsive.fontScale.clamp(22, 34),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Parte blanca inferior con formulario
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                    vertical: responsive.verticalPadding,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    // ✅ CAMBIO: Añadido Center para web
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // ✅ CAMBIO: maxWidth fijo para el formulario en web
                          maxWidth: 500,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _emailCtrl,
                              decoration: AppTheme.inputDecoration("Correo"),
                            ),
                            SizedBox(height: responsive.screenHeight * 0.02),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: AppTheme.inputDecoration(
                                "Contraseña",
                              ),
                            ),
                            SizedBox(height: responsive.screenHeight * 0.015),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                Flexible(
                                  child: Text(
                                    "Recuérdame",
                                    style: TextStyle(
                                      // ✅ CAMBIO: Añadido clamp
                                      fontSize:
                                          (responsive.isPortrait
                                                  ? responsive.screenWidth *
                                                        0.04
                                                  : responsive.screenHeight *
                                                        0.04)
                                              .clamp(14, 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.screenHeight * 0.02),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: responsive.screenHeight * 0.018,
                                ),
                              ),
                              onPressed: () async {
                                final auth = Provider.of<Authentication>(
                                  context,
                                  listen: false,
                                );
                                final email = _emailCtrl.text.trim();
                                final password = _passwordCtrl.text;

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Por favor ingresa correo y contraseña",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                auth.setEmail = email;
                                auth.setPassword = password;

                                setState(() => _isLoading = true);

                                //guardar credenciales si aplica
                                await _saveCredentials();

                                try {
                                  final user = await auth.login();
                                  if (user != null &&
                                      auth.tipoUsuario.isNotEmpty) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/dashboard',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Credenciales incorrectas",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                  return;
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                              child: Text(
                                _isLoading ? "Cargando..." : "Iniciar Sesión",
                                style: TextStyle(
                                  // ✅ CAMBIO: Añadido clamp
                                  fontSize:
                                      (responsive.isPortrait
                                              ? responsive.screenWidth * 0.045
                                              : responsive.screenHeight * 0.045)
                                          .clamp(15, 20),
                                  color: AppTheme.backgroundColor,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.screenHeight * 0.025),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: "¿No tienes cuenta? ",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      // ✅ CAMBIO: Añadido clamp
                                      fontSize:
                                          (responsive.isPortrait
                                                  ? responsive.screenWidth *
                                                        0.04
                                                  : responsive.screenHeight *
                                                        0.04)
                                              .clamp(14, 18),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Regístrate aquí",
                                        style: TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
