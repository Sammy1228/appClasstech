import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class Register extends StatelessWidget {
  const Register({super.key});

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
                child: Text(
                  "Registro",
                  style: TextStyle(
                    fontSize: screenWidth * 0.15,
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
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(decoration: AppTheme.inputDecoration("Nombre(s)")),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(decoration: AppTheme.inputDecoration("Apellidos")),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(decoration: AppTheme.inputDecoration("Correo")),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(decoration: AppTheme.inputDecoration("Escuela")),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    obscureText: true,
                    decoration: AppTheme.inputDecoration("Contraseña"),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    obscureText: true,
                    decoration: AppTheme.inputDecoration(
                      "Repite la contraseña",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Registrarme",
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
                        Navigator.pop(context);
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Ya tienes una cuenta, ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth * 0.04,
                          ),
                          children: [
                            TextSpan(
                              text: "inicia sesión aquí",
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
