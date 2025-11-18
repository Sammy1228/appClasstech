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
    final actividadesProvider =
        Provider.of<ProviderActividades>(context, listen: false);
    final clasesProvider =
        Provider.of<ProviderClases>(context, listen: false);

    final tipoUsuario = authProvider.tipoUsuario;

    final nombreClase = titulo; // Usamos el título como nombre de clase

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
              icon: Icon(Icons.menu,
                  color: AppTheme.backgroundColor, size: responsive.dp(5)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          // SOLO PROFESOR → mostrar botón crear actividad
          if (tipoUsuario == "profesor")
            IconButton(
              icon: Icon(Icons.add_box,
                  color: AppTheme.backgroundColor, size: responsive.dp(5)),
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
              icon: Icon(Icons.delete,
                  color: AppTheme.backgroundColor, size: responsive.dp(5)),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("clases")
            .doc(claseId)
            .get(),
        builder: (context, snapshotClase) {
          if (!snapshotClase.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshotClase.data!.data() as Map<String, dynamic>;
          final profesorId = data["uidProfesor"];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("profesores")
                .doc(profesorId)
                .get(),
            builder: (context, snapshotProfesor) {
              if (!snapshotProfesor.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final profesor =
                  snapshotProfesor.data!.data() as Map<String, dynamic>?;

              final nombreProfesor = profesor?["nombre"] ?? "Desconocido";

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
                                  titulo,
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
  "Código de acceso: ${data['codigoAcceso'] ?? 'N/A'}",
  style: TextStyle(
    fontSize: responsive.dp(3.8),
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),
                                SizedBox(height: responsive.hp(1)),
                                Text(
                                  descripcion,
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
              );
            },
          );
        },
      ),
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
        // --- INICIO DE LÓGICA MODIFICADA ---
        final auth = Provider.of<Authentication>(context, listen: false);

        if (auth.tipoUsuario == 'profesor') {
          // Si es profesor, va a la pantalla de calificar
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CalificarActividadPage(actividadId: actividadDoc.id),
            ),
          );
        } else {
          // Si es alumno, va a la pantalla de detalle de actividad
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActividadPage(actividadId: actividadDoc.id),
            ),
          );
        }
        // --- FIN DE LÓGICA MODIFICADA ---
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
                color: Colors.blue,
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


  // DIÁLOGO PARA BORRAR CLASE
  void _showDeleteConfirmationDialog(
    BuildContext context,
    Responsive responsive,
    ProviderClases clasesProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Eliminar clase",
            style: TextStyle(fontSize: responsive.dp(4.5))),
        content: Text(
          "¿Seguro que deseas eliminar esta clase? Esta acción no se puede deshacer.",
          style: TextStyle(fontSize: responsive.dp(3.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar",
                style: TextStyle(fontSize: responsive.dp(3.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              await clasesProvider.eliminarClase(claseId);
              Navigator.pop(context);
              Navigator.pop(context); // salir a dashboard

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Clase eliminada con éxito."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Eliminar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.dp(3.5),
                )),
          ),
        ],
      ),
    );
  }
}