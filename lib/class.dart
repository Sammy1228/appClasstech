import 'crearclase.dart';
import 'crearactividad.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';

class ClasesScreen extends StatelessWidget {
  const ClasesScreen({super.key});

  final List<Map<String, dynamic>> clases = const [
    {
      "title": "Clase 1",
      "desc": "Descripción de la clase",
      "color": 0xFFFFE0B2,
    },
    {
      "title": "Clase 2",
      "desc": "Descripción de la clase",
      "color": 0xFFFFE0B2,
    },
    {
      "title": "Clase 3",
      "desc": "Descripción de la clase",
      "color": 0xFFFFCDD2,
    },
    {
      "title": "Clase 4",
      "desc": "Descripción de la clase",
      "color": 0xFFFFCDD2,
    },
    {
      "title": "Clase 5",
      "desc": "Descripción de la clase",
      "color": 0xFFBBDEFB,
    },
    {
      "title": "Clase 6",
      "desc": "Descripción de la clase",
      "color": 0xFFBBDEFB,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clases"),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        actions: [
          IconButton(
            icon: AppTheme.themedIcon(
              Icons.add,
              color: AppTheme.backgroundColor,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Seleccionar Opción"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CrearClasePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: AppTheme.backgroundColor,
                          ),
                          child: const Text("Crear Clase"),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CrearActividadPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: AppTheme.backgroundColor,
                          ),
                          child: const Text("Crear Actividad"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: clases.length,
          itemBuilder: (context, index) {
            final clase = clases[index];
            return AppTheme.claseCard(
              title: clase["title"],
              description: clase["desc"],
              color: Color(clase["color"]),
            );
          },
        ),
      ),
    );
  }
}
