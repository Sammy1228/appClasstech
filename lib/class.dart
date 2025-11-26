import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'crearclase.dart';
import 'crearactividad.dart';
import '../widgets/clase_card.dart';
import 'mostrarclases.dart';

class ClasesScreen extends StatefulWidget {
  const ClasesScreen({super.key});
  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
  List<Map<String, dynamic>> clases = [];
  bool mostrarInactivas = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    final tipoUsuario = Provider.of<Authentication>(
      context,
      listen: false,
    ).tipoUsuario;
    final provider = Provider.of<ProviderClases>(context, listen: false);

    try {
      final snapshot = await provider.obtenerClases();
      final nuevas = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final alumnos = data['alumnos'] ?? [];
        final estado = data['estado'] ?? 'activo';

        if (tipoUsuario == "alumno") {
          if (estado == "activo" && alumnos.contains(user?.uid)) {
            nuevas.add({
              "id": doc.id,
              "title": data['titulo'],
              "desc": data['descripcion'],
              "estado": estado,
            });
          }
        } else if (tipoUsuario == "profesor" &&
            data['uidProfesor'] == user?.uid) {
          if (mostrarInactivas || estado == "activo") {
            nuevas.add({
              "id": doc.id,
              "title": data['titulo'],
              "desc": data['descripcion'],
              "estado": estado,
            });
          }
        }
      }
      setState(() => clases = nuevas);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final tipoUsuario = Provider.of<Authentication>(context).tipoUsuario;

    return Scaffold(
      appBar: AppBar(
        // ✅ CORREGIDO: Fuente adaptable
        title: Text(
          "Clases",
          style: TextStyle(
            color: Colors.white,
            fontSize: r.headerFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (tipoUsuario == 'profesor') ...[
            Switch(
              value: mostrarInactivas,
              onChanged: (v) {
                setState(() => mostrarInactivas = v);
                cargarDatos();
              },
              activeColor: Colors.white,
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _mostrarDialogo(context, r),
            ),
          ],
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(r.horizontalPadding),
            child: clases.isEmpty
                ? const Center(child: Text("No hay clases disponibles"))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.1,
                        ),
                    itemCount: clases.length,
                    itemBuilder: (context, index) {
                      final clase = clases[index];
                      final color = AppTheme
                          .claseColors[index % AppTheme.claseColors.length];
                      return ClaseCard(
                        title: clase["title"] ?? '',
                        description: clase["desc"] ?? '',
                        color: color,
                        isInactive: clase["estado"] == "inactivo",
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
                        footerWidget: tipoUsuario == 'profesor'
                            ? _footerSwitch(clase)
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _footerSwitch(Map<String, dynamic> clase) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          clase["estado"] == "activo" ? "Desactivar" : "Activar",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Switch(
          value: clase["estado"] == "activo",
          onChanged: (v) async {
            await Provider.of<ProviderClases>(
              context,
              listen: false,
            ).cambiarEstadoClase(clase["id"], v ? "activo" : "inactivo");
            cargarDatos();
          },
          activeColor: Colors.white,
        ),
      ],
    );
  }

  void _mostrarDialogo(BuildContext context, Responsive r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Opciones"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Crear Clase"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearClasePage()),
                );
              },
            ),
            ListTile(
              title: const Text("Crear Actividad"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearActividadPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
