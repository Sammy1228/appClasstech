import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import '../Utils/responsive.dart';

class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Título de la actividad"),
        titleTextStyle: TextStyle(
          color: AppTheme.backgroundColor,
          // 🔹 Limitamos el tamaño mínimo y máximo del texto
          fontSize: (responsive.sp(2.5)).clamp(16, 22),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 🔹 Margen lateral dinámico pero con límite máximo
          double horizontalPadding = width < 500
              ? 16
              : width < 900
                  ? 40
                  : 80;

          // 🔹 Ancho máximo limitado para evitar márgenes excesivos
          double maxWidth = width < 900 ? 700 : 900;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: responsive.hp(2),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🟨 Contenedor descripción
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.wp(5),
                        vertical: responsive.hp(3),
                      ),
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
                          Text(
                            "Fecha de entrega",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: (responsive.sp(2)).clamp(14, 18),
                            ),
                          ),
                          SizedBox(height: responsive.hp(1)),
                          Text(
                            "Descripción de la actividad:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (responsive.sp(2)).clamp(14, 18),
                            ),
                          ),
                          SizedBox(height: responsive.hp(0.5)),
                          Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris et molestie felis. Duis eget urna id odio luctus consequat ut at dui. In scelerisque purus magna. Vestibulum eget erat finibus, vehicula sapien a, sollicitudin velit. Duis tincidunt luctus libero at ultrices. Vivamus congue vitae lectus dignissim accumsan. Interdum et malesuada fames ac ante ipsum primis in faucibus. Curabitur finibus fermentum felis sit amet ullamcorper. Nunc sit amet fringilla orci, vel vehicula sem.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: (responsive.sp(1.8)).clamp(13, 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(3)),

                    // 🟩 Campo URL
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Campo de url del video (solo si se requiere)",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: responsive.hp(2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsive.hp(3)),

                    // 🟦 Subida de archivos
                    Container(
                      height: responsive.hp(25),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.primaryColor, width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: responsive.isMobile
                                ? responsive.wp(20)
                                : responsive.wp(10),
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(height: responsive.hp(1)),
                          Text(
                            "Adjunta tus archivos",
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: (responsive.sp(2)).clamp(14, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(3)),

                    // 🟧 Botón Enviar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.wp(10),
                          vertical: responsive.hp(2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Enviar",
                        style: TextStyle(
                          color: AppTheme.backgroundColor,
                          fontSize: (responsive.sp(2.2)).clamp(15, 20),
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.hp(3)),

                    // 🟥 Retroalimentación
                    Container(
                      padding: EdgeInsets.all(responsive.wp(4)),
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
                          CircleAvatar(
                            backgroundColor: const Color(0xFFE53935),
                            radius: responsive.wp(5),
                            child: Text(
                              "D",
                              style: TextStyle(
                                color: AppTheme.backgroundColor,
                                fontSize: (responsive.sp(2.2)).clamp(14, 18),
                              ),
                            ),
                          ),
                          SizedBox(width: responsive.wp(4)),
                          Expanded(
                            child: Text(
                              "Retroalimentación del alumno (opcional)",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: (responsive.sp(1.9)).clamp(13, 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
