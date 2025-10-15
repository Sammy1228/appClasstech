import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class CrearActividadPage extends StatelessWidget {
  const CrearActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
 return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Crear actividad",
          style: TextStyle(
            fontSize: responsive.dp(2.1),
            color: AppTheme.backgroundColor,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.wp(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(responsive, "Título de la actividad"),
            SizedBox(height: responsive.hp(1.5)),
            _buildTextField(responsive, "Descripción"),
            SizedBox(height: responsive.hp(1.5)),
            _buildTextField(responsive, "Url de contenido"),
            SizedBox(height: responsive.hp(1.5)),
            _buildTextField(responsive, "Carrera"),
            SizedBox(height: responsive.hp(1.5)),
            _buildTextField(responsive, "Semestre"),
            SizedBox(height: responsive.hp(1.5)),

            // Dropdown adaptativo
            DropdownButtonFormField<String>(
              items: ["Clase A", "Clase B", "Clase C"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
              decoration: AppTheme.inputDecoration("Clase"),
              style: TextStyle(fontSize: responsive.dp(1.7)),
            ),
            SizedBox(height: responsive.hp(3)),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.dp(3)),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.hp(2),
                  horizontal: responsive.wp(5),
                ),
              ),
              onPressed: () {},
              child: Text(
                "Crear",
                style: TextStyle(
                  color: AppTheme.backgroundColor,
                  fontSize: responsive.dp(1.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(Responsive responsive, String label) {
    return TextField(
      decoration: AppTheme.inputDecoration(label),
      style: TextStyle(fontSize: responsive.dp(1.7)),
    );
  }
}