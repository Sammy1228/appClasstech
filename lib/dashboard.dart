import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/providers/provider_actividades.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/clase_card.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import 'mostrarclases.dart';
import 'Utils/responsive.dart';
import 'actividad.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final authProvider = Provider.of<Authentication>(context);
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);
    final actividadesProvider = Provider.of<ProviderActividades>(
      context,
      listen: false,
    );
    final tipoUsuario = authProvider.tipoUsuario;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        // ✅ CORREGIDO: Uso de headerFontSize para mejor adaptación
        title: Text(
          "Panel Principal",
          style: TextStyle(
            color: Colors.white,
            fontSize: r.headerFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (tipoUsuario == 'alumno')
            IconButton(
              onPressed: () => _mostrarDialogoUnirse(context, r),
              icon: const Icon(Icons.add, color: Colors.white),
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: StreamBuilder<QuerySnapshot>(
            stream: clasesProvider.obtenerClasesStream(),
            builder: (context, snapshotClases) {
              if (snapshotClases.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshotClases.hasError) {
                return Center(child: Text("Error: ${snapshotClases.error}"));
              }

              final nuevasClases = <Map<String, dynamic>>[];
              if (snapshotClases.hasData) {
                for (var doc in snapshotClases.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final estado = data['estado'] ?? 'activo';
                  final alumnos = data['alumnos'] ?? [];

                  bool incluir = false;
                  if (tipoUsuario == "alumno" &&
                      estado == "activo" &&
                      alumnos.contains(user?.uid))
                    incluir = true;
                  if (tipoUsuario == "profesor" &&
                      data['uidProfesor'] == user?.uid &&
                      estado == "activo")
                    incluir = true;

                  if (incluir) {
                    nuevasClases.add({
                      "id": doc.id,
                      "title": data['titulo'],
                      "desc": data['descripcion'],
                      ...data,
                    });
                  }
                }
              }

              final Set<String> titulosDeMisClases = nuevasClases
                  .map((c) => c["title"].toString())
                  .toSet();

              return SingleChildScrollView(
                padding: EdgeInsets.all(r.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nuevasClases.isNotEmpty)
                      SizedBox(
                        height: r.value(mobile: 190.0, desktop: 240.0),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: nuevasClases.length,
                          separatorBuilder: (_, __) => SizedBox(width: r.wp(3)),
                          itemBuilder: (context, index) {
                            final clase = nuevasClases[index];
                            final color =
                                AppTheme.claseColors[index %
                                    AppTheme.claseColors.length];
                            return SizedBox(
                              width: r.value(
                                mobile: r.wp(75),
                                tablet: 320.0,
                                desktop: 380.0,
                              ),
                              child: ClaseCard(
                                title: clase["title"],
                                description: clase["desc"],
                                color: color,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MostrarClasePage(
                                      claseId: clase["id"],
                                      titulo: clase["title"],
                                      descripcion: clase["desc"],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: r.hp(4)),
                          child: Text(
                            "No tienes clases activas.",
                            style: TextStyle(
                              fontSize: r.bodyFontSize,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: r.hp(4)),

                    Text(
                      "Próximas Actividades",
                      style: TextStyle(
                        fontSize: r.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: r.hp(2)),

                    StreamBuilder<QuerySnapshot>(
                      stream: actividadesProvider.obtenerActividadesStream(),
                      builder: (context, snapshotActs) {
                        if (!snapshotActs.hasData) return const SizedBox();
                        final acts = snapshotActs.data!.docs.where((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          return titulosDeMisClases.contains(d['clase']);
                        }).toList();

                        if (acts.isEmpty)
                          return const Text("No hay actividades pendientes.");

                        return Column(
                          children: acts.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            String f = "Sin fecha";
                            if (d['fechaEntrega'] is Timestamp) {
                              final dt = (d['fechaEntrega'] as Timestamp)
                                  .toDate();
                              f = "${dt.day}/${dt.month}/${dt.year}";
                            }
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ActividadPage(actividadId: doc.id),
                                ),
                              ),
                              child: _activityCard(
                                d['titulo'] ?? '',
                                f,
                                d['descripcion'] ?? '',
                                r,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _activityCard(String title, String fecha, String desc, Responsive r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(r.value(mobile: 16.0, desktop: 20.0)),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: r.bodyFontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            fecha,
            style: TextStyle(color: Colors.blue, fontSize: r.bodyFontSize - 2),
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            style: TextStyle(color: Colors.black54, fontSize: r.bodyFontSize),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoUnirse(BuildContext context, Responsive r) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Unirse a clase"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Código"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final res =
                  await Provider.of<ProviderClases>(
                    context,
                    listen: false,
                  ).unirseAClase(
                    controller.text.trim(),
                    FirebaseAuth.instance.currentUser!.uid,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res == 'ok' ? 'Unido correctamente' : res),
                  ),
                );
              }
            },
            child: const Text("Unirse"),
          ),
        ],
      ),
    );
  }
}
