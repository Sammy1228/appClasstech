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
                fontSize: responsive.dp(5),
              ),
            ),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppTheme.backgroundColor,
                    size: responsive.dp(5.5),
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
                  size: responsive.dp(5.5),
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
                              claseData['titulo'] ??
                                  'Sin Título', // 👈 DATO REAL
                              style: TextStyle(
                                fontSize: responsive.dp(4.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: responsive.hp(1)),
                            Text(
                              claseData['nombreProfesor'] ??
                                  'Sin Docente', // 👈 DATO REAL
                              style: TextStyle(
                                fontSize: responsive.dp(3.8),
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: responsive.hp(1)),
                            Text(
                              claseData['descripcion'] ??
                                  'Sin descripción.', // 👈 DATO REAL
                              style: AppTheme.bodyText.copyWith(
                                fontSize: responsive.dp(3.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: responsive.wp(3)),
                      Image.asset(
                        'assets/images/logo.png', // Asegúrate que esta ruta sea correcta
                        width: responsive.wp(18),
                        height: responsive.wp(18),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.school,
                          size: responsive.wp(18),
                        ), // Placeholder si la imagen falla
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

                // 2. OBTENEMOS EL STREAM DE ACTIVIDADES FILTRADAS
                StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<ProviderActividades>(
                    context,
                    listen: false,
                  ).obtenerActividadesStreamPorClase(nombreClase), // 👈 FILTRO
                  builder: (context, snapshotActividades) {
                    // --- Manejo de estados de carga/error de ACTIVIDADES ---
                    if (snapshotActividades.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
        );
      },
    );
  }

  // Tarjeta de actividad (Modificada para aceptar datos)
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
                Icon(
                  Icons.edit,
                  color: AppTheme.primaryColor,
                  size: responsive.dp(5),
                ),
                SizedBox(width: responsive.wp(2)),
                Flexible(
                  // Añadido para evitar overflow
                  child: Text(
                    actividadData['titulo'] ?? 'Sin Título', // 👈 DATO REAL
                    style: TextStyle(
                      fontSize: responsive.dp(4),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.hp(0.5)),
            Text(
              fechaFormateada, // 👈 DATO REAL
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsive.dp(3),
              ),
            ),
            SizedBox(height: responsive.hp(0.8)),
            Text(
              actividadData['descripcion'] ?? 'Sin descripción', // 👈 DATO REAL
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsive.dp(3.3),
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
