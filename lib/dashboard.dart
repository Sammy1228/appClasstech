import 'package:flutter/material.dart';
import 'widgets/clase_card.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import 'mostrarclases.dart';
import 'tituloact.dart'; // Asegúrate de importar la nueva pantalla

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Panel Principal"),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              final TextEditingController codigoController =
                  TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      "Unirse a una clase",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Ingresa el código de la clase para unirte:",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: codigoController,
                          decoration: const InputDecoration(
                            labelText: "Código de clase",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String codigo = codigoController.text.trim();
                          if (codigo.isNotEmpty) {
                            Navigator.pop(context); // Cierra el popup

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Clase se agregó con éxito 🎉"),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            print("Código ingresado: $codigo");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: AppTheme.backgroundColor,
                        ),
                        child: const Text("Unirse"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add, color: AppTheme.backgroundColor),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppTheme.claseColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 160,
                    child: ClaseCard(
                      title: "Clase ${index + 1}",
                      description: "Descripción de la clase",
                      color: AppTheme.claseColors[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MostrarClasePage(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Llamada a las tarjetas de actividad con la navegación
            _activityCard(
              context,
              "Actividad 1",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
            _activityCard(
              context,
              "Actividad 2",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
            _activityCard(
              context,
              "Actividad 3",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
            _activityCard(
              context,
              "Actividad 4",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
            _activityCard(
              context,
              "Actividad 5",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
            _activityCard(
              context,
              "Actividad 6",
              "Fecha de entrega",
              "Descripción de la actividad dentro de la clase",
            ),
          ],
        ),
      ),
    );
  }

  static Widget _activityCard(
    BuildContext context,
    String title,
    String fecha,
    String descripcion,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActividadPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            Text(fecha, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            Text(descripcion, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
