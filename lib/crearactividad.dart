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
        title: const Text("Crear actividad"),
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.fieldWidth),
            child: Column(
              children: [
                TextField(
                  decoration: AppTheme.inputDecoration("Título de la actividad"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Descripción"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Url de contenido"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Carrera"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Semestre"),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  items: ["Clase A", "Clase B", "Clase C"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: AppTheme.inputDecoration("Clase"),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    child: Text(
                      "Crear",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}