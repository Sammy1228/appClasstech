import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'actividad.dart'; // Importado

class MostrarClasePage extends StatelessWidget {
  final String claseId;

  const MostrarClasePage({super.key, required this.claseId});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);

    return StreamBuilder<DocumentSnapshot>(
      // 1. OBTENEMOS EL STREAM DE LA CLASE ESPECÍFICA
      stream: clasesProvider.obtenerClaseStreamPorId(claseId),
      builder: (context, snapshotClase) {
        // --- Manejo de estados de carga/error de CLASE ---
        if (snapshotClase.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshotClase.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Text("Error al cargar la clase: ${snapshotClase.error}"),
            ),
          );
        }
        if (!snapshotClase.hasData || !snapshotClase.data!.exists) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: Text("Esta clase no existe.")),
          );
        }

        // --- DATOS DE LA CLASE ---
        final claseData = snapshotClase.data!.data() as Map<String, dynamic>;
        final String nombreClase = claseData['titulo'] ?? "Sin Título";

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            title: Text(
              nombreClase, // 👈 DATO REAL
              style: TextStyle(
                color: AppTheme.backgroundColor,
                // ✅ CAMBIO: Añadido clamp
                fontSize: responsive.dp(5).clamp(18, 22),
              ),
            ),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppTheme.backgroundColor,
                    // ✅ CAMBIO: Añadido clamp
                    size: responsive.dp(5.5).clamp(24, 28),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppTheme.backgroundColor,
                  // ✅ CAMBIO: Añadido clamp
                  size: responsive.dp(5.5).clamp(24, 28),
                ),
                onPressed: () {
                  _showDeleteConfirmationDialog(
                    context,
                    responsive,
                    claseId,
                  ); // Se pasa el ID
                },
              ),
            ],
          ),
          drawer: const CustomDrawer(),
          // ✅ CAMBIO: Añadido Center y ConstrainedBox
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900), // Ancho de contenido
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Caja amarilla con información de la clase
                    Container(
                      // ✅ CAMBIO: Añadido clamp
                      padding: EdgeInsets.all(responsive.dp(4).clamp(16, 24)),
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
                                  claseData['titulo'] ??
                                      'Sin Título', // 👈 DATO REAL
                                  style: TextStyle(
                                    // ✅ CAMBIO: Añadido clamp
                                    fontSize: responsive.dp(4.8).clamp(18, 24),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ✅ CAMBIO: Añadido clamp
                                SizedBox(height: responsive.hp(1).clamp(8, 12)),
                                Text(
                                  claseData['nombreProfesor'] ??
                                      'Sin Docente', // 👈 DATO REAL
                                  style: TextStyle(
                                    // ✅ CAMBIO: Añadido clamp
                                    fontSize: responsive.dp(3.8).clamp(15, 19),
                                    color: Colors.black54,
                                  ),
                                ),
                                // ✅ CAMBIO: Añadido clamp
                                SizedBox(height: responsive.hp(1).clamp(8, 12)),
                                Text(
                                  claseData['descripcion'] ??
                                      'Sin descripción.', // 👈 DATO REAL
                                  style: AppTheme.bodyText.copyWith(
                                    // ✅ CAMBIO: Añadido clamp
                                    fontSize: responsive.dp(3.5).clamp(14, 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ✅ CAMBIO: Añadido clamp
                          SizedBox(width: responsive.wp(3).clamp(10, 16)),
                          Image.asset(
                            'assets/images/logo.png',
                            // ✅ CAMBIO: Añadido clamp
                            width: responsive.wp(18).clamp(60, 80),
                            height: responsive.wp(18).clamp(60, 80),
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.school,
                              // ✅ CAMBIO: Añadido clamp
                              size: responsive.wp(18).clamp(60, 80),
                            ), // Placeholder si la imagen falla
                          ),
                        ],
                      ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Título de sección
                    Text(
                      "Actividades",
                      style: TextStyle(
                        // ✅ CAMBIO: Añadido clamp
                        fontSize: responsive.dp(5).clamp(18, 24),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    // ✅ CAMBIO: Añadido clamp
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // 2. OBTENEMOS EL STREAM DE ACTIVIDADES FILTRADAS
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          Provider.of<ProviderActividades>(
                            context,
                            listen: false,
                          ).obtenerActividadesStreamPorClase(
                            nombreClase,
                          ), // 👈 FILTRO
                      builder: (context, snapshotActividades) {
                        // --- Manejo de estados de carga/error de ACTIVIDADES ---
                        if (snapshotActividades.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshotActividades.hasError) {
                          return Center(
                            child: Text(
                              "Error al cargar actividades: ${snapshotActividades.error}",
                            ),
                          );
                        }
                        if (!snapshotActividades.hasData ||
                            snapshotActividades.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No hay actividades para esta clase."),
                          );
                        }

                        // --- DATOS DE ACTIVIDADES ---
                        final actividadesDocs = snapshotActividades.data!.docs;

                        return Column(
                          children: actividadesDocs.map((doc) {
                            // Pasamos el DocumentSnapshot completo
                            return _buildActivityCard(context, responsive, doc);
                          }).toList(),
                        );
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

  // Tarjeta de actividad (Modificada para aceptar datos)
  // ✅ CAMBIO: Aplicado clamp() a todos los valores internos
  Widget _buildActivityCard(
    BuildContext context,
    Responsive responsive,
    DocumentSnapshot actividadDoc,
  ) {
    final actividadData = actividadDoc.data() as Map<String, dynamic>;

    // Formateo de fecha
    String fechaFormateada = "Sin fecha de entrega";
    if (actividadData['fechaEntrega'] != null &&
        actividadData['fechaEntrega'] is Timestamp) {
      final fecha = (actividadData['fechaEntrega'] as Timestamp).toDate();
      fechaFormateada = "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}";
    }

    return GestureDetector(
      // 👈 Añadido para navegar
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActividadPage(actividadId: actividadDoc.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: responsive.hp(1.5).clamp(10, 15)),
        padding: EdgeInsets.all(responsive.dp(3.5).clamp(14, 20)),
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
                Icon(
                  Icons.edit,
                  color: AppTheme.primaryColor,
                  size: responsive.dp(5).clamp(22, 26),
                ),
                SizedBox(width: responsive.wp(2).clamp(8, 12)),
                Flexible(
                  // Añadido para evitar overflow
                  child: Text(
                    actividadData['titulo'] ?? 'Sin Título', // 👈 DATO REAL
                    style: TextStyle(
                      fontSize: responsive.dp(4).clamp(16, 19),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.hp(0.5).clamp(4, 6)),
            Text(
              fechaFormateada, // 👈 DATO REAL
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsive.dp(3).clamp(12, 14),
              ),
            ),
            SizedBox(height: responsive.hp(0.8).clamp(6, 10)),
            Text(
              actividadData['descripcion'] ?? 'Sin descripción', // 👈 DATO REAL
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsive.dp(3.3).clamp(13, 16),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo de confirmación
  // ✅ CAMBIO: Aplicado clamp() a fuentes
  void _showDeleteConfirmationDialog(
    BuildContext context,
    Responsive responsive,
    String claseId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Eliminar clase",
            style: TextStyle(fontSize: responsive.dp(4.5).clamp(18, 22)),
          ),
          content: Text(
            "¿Estás seguro de que quieres eliminar esta clase? Esta acción no se puede deshacer.",
            style: TextStyle(fontSize: responsive.dp(3.4).clamp(14, 17)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancelar",
                style: TextStyle(fontSize: responsive.dp(3.5).clamp(14, 17)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Añadir lógica para eliminar la clase
                // Por ejemplo:
                // Provider.of<ProviderClases>(context, listen: false).eliminarClase(claseId);

                Navigator.pop(context); // Cierra el diálogo
                Navigator.pop(context); // Regresa al dashboard

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
                  fontSize: responsive.dp(3.5).clamp(14, 17),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
