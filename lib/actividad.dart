import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Título de la actividad",
          style: TextStyle(
            fontSize: responsive.titleFontSize * 0.6, // Escala adaptada
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: responsive.verticalPadding,
        ),
        child: Column(
          children: [
            // Caja amarilla
            Container(
              width: responsive.fieldWidth,
              padding: EdgeInsets.all(responsive.wp(4)),
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
                  Text(
                    "Fecha de entrega",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.scale(0.045, 0.03),
                    ),
                  ),
                  SizedBox(height: responsive.hp(1)),
                  Text(
                    "Descripción de la actividad:\nLorem ipsum dolor sit amet...",
                    style: AppTheme.bodyText.copyWith(
                      fontSize: responsive.scale(0.04, 0.03),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive.hp(2)),

            // Campo URL
            SizedBox(
              width: responsive.fieldWidth,
              child: TextField(
                decoration: AppTheme.inputDecoration(
                  "Campo de URL del video (solo si se requiere)",
                ),
              ),
            ),

            SizedBox(height: responsive.hp(2)),

            // Subida de archivos
            Container(
              width: responsive.fieldWidth,
              padding: EdgeInsets.all(responsive.wp(8)),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                children: [
                  AppTheme.themedIcon(Icons.upload_file,
                      size: responsive.scale(0.15, 0.08)),
                  SizedBox(height: responsive.hp(1)),
                  Text(
                    "Adjunta tus archivos",
                    style: TextStyle(
                      fontSize: responsive.scale(0.04, 0.03),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive.hp(3)),

            // Botón enviar
            SizedBox(
              width: responsive.fieldWidth * 0.7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(6),
                    vertical: responsive.hp(1.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Enviar",
                  style: TextStyle(
                    color: AppTheme.backgroundColor,
                    fontSize: responsive.scale(0.045, 0.03),
                  ),
                ),
              ),
            ),

            SizedBox(height: responsive.hp(3)),

            // Retroalimentación
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent,
                radius: responsive.wp(5),
                child: Text(
                  "D",
                  style: TextStyle(
                    color: AppTheme.backgroundColor,
                    fontSize: responsive.scale(0.04, 0.03),
                  ),
                ),
              ),
              title: Text(
                "Retroalimentación del alumno (opcional)",
                style: TextStyle(
                  fontSize: responsive.scale(0.04, 0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
