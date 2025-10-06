import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MostrarClasePage extends StatelessWidget {
  const MostrarClasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Título de la clase"),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.backgroundColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.backgroundColor),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caja amarilla con diseño de la imagen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5B4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  // Aquí se reemplaza Expanded por Flexible
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Química avanzada",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Nombre del docente",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Descripcion: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et molestie felis. Duis eget urna id odio luctus consequat ut at dui. In scelerisque purus magna. Vestibulum eget erat finibus, vehicula sapien a, sollicitudin velit. Duis tincidunt lectus libero at ultrices. Vivamus congue vitae lectus dignissim accumsan. Interdum et malesuada fames ac ante ipsum primis in faucibus. Curabitur finibus fermentum felis sit amet ullamcorper. Nunc sit amet fringilla orci, vel vehicula sem.",
                          style: AppTheme.bodyText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Image(
                    image: AssetImage(
                      'assets/images/logo.png',
                    ), // Revisa esta ruta
                    width: 80,
                    height: 80,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Título para la sección de actividades
            const Text(
              "Actividades",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de actividades
            Column(
              children: List.generate(4, (index) {
                return _buildActivityCard();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la tarjeta de actividad
  Widget _buildActivityCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                "Actividad",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Fecha de entrega",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            "Descripción de la actividad dentro de la clase",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Cuadro de diálogo de confirmación para eliminar
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Eliminar clase"),
          content: const Text(
            "¿Estás seguro de que quieres eliminar esta clase? Esta acción no se puede deshacer.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el popup
                // Aquí podrías agregar la lógica para eliminar la clase
                // Por ejemplo, una llamada a un servicio
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Clase eliminada con éxito."),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
