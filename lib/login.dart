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
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: responsive.hp(
                      responsive.value(mobile: 15, desktop: 8),
                    ),
                  ),
                  Center(
                    child: Text(
                      "¡Bienvenido!\nIniciar Sesión",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.dp(
                          responsive.value(mobile: 7, desktop: 3.5),
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.backgroundColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: responsive.hp(
                      responsive.value(mobile: 5, desktop: 3),
                    ),
                  ),
                ],
              ),

              // Parte blanca inferior con formulario
              Expanded(
                child: Container(
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
                    child: Center(
                      // 🟢 RESPONSIVIDAD: Limitamos el ancho en PC
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: responsive.maxFormWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _emailCtrl,
                              decoration: AppTheme.inputDecoration("Correo"),
                            ),
                            SizedBox(height: responsive.hp(2)),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: AppTheme.inputDecoration(
                                "Contraseña",
                              ),
                            ),
                            SizedBox(height: responsive.hp(1.5)),
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
                                      fontSize: responsive.bodyFontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: responsive.hp(2)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: responsive.hp(1.8).clamp(14, 20),
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
                                  fontSize: responsive.bodyFontSize + 2,
                                  color: AppTheme.backgroundColor,
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.hp(2)),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot_password',
                                  );
                                },
                                child: Text(
                                  "¿Olvidaste tu contraseña?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: responsive.bodyFontSize,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: responsive.hp(2.5)),
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
                                      fontSize: responsive.bodyFontSize,
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
