import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class MostrarClasePage extends StatelessWidget {
  const MostrarClasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Título de la clase",
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: responsive.dp(5),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu,
                  color: AppTheme.backgroundColor, size: responsive.dp(5.5)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete,
                color: AppTheme.backgroundColor, size: responsive.dp(5.5)),
            onPressed: () {
              _showDeleteConfirmationDialog(context, responsive);
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: responsive.verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caja amarilla con información de la clase
            Container(
              padding: EdgeInsets.all(responsive.dp(4)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5B4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Química avanzada",
                          style: TextStyle(
                            fontSize: responsive.dp(4.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),
                        Text(
                          "Nombre del docente",
                          style: TextStyle(
                            fontSize: responsive.dp(3.8),
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),
                        Text(
                          "Descripcion: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et molestie felis. Duis eget urna id odio luctus consequat ut at dui. In scelerisque purus magna...",
                          style: AppTheme.bodyText.copyWith(
                            fontSize: responsive.dp(3.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: responsive.wp(3)),
                  Image.asset(
                    'assets/images/logo.png',
                    width: responsive.wp(18),
                    height: responsive.wp(18),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            // Título de sección
            Text(
              "Actividades",
              style: TextStyle(
                fontSize: responsive.dp(5),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            // Lista de actividades
            Column(
              children: List.generate(4, (index) {
                return _buildActivityCard(responsive);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de actividad
  Widget _buildActivityCard(Responsive responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.hp(1.5)),
      padding: EdgeInsets.all(responsive.dp(3.5)),
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
              Icon(Icons.edit,
                  color: AppTheme.primaryColor, size: responsive.dp(5)),
              SizedBox(width: responsive.wp(2)),
              Text(
                "Actividad",
                style: TextStyle(
                  fontSize: responsive.dp(4),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.hp(0.5)),
          Text(
            "Fecha de entrega",
            style: TextStyle(color: Colors.black54, fontSize: responsive.dp(3)),
          ),
          SizedBox(height: responsive.hp(0.8)),
          Text(
            "Descripción de la actividad dentro de la clase",
            style: TextStyle(color: Colors.black54, fontSize: responsive.dp(3.3)),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación
  void _showDeleteConfirmationDialog(
      BuildContext context, Responsive responsive) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Eliminar clase",
            style: TextStyle(fontSize: responsive.dp(4.5)),
          ),
          content: Text(
            "¿Estás seguro de que quieres eliminar esta clase? Esta acción no se puede deshacer.",
            style: TextStyle(fontSize: responsive.dp(3.4)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(fontSize: responsive.dp(3.5)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Clase eliminada con éxito."),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                "Eliminar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.dp(3.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
