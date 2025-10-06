import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'widgets/custom_drawer.dart';

class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo de la pantalla
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Título de la actividad"),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.backgroundColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.backgroundColor),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenedor de la descripción (rectángulo redondeado)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 39, vertical: 25),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 220, 168),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fecha de entrega",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Descripción de la actividad:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et molestie felis. Duis eget urna id odio luctus consequat ut at dui. In scelerisque purus magna. Vestibulum eget erat finibus, vehicula sapien a, sollicitudin velit. Duis tincidunt luctus libero at ultrices. Vivamus congue vitae lectus dignissim accumsan. Interdum et malesuada fames ac ante ipsum primis in faucibus. Curabitur finibus fermentum felis sit amet ullamcorper. Nunc sit amet fringilla orci, vel vehicula sem.",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de URL del video
            TextField(
              decoration: InputDecoration(
                hintText: "Campo de url del video (solo si se requiere)",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Contenedor para la subida de archivos
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 90,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Adjunta tus archivos",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón Enviar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Enviar",
                style: TextStyle(color: AppTheme.backgroundColor, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Retroalimentación
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE53935),
                    child: Text(
                      "D",
                      style: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Retroalimentación del alumno (opcional)",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
