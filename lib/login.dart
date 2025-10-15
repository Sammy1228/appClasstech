import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../Utils/responsive.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
            mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
            children: [
              SizedBox(height: responsive.screenHeight * (responsive.isPortrait ? 0.15 : 0.08)),
              Center(
                child: Text(
                  "¡Bienvenido!\nIniciar Sesión",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.fontScale,
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: responsive.isPortrait ? double.infinity : responsive.screenWidth * 0.6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            decoration: AppTheme.inputDecoration("Correo"),
                          ),
                          SizedBox(height: responsive.screenHeight * 0.02),
                          TextField(
                            obscureText: true,
                            decoration: AppTheme.inputDecoration("Contraseña"),
                          ),
                          SizedBox(height: responsive.screenHeight * 0.015),
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: (_) {}),
                              Flexible(
                                child: Text(
                                  "Recuérdame",
                                  style: TextStyle(
                                    fontSize: responsive.isPortrait
                                        ? responsive.screenWidth * 0.04
                                        : responsive.screenHeight * 0.04,
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
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/dashboard');
                            },
                            child: Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                fontSize: responsive.isPortrait
                                    ? responsive.screenWidth * 0.045
                                    : responsive.screenHeight * 0.045,
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
                                    fontSize: responsive.isPortrait
                                        ? responsive.screenWidth * 0.04
                                        : responsive.screenHeight * 0.04,
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
            ],
          );
        },
      ),
    );
  }
}
