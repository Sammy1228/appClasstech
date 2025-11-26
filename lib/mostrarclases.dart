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
        // ✅ CORREGIDO: Fuente adaptable usando headerFontSize
        title: Text(
          titulo,
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: responsive.headerFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          // SOLO PROFESOR → mostrar botón crear actividad
          if (tipoUsuario == "profesor")
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: "Crear Actividad",
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
              icon: const Icon(Icons.delete),
              tooltip: "Eliminar Clase",
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("clases")
                .doc(claseId)
                .snapshots(),
            builder: (context, snapshotClase) {
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
              final String profesorId = data["uidProfesor"] ?? "";
              final tituloReal = data['titulo'] ?? titulo;
              final descripcionReal = data['descripcion'] ?? descripcion;
              final codigoAcceso = data['codigoAcceso'] ?? 'N/A';

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
                          padding: EdgeInsets.all(
                            responsive.value(mobile: 16.0, desktop: 24.0),
                          ),
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
                                        fontSize: responsive.titleFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: responsive.hp(1)),
                                    Text(
                                      "Profesor: $nombreProfesor",
                                      style: TextStyle(
                                        fontSize: responsive.bodyFontSize,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: responsive.hp(1)),
                                    SelectableText(
                                      "Código de acceso: $codigoAcceso",
                                      style: TextStyle(
                                        fontSize: responsive.bodyFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: responsive.hp(1)),
                                    Text(
                                      descripcionReal,
                                      style: AppTheme.bodyText.copyWith(
                                        fontSize: responsive.bodyFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: responsive.wp(3)),
                              Image.asset(
                                'assets/images/logo.png',
                                width: responsive.value(
                                  mobile: 60.0,
                                  desktop: 100.0,
                                ),
                                height: responsive.value(
                                  mobile: 60.0,
                                  desktop: 100.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // Título de sección
                        Text(
                          "Actividades",
                          style: TextStyle(
                            fontSize: responsive.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: responsive.hp(2)),

                        // LISTA DE ACTIVIDADES
                        StreamBuilder<QuerySnapshot>(
                          stream: Provider.of<ProviderActividades>(
                            context,
                            listen: false,
                          ).obtenerActividadesStreamPorClase(nombreClase),
                          builder: (context, snapshotActividades) {
                            if (snapshotActividades.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshotActividades.hasData ||
                                snapshotActividades.data!.docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No hay actividades para esta clase.",
                                ),
                              );
                            }

                            final actividadesDocs =
                                snapshotActividades.data!.docs;

                            return Column(
                              children: actividadesDocs.map((doc) {
                                return _buildActivityCard(
                                  context,
                                  responsive,
                                  doc,
                                );
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
        ),
      ),
    );
  }

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
        margin: const EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(responsive.value(mobile: 16.0, desktop: 20.0)),
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
                  size: responsive.value(mobile: 24.0, desktop: 28.0),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    actividadData['titulo'] ?? 'Sin Título',
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              fechaFormateada,
              style: TextStyle(
                color: Colors.blue,
                fontSize: responsive.bodyFontSize - 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              actividadData['descripcion'] ?? 'Sin descripción',
              style: TextStyle(
                color: Colors.black54,
                fontSize: responsive.bodyFontSize,
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
        title: const Text("Eliminar clase"),
        content: const Text(
          "¿Seguro que deseas eliminar esta clase? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await clasesProvider.eliminarClase(claseId);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Clase eliminada con éxito."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
