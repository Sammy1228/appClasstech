import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_entregas.dart';
import 'package:appzacek/ver_entrega_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class CalificarActividadPage extends StatelessWidget {
  final String actividadId;
  const CalificarActividadPage({super.key, required this.actividadId});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final entregasProvider = Provider.of<ProviderEntregas>(
      context,
      listen: false,
    );
    final actividadesProvider = Provider.of<ProviderActividades>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        // Título dinámico de la actividad
        title: StreamBuilder<DocumentSnapshot>(
          stream: actividadesProvider.obtenerActividadStreamPorId(actividadId),
          builder: (context, snapshot) {
            final titulo =
                (snapshot.data?.data() as Map<String, dynamic>?)?['titulo'] ??
                'Calificar';
            return Text(
              titulo,
              style: TextStyle(
                color: AppTheme.backgroundColor,
                fontSize: responsive.dp(5).clamp(18, 22),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream que obtiene TODAS las entregas de esta actividad
        stream: entregasProvider.getEntregasPorActividadStream(actividadId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar la lista de entregas."),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aún no hay entregas para esta actividad."),
            );
          }

          final entregas = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(responsive.dp(3).clamp(12, 16)),
            itemCount: entregas.length,
            itemBuilder: (context, index) {
              final entregaDoc = entregas[index];
              final data = entregaDoc.data() as Map<String, dynamic>;

              final nombreAlumno = data['nombreAlumno'] ?? 'Sin nombre';
              final estado = data['estado'] ?? 'entregado';
              final calificacion = data['calificacion']; // Puede ser null

              IconData estadoIcon;
              Color estadoColor;

              switch (estado) {
                case 'calificado':
                  estadoIcon = Icons.check_circle;
                  estadoColor = Colors.green;
                  break;
                case 'entregado':
                default:
                  estadoIcon = Icons.hourglass_top;
                  estadoColor = Colors.orange;
                  break;
              }

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: responsive.hp(1).clamp(8, 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: estadoColor,
                    child: Icon(estadoIcon, color: Colors.white),
                  ),
                  title: Text(
                    nombreAlumno,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    estado == 'calificado'
                        ? 'Calificación: $calificacion / 100'
                        : 'Pendiente de calificar',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navegar a la pantalla de detalle para calificar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerEntregaPage(
                          entregaId: entregaDoc.id, // Pasa el ID de la entrega
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
