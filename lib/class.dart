import 'crearclase.dart';
import 'crearactividad.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class ClasesScreen extends StatelessWidget {
  const ClasesScreen({super.key});

  final List<Map<String, dynamic>> clases = const [
    {"title": "Clase 1", "desc": "Descripción de la clase", "color": 0xFFFFE0B2},
    {"title": "Clase 2", "desc": "Descripción de la clase", "color": 0xFFFFE0B2},
    {"title": "Clase 3", "desc": "Descripción de la clase", "color": 0xFFFFCDD2},
    {"title": "Clase 4", "desc": "Descripción de la clase", "color": 0xFFFFCDD2},
    {"title": "Clase 5", "desc": "Descripción de la clase", "color": 0xFFBBDEFB},
    {"title": "Clase 6", "desc": "Descripción de la clase", "color": 0xFFBBDEFB},
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isPortrait = responsive.isPortrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Clases",
          style: TextStyle(
            fontSize: responsive.titleFontSize * 0.6,
            color: AppTheme.backgroundColor,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        actions: [
          IconButton(
            icon: AppTheme.themedIcon(
              Icons.add,
              color: AppTheme.backgroundColor,
              size: responsive.scale(0.08, 0.05),
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
                        _dialogButton(
                          context,
                          responsive,
                          "Crear Clase",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearClasePage(),
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),
                        _dialogButton(
                          context,
                          responsive,
                          "Crear Actividad",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CrearActividadPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(responsive.wp(3)),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isPortrait ? 2 : 3,
            crossAxisSpacing: responsive.wp(3),
            mainAxisSpacing: responsive.hp(2),
            childAspectRatio: isPortrait ? 1 : 1.2,
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

  Widget _dialogButton(
    BuildContext context,
    Responsive responsive,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: responsive.fieldWidth * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.backgroundColor,
          padding: EdgeInsets.symmetric(
            vertical: responsive.hp(1.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: responsive.scale(0.04, 0.03)),
        ),
      ),
    );
  }
}
