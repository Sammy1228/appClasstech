import 'package:appzacek/providers/provider_actividades.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class ActividadPage extends StatelessWidget {
  final String actividadId;

  const ActividadPage({super.key, required this.actividadId});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final actividadesProvider = Provider.of<ProviderActividades>(
      context,
      listen: false,
    );

    return StreamBuilder<DocumentSnapshot>(
      // 1. OBTENEMOS EL STREAM DE LA ACTIVIDAD ESPECÍFICA
      stream: actividadesProvider.obtenerActividadStreamPorId(actividadId),
      builder: (context, snapshotActividad) {
        // --- Manejo de estados de carga/error ---
        if (snapshotActividad.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshotActividad.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Text(
                "Error al cargar la actividad: ${snapshotActividad.error}",
              ),
            ),
          );
        }
        if (!snapshotActividad.hasData || !snapshotActividad.data!.exists) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: Text("Esta actividad no existe.")),
          );
        }

        // --- DATOS DE LA ACTIVIDAD ---
        final actividadData =
            snapshotActividad.data!.data() as Map<String, dynamic>;

        // Formateo de fecha
        String fechaFormateada = "Sin fecha de entrega";
        if (actividadData['fechaEntrega'] != null &&
            actividadData['fechaEntrega'] is Timestamp) {
          final fecha = (actividadData['fechaEntrega'] as Timestamp).toDate();
          fechaFormateada =
              "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}";
        }

        // Controlador para el campo URL
        final urlController = TextEditingController(
          text: actividadData['url'] ?? '',
        );

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            title: Text(
              actividadData['titulo'] ?? 'Sin Título', // 👈 DATO REAL
              style: TextStyle(
                // ✅ CAMBIO: Añadido clamp
                fontSize: (responsive.titleFontSize * 0.6).clamp(18, 22),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  // TODO: Lógica para eliminar actividad
                },
              ),
            ],
          ),
          // El drawer no es necesario en esta vista de detalle
          // drawer: const Drawer(),
          // ✅ CAMBIO: Añadido Center y ConstrainedBox
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700), // Ancho de formulario
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                child: Column(
                  children: [
                    // Caja amarilla
                    Container(
                      // width: responsive.fieldWidth, // 👈 REMOVIDO
                      padding: EdgeInsets.all(
                        responsive.wp(4).clamp(16, 24),
                      ), // ✅ CAMBIO
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
                            fechaFormateada, // 👈 DATO REAL
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // ✅ CAMBIO: Añadido clamp
                              fontSize: responsive
                                  .scale(0.045, 0.03)
                                  .clamp(16, 20),
                            ),
                          ),
                          // ✅ CAMBIO: Añadido clamp
                          SizedBox(height: responsive.hp(1).clamp(8, 12)),
                          Text(
                            actividadData['descripcion'] ??
                                'Sin descripción.', // 👈 DATO REAL
                            style: AppTheme.bodyText.copyWith(
                              // ✅ CAMBIO: Añadido clamp
                              fontSize: responsive
                                  .scale(0.04, 0.03)
                                  .clamp(14, 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Campo URL (ahora muestra la URL y es de solo lectura)
                    TextField(
                      // width: responsive.fieldWidth, // 👈 REMOVIDO
                      controller: urlController,
                      readOnly: true, // El alumno no debería editar esto
                      decoration: AppTheme.inputDecoration("URL de contenido")
                          .copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.link),
                              onPressed: () {
                                // TODO: Lógica para abrir el enlace
                              },
                            ),
                          ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Subida de archivos (Esto es para la entrega del alumno)
                    GestureDetector(
                      onTap: () {
                        // TODO: Lógica para subir archivos
                      },
                      child: Container(
                        // width: responsive.fieldWidth, // 👈 REMOVIDO
                        padding: EdgeInsets.all(
                          responsive.wp(8).clamp(24, 40),
                        ), // ✅ CAMBIO
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ), // Borde sutil
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          children: [
                            AppTheme.themedIcon(
                              Icons.upload_file,
                              // ✅ CAMBIO: Añadido clamp
                              size: responsive.scale(0.15, 0.08).clamp(50, 70),
                            ),
                            // ✅ CAMBIO: Añadido clamp
                            SizedBox(height: responsive.hp(1).clamp(8, 12)),
                            Text(
                              "Adjunta tus archivos",
                              style: TextStyle(
                                // ✅ CAMBIO: Añadido clamp
                                fontSize: responsive
                                    .scale(0.04, 0.03)
                                    .clamp(14, 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(3).clamp(20, 30)),

                    // Botón enviar
                    SizedBox(
                      // ✅ CAMBIO: Añadido clamp
                      width: (responsive.fieldWidth * 0.7).clamp(250, 500),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: EdgeInsets.symmetric(
                            // ✅ CAMBIO: Añadido clamp
                            horizontal: responsive.wp(6).clamp(24, 36),
                            vertical: responsive.hp(1.5).clamp(12, 18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Lógica para enviar la tarea
                        },
                        child: Text(
                          "Entregar Tarea",
                          style: TextStyle(
                            color: AppTheme.backgroundColor,
                            // ✅ CAMBIO: Añadido clamp
                            fontSize: responsive
                                .scale(0.045, 0.03)
                                .clamp(15, 19),
                          ),
                        ),
                      ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(3).clamp(20, 30)),

                    // Retroalimentación (Esto debería ser condicional)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        // ✅ CAMBIO: Añadido clamp
                        radius: responsive.wp(5).clamp(20, 24),
                        child: Text(
                          "D",
                          style: TextStyle(
                            color: AppTheme.backgroundColor,
                            // ✅ CAMBIO: Añadido clamp
                            fontSize: responsive
                                .scale(0.04, 0.03)
                                .clamp(14, 17),
                          ),
                        ),
                      ),
                      title: Text(
                        "Retroalimentación del alumno (opcional)",
                        // ✅ CAMBIO: Añadido clamp
                        style: TextStyle(
                          fontSize: responsive.scale(0.04, 0.03).clamp(14, 17),
                        ),
                      ),
                      onTap: () {
                        // TODO: Abrir diálogo para escribir retroalimentación
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
