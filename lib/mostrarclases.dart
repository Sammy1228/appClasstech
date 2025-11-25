import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appzacek/calificar_actividad_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'crearactividad.dart';
import 'actividad.dart';

class MostrarClasePage extends StatelessWidget {
  final String claseId;
  final String titulo;
  final String descripcion;

  const MostrarClasePage({
    super.key,
    required this.claseId,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final authProvider = Provider.of<Authentication>(context, listen: false);
    final tipoUsuario = authProvider.tipoUsuario;
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);

    // Usamos el título que viene por parámetro como fallback inicial
    final nombreClase = titulo;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          titulo,
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: responsive.dp(4.5),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: AppTheme.backgroundColor,
                size: responsive.dp(5),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          // SOLO PROFESOR → mostrar botón crear actividad
          if (tipoUsuario == "profesor")
            IconButton(
              icon: Icon(
                Icons.add_box,
                color: AppTheme.backgroundColor,
                size: responsive.dp(5),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CrearActividadPage(
                      claseId: claseId,
                      tituloClase: titulo,
                    ),
                  ),
                );
              },
            ),

          // SOLO PROFESOR → botón eliminar clase
          if (tipoUsuario == "profesor")
            IconButton(
              icon: Icon(
                Icons.delete,
                color: AppTheme.backgroundColor,
                size: responsive.dp(5),
              ),
              onPressed: () {
                _showDeleteConfirmationDialog(
                  context,
                  responsive,
                  clasesProvider,
                );
              },
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      // ✅ CORRECCIÓN 1: Usamos StreamBuilder para ver cambios en tiempo real
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("clases")
            .doc(claseId)
            .snapshots(), // .snapshots() escucha cambios en vivo
        builder: (context, snapshotClase) {
          // Manejo de errores y carga
          if (snapshotClase.hasError) {
            return Center(child: Text("Error: ${snapshotClase.error}"));
          }

          if (snapshotClase.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshotClase.hasData || !snapshotClase.data!.exists) {
            return const Center(
              child: Text("La clase no existe o fue eliminada."),
            );
          }

          final data = snapshotClase.data!.data() as Map<String, dynamic>;

          // ✅ CORRECCIÓN 2: Validación del ID del profesor para evitar errores nulos
          final String profesorId = data["uidProfesor"] ?? "";

          // Actualizamos los datos visuales con lo que viene de la base de datos (tiempo real)
          final tituloReal = data['titulo'] ?? titulo;
          final descripcionReal = data['descripcion'] ?? descripcion;
          final codigoAcceso = data['codigoAcceso'] ?? 'N/A';

          // Builder anidado para obtener el nombre del profesor
          // Nota: El profesor rara vez cambia, por lo que FutureBuilder aquí es aceptable,
          // pero agregamos validación para que no se quede cargando si no hay ID.
          return FutureBuilder<DocumentSnapshot>(
            future: profesorId.isNotEmpty
                ? FirebaseFirestore.instance
                      .collection("profesores")
                      .doc(profesorId)
                      .get()
                : null,
            builder: (context, snapshotProfesor) {
              String nombreProfesor = "Cargando...";

              if (profesorId.isEmpty) {
                nombreProfesor = "Sin profesor asignado";
              } else if (snapshotProfesor.hasData &&
                  snapshotProfesor.data != null) {
                final profData =
                    snapshotProfesor.data!.data() as Map<String, dynamic>?;
                nombreProfesor = profData?["nombre"] ?? "Desconocido";
              } else if (snapshotProfesor.connectionState ==
                  ConnectionState.done) {
                nombreProfesor = "Profesor no encontrado";
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // INFORMACIÓN DE LA CLASE
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
                                  tituloReal,
                                  style: TextStyle(
                                    fontSize: responsive.dp(4.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: responsive.hp(1)),
                                Text(
                                  "Profesor: $nombreProfesor",
                                  style: TextStyle(
                                    fontSize: responsive.dp(3.8),
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: responsive.hp(1)),
                                Text(
                                  "Código de acceso: $codigoAcceso",
                                  style: TextStyle(
                                    fontSize: responsive.dp(3.8),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: responsive.hp(1)),
                                Text(
                                  descripcionReal,
                                  style: AppTheme.bodyText.copyWith(
                                    fontSize: responsive.dp(3.4),
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

                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Título de sección
                    Text(
                      "Actividades",
                      style: TextStyle(
                        fontSize: responsive.dp(5).clamp(18, 24),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // 2. OBTENEMOS EL STREAM DE ACTIVIDADES FILTRADAS
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          Provider.of<ProviderActividades>(
                            context,
                            listen: false,
                          ).obtenerActividadesStreamPorClase(
                            nombreClase, // IMPORTANTE: Asegúrate que tus actividades guarden el nombre de la clase o el ID
                          ),
                      builder: (context, snapshotActividades) {
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
                            return _buildActivityCard(context, responsive, doc);
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Tarjeta de actividad
  Widget _buildActivityCard(
    BuildContext context,
    Responsive responsive,
    DocumentSnapshot actividadDoc,
  ) {
    final actividadData = actividadDoc.data() as Map<String, dynamic>;

    String fechaFormateada = "Sin fecha de entrega";
    if (actividadData['fechaEntrega'] != null &&
        actividadData['fechaEntrega'] is Timestamp) {
      final fecha = (actividadData['fechaEntrega'] as Timestamp).toDate();
      fechaFormateada = "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}";
    }

    return GestureDetector(
      onTap: () {
        final auth = Provider.of<Authentication>(context, listen: false);

        if (auth.tipoUsuario == 'profesor') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CalificarActividadPage(actividadId: actividadDoc.id),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActividadPage(actividadId: actividadDoc.id),
            ),
          );
        }
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
                  child: Text(
                    actividadData['titulo'] ?? 'Sin Título',
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
              fechaFormateada,
              style: TextStyle(
                color: Colors.blue,
                fontSize: responsive.dp(3).clamp(12, 14),
              ),
            ),
            SizedBox(height: responsive.hp(0.8).clamp(6, 10)),
            Text(
              actividadData['descripcion'] ?? 'Sin descripción',
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Responsive responsive,
    ProviderClases clasesProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Eliminar clase",
          style: TextStyle(fontSize: responsive.dp(4.5)),
        ),
        content: Text(
          "¿Seguro que deseas eliminar esta clase? Esta acción no se puede deshacer.",
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
            onPressed: () async {
              await clasesProvider.eliminarClase(claseId);
              Navigator.pop(context);
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
      ),
    );
  }
}
