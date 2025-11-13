import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/providers/provider_actividades.dart'; // Importado
import 'package:cloud_firestore/cloud_firestore.dart'; // Importado
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/clase_card.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import 'mostrarclases.dart';
import 'tituloact.dart';
import 'Utils/responsive.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Ya no se necesitan las listas de estado 'clases' y 'actividades' aquí.
  // Ya no se necesitan 'initState' ni 'cargarClases()'.

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    // Obtenemos los providers
    final authProvider = Provider.of<Authentication>(context);
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);
    final actividadesProvider = Provider.of<ProviderActividades>(
      context,
      listen: false,
    );

    // Obtenemos los datos del usuario
    final tipoUsuario = authProvider.tipoUsuario;
    final user = FirebaseAuth.instance.currentUser;

    // Tamaños de UI
    final double basePadding = r.hp(2).clamp(12, 24);
    final double cardSpacing = r.hp(1.5).clamp(10, 20);
    final double titleSize = r.dp(4.5).clamp(16, 22);
    final double textSize = r.dp(4).clamp(14, 20);

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
          // Solo los alumnos pueden unirse a clases
          if (tipoUsuario == 'alumno')
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
                              final provider = Provider.of<ProviderClases>(
                                context,
                                listen: false,
                              );

                              final uidAlumno =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (uidAlumno == null) return;

                              String resultado = await provider.unirseAClase(
                                codigo,
                                uidAlumno,
                              );

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
                                case "clase_inactiva":
                                  mensaje =
                                      "Esta clase está inactiva y no puedes unirte.";
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

                              Navigator.pop(context);
                              // Ya no se necesita cargarClases() manualmente
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
      body: StreamBuilder<QuerySnapshot>(
        // 1. Escuchamos el Stream de CLASES
        stream: clasesProvider.obtenerClasesStream(),
        builder: (context, snapshotClases) {
          // --- Manejo de estados de carga/error de CLASES ---
          if (snapshotClases.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotClases.hasError) {
            return Center(
              child: Text("Error al cargar clases: ${snapshotClases.error}"),
            );
          }
          if (!snapshotClases.hasData || snapshotClases.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No hay clases disponibles.",
                style: TextStyle(fontSize: textSize),
              ),
            );
          }

          // --- FILTRADO DE CLASES (Tu lógica original) ---
          final nuevasClases = <Map<String, dynamic>>[];
          final snapshot = snapshotClases.data!; // Datos de clases

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final estado = data['estado'] ?? 'activo';
            final List<dynamic> alumnos = data['alumnos'] ?? [];

            if (tipoUsuario == "alumno") {
              if (estado == "activo" && alumnos.contains(user?.uid)) {
                nuevasClases.add({
                  "id": doc.id,
                  "title": data['titulo'] ?? 'Sin título',
                  "desc": data['descripcion'] ?? 'Sin descripción',
                });
              }
            } else if (tipoUsuario == "profesor") {
              if (data['uidProfesor'] == user?.uid && estado == "activo") {
                nuevasClases.add({
                  "id": doc.id,
                  "title": data['titulo'] ?? 'Sin título',
                  "desc": data['descripcion'] ?? 'Sin descripción',
                });
              }
            }
          }

          // Obtenemos los títulos de las clases filtradas para filtrar actividades
          final Set<String> titulosDeMisClases = nuevasClases
              .map((clase) => clase["title"].toString())
              .toSet();

          // --- Construcción de la UI ---
          return SingleChildScrollView(
            padding: EdgeInsets.all(basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECCIÓN DE CLASES (Horizontal) ---
                if (nuevasClases.isNotEmpty)
                  SizedBox(
                    height: r.hp(22).clamp(150, 220),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: nuevasClases.length,
                      separatorBuilder: (_, __) => SizedBox(width: cardSpacing),
                      itemBuilder: (context, index) {
                        final clase = nuevasClases[index];
                        final color = AppTheme
                            .claseColors[index % AppTheme.claseColors.length];
                        return SizedBox(
                          width: r.wp(40).clamp(140, 180),
                          child: ClaseCard(
                            title: clase["title"],
                            description: clase["desc"],
                            color: color,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MostrarClasePage(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: r.hp(4)),
                      child: Text(
                        "No hay clases disponibles",
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: r.hp(2).clamp(12, 24)),

                // --- SECCIÓN DE ACTIVIDADES (Vertical) ---
                Text(
                  "Próximas Actividades",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: r.hp(1.5).clamp(10, 20)),

                // 2. Escuchamos el Stream de ACTIVIDADES (Anidado)
                StreamBuilder<QuerySnapshot>(
                  stream: actividadesProvider.obtenerActividadesStream(),
                  builder: (context, snapshotActividades) {
                    // --- Manejo de estados de carga/error de ACTIVIDADES ---
                    if (snapshotActividades.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                      return Center(
                        child: Text(
                          "No hay actividades.",
                          style: TextStyle(
                            fontSize: textSize,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }

                    // --- FILTRADO DE ACTIVIDADES ---
                    final nuevasActividades = <Map<String, dynamic>>[];
                    final snapshot =
                        snapshotActividades.data!; // Datos de actividades

                    for (var doc in snapshot.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String claseDeActividad = data['clase'] ?? '';

                      // ⭐️ Filtramos usando los títulos de clases del Stream exterior
                      if (titulosDeMisClases.contains(claseDeActividad)) {
                        String fechaFormateada = "Sin fecha de entrega";
                        if (data['fechaEntrega'] != null &&
                            data['fechaEntrega'] is Timestamp) {
                          final fecha = (data['fechaEntrega'] as Timestamp)
                              .toDate();
                          fechaFormateada =
                              "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}";
                        }
                        nuevasActividades.add({
                          "id": doc.id,
                          "title": data['titulo'] ?? 'Sin título',
                          "desc": data['descripcion'] ?? 'Sin descripción',
                          "fecha": fechaFormateada,
                        });
                      }
                    }

                    // --- Renderizado de ACTIVIDADES ---
                    if (nuevasActividades.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: r.hp(4)),
                          child: Text(
                            "No hay actividades para tus clases.",
                            style: TextStyle(
                              fontSize: textSize,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: nuevasActividades.map((actividad) {
                        return _activityCard(
                          context,
                          actividad["title"]!,
                          actividad["fecha"]!,
                          actividad["desc"]!,
                          r,
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
                Icon(Icons.edit, color: AppTheme.primaryColor, size: iconSize),
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
              style: TextStyle(color: Colors.black54, fontSize: textSize - 1),
            ),
          ],
        ),
      ),
    );
  }
}
