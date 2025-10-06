import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart'; // Asegúrate de la ruta correcta
import '../theme/app_theme.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),
            CircleAvatar(
              radius: screenWidth * 0.15,
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.7),
              child: const Text(
                "NA",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildTextField("Nombres"),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                Expanded(child: _buildTextField("Apellido P")),
                SizedBox(width: screenWidth * 0.02),
                Expanded(child: _buildTextField("Apellido M")),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField("Correo"),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField("Semestre"),
            SizedBox(height: screenHeight * 0.02),
            _buildTextField("Carrera"),
            SizedBox(height: screenHeight * 0.04),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.018,
                  horizontal: screenWidth * 0.1,
                ),
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 14, color: AppTheme.backgroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(decoration: AppTheme.inputDecoration(label));
  }
}
