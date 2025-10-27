import 'package:appzacek/providers/provider_clases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/clase_card.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import 'mostrarclases.dart';
import 'tituloact.dart';
import 'Utils/responsive.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    // Ajustes base para mantener proporciones similares al diseño original
    final double basePadding = r.hp(2).clamp(12, 24);
    final double cardSpacing = r.hp(1.5).clamp(10, 20);
    final double textSize = r.dp(4).clamp(14, 20);
    final double titleSize = r.dp(4.5).clamp(16, 22);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Panel Principal",
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: titleSize,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        actions: [
          IconButton(
            onPressed: () {
              final TextEditingController codigoController =
                  TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final r2 = Responsive(context);
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      "Unirse a una clase",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: titleSize,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Ingresa el código de la clase para unirte:",
                          style: TextStyle(fontSize: textSize),
                        ),
                        SizedBox(height: basePadding),
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
                        child: Text(
                          "Cancelar",
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String codigo = codigoController.text.trim();
                          if (codigo.isNotEmpty) {
                            final provider = Provider.of<ProviderClases>(context, listen: false);

                            final uidAlumno = FirebaseAuth.instance.currentUser?.uid;
                            if (uidAlumno == null) return;

                            String resultado = await provider.unirseAClase(codigo, uidAlumno);

                            String mensaje = '';
                            Color color = Colors.green;

                            switch (resultado) {
                              case "ok":
                                mensaje = "Clase agregada con éxito";
                                break;
                              case "no_existe":
                                mensaje = "Código de clase no existe";
                                color = Colors.red;
                                break;
                              case "ya_inscrito":
                                mensaje = "Ya estás inscrito en esta clase";
                                color = Colors.orange;
                                break;
                              default:
                                mensaje = "Ocurrió un error";
                                color = Colors.red;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensaje),
                                backgroundColor: color,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: AppTheme.backgroundColor,
                        ),
                        child: Text(
                          "Unirse",
                          style: TextStyle(fontSize: textSize),
                        ),
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
        padding: EdgeInsets.all(basePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: r.hp(22).clamp(150, 220),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppTheme.claseColors.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: cardSpacing),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: r.wp(40).clamp(140, 180),
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
            SizedBox(height: r.hp(2).clamp(12, 24)),
            // Actividades
            for (int i = 1; i <= 6; i++)
              _activityCard(
                context,
                "Actividad $i",
                "Fecha de entrega",
                "Descripción de la actividad dentro de la clase",
                r,
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
    Responsive r,
  ) {
    final double innerPadding = r.hp(2).clamp(12, 20);
    final double textSize = r.dp(3.6).clamp(13, 18);
    final double iconSize = r.dp(4.8).clamp(20, 26);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActividadPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: innerPadding),
        padding: EdgeInsets.all(innerPadding),
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
                Icon(Icons.edit,
                    color: AppTheme.primaryColor, size: iconSize),
                SizedBox(width: r.wp(2).clamp(8, 16)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: textSize + 2,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            Text(
              fecha,
              style: TextStyle(color: Colors.blue, fontSize: textSize - 1),
            ),
            SizedBox(height: r.hp(0.8).clamp(6, 10)),
            Text(
              descripcion,
              style: TextStyle(
                color: Colors.black54,
                fontSize: textSize - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
