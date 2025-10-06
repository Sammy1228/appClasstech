import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Fondo superior con texto centrado
          Column(
            children: [
              SizedBox(height: screenHeight * 0.15),
              Center(
                // Centrar el texto
                child: Text(
                  "¡Bienvenido!\nIniciar Sesión",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.backgroundColor,
                  ),
                ),
              ),
            ],
          ),

          // Parte blanca inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity, // Asegura que ocupe todo el ancho
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.09,
                vertical: screenHeight * 0.10,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ajusta al contenido
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Estira horizontalmente
                children: [
                  TextField(decoration: AppTheme.inputDecoration("Correo")),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    obscureText: true,
                    decoration: AppTheme.inputDecoration("Contraseña"),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Text("Recuérdame"),
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
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
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
                            fontSize: screenWidth * 0.04,
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
        ],
      ),
    );
  }
}
