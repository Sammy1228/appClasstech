import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Título de la actividad"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Caja amarilla
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5B4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fecha de entrega",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Descripción de la actividad:\nLorem ipsum dolor sit amet...",
                    style: AppTheme.bodyText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo URL
            TextField(
              decoration: AppTheme.inputDecoration(
                "Campo de url del video (solo si se requiere)",
              ),
            ),
            const SizedBox(height: 20),

            // Subida de archivos
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  AppTheme.themedIcon(Icons.upload_file, size: 64),
                  const SizedBox(height: 8),
                  const Text("Adjunta tus archivos"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón enviar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Enviar",
                style: TextStyle(color: AppTheme.backgroundColor),
              ),
            ),
            const SizedBox(height: 20),

            // Retroalimentación
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: const Text(
                  "D",
                  style: TextStyle(color: AppTheme.backgroundColor),
                ),
              ),
              title: const Text("Retroalimentación del alumno (opcional)"),
            ),
          ],
        ),
      ),
    );
  }
}
