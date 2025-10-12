import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos dimensiones y orientación
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Ajustes dinámicos según orientación
    final bool isPortrait = orientation == Orientation.portrait;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    // Escalado adaptable
    final double fontScale = isPortrait ? screenWidth * 0.13 : screenHeight * 0.13;
    final double paddingVertical = isPortrait ? screenHeight * 0.10 : screenHeight * 0.06;
    final double paddingHorizontal = isPortrait ? screenWidth * 0.09 : screenWidth * 0.20;

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
              SizedBox(height: screenHeight * (isPortrait ? 0.15 : 0.08)),
              Center(
                child: Text(
                  "¡Bienvenido!\nIniciar Sesión",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontScale,
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
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isPortrait ? double.infinity : screenWidth * 0.6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            decoration: AppTheme.inputDecoration("Correo"),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          TextField(
                            obscureText: true,
                            decoration: AppTheme.inputDecoration("Contraseña"),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: (_) {}),
                              Flexible(
                                child: Text(
                                  "Recuérdame",
                                  style: TextStyle(
                                    fontSize: isPortrait
                                        ? screenWidth * 0.04
                                        : screenHeight * 0.04,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/dashboard');
                            },
                            child: Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                fontSize: isPortrait
                                    ? screenWidth * 0.045
                                    : screenHeight * 0.045,
                                color: AppTheme.backgroundColor,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
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
                                    fontSize: isPortrait
                                        ? screenWidth * 0.04
                                        : screenHeight * 0.04,
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
