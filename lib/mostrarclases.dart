import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'crearactividad.dart';

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

                    SizedBox(height: responsive.hp(2)),

                    Text(
                      "Actividades",
                      style: TextStyle(
                        fontSize: responsive.dp(5),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    SizedBox(height: responsive.hp(1.5)),

                    // LISTADO DE ACTIVIDADES POR STREAM
                    StreamBuilder<QuerySnapshot>(
                      stream: actividadesProvider
                          .obtenerActividadesStreamPorClase(titulo),
                      builder: (context, snapshotAct) {
                        if (!snapshotAct.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshotAct.data!.docs;

                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No hay actividades creadas.",
                              style: TextStyle(
                                fontSize: responsive.dp(3.6),
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final fecha = data["fechaEntrega"] != null
                                ? (data["fechaEntrega"] as Timestamp)
                                    .toDate()
                                : null;

                            return _buildActivityCard(
                              responsive,
                              data["titulo"] ?? "Sin título",
                              fecha != null
                                  ? "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}"
                                  : "Sin fecha",
                              data["descripcion"] ??
                                  "Sin descripción de actividad",
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
    );
  }

  // TARJETA DE ACTIVIDAD
  Widget _buildActivityCard(
    Responsive responsive,
    String title,
    String fecha,
    String descripcion,
  ) {
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
                title,
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
            fecha,
            style: TextStyle(
                color: Colors.black54, fontSize: responsive.dp(3.2)),
          ),
          SizedBox(height: responsive.hp(0.8)),
          Text(
            descripcion,
            style:
                TextStyle(color: Colors.black54, fontSize: responsive.dp(3.3)),
          ),
        ],
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