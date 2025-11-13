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

class ClasesScreen extends StatefulWidget {
  const ClasesScreen({super.key});

  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
  List<Map<String, dynamic>> clases = [];
  bool mostrarInactivas = false; // ✅ Control para el profesor

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    final tipoUsuario =
        Provider.of<Authentication>(context, listen: false).tipoUsuario;
    final provider = Provider.of<ProviderClases>(context, listen: false);

    try {
      final snapshot = await provider.obtenerClases();
      final nuevasClases = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> alumnos = data['alumnos'] ?? [];
        final estado = data['estado'] ?? 'activo';

        if (tipoUsuario == "alumno") {
          // ✅ Los alumnos solo ven clases activas
          if (estado == "activo" && alumnos.contains(user?.uid)) {
            nuevasClases.add({
              "id": doc.id,
              "title": data['titulo'] ?? 'Sin título',
              "desc": data['descripcion'] ?? 'Sin descripción',
              "color": 0xFFBBDEFB, // azul
              "estado": estado,
            });
          }
        } else if (tipoUsuario == "profesor") {
          // ✅ El profesor ve sus clases, puede filtrar por estado
          if (data['uidProfesor'] == user?.uid) {
            if (mostrarInactivas || estado == "activo") {
              nuevasClases.add({
                "id": doc.id,
                "title": data['titulo'] ?? 'Sin título',
                "desc": data['descripcion'] ?? 'Sin descripción',
                "color": estado == "activo" ? 0xFFC8E6C9 : 0xFFBDBDBD, // gris si inactiva
                "estado": estado,
              });
            }
          }
        }
      }

      setState(() {
        clases = nuevasClases;
      });

      print("✅ Clases cargadas para $tipoUsuario: $clases");
    } catch (e) {
      print("❌ Error al cargar clases: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isPortrait = responsive.isPortrait;
    final tipoUsuario = Provider.of<Authentication>(context).tipoUsuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clases", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (tipoUsuario == 'profesor')
            Row(
              children: [
                Text(
                  mostrarInactivas ? "Ocultar clases inactivas" : "Mostrar clases inactivas",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Switch(
                  value: mostrarInactivas,
                  onChanged: (value) {
                    setState(() => mostrarInactivas = value);
                    cargarDatos();
                  },
                  activeColor: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Seleccionar Opción"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _dialogButton(
                                context,
                                responsive,
                                "Crear Clase",
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CrearClasePage(),
                                  ),
                                ),
                              ),
                              SizedBox(height: responsive.hp(1)),
                              _dialogButton(
                                context,
                                responsive,
                                "Crear Actividad",
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CrearActividadPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(responsive.wp(3)),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isPortrait ? 2 : 3,
            crossAxisSpacing: responsive.wp(3),
            mainAxisSpacing: responsive.hp(2),
            childAspectRatio: isPortrait ? 1 : 1.2,
          ),
          itemCount: clases.length,
          itemBuilder: (context, index) {
            final clase = clases[index];
            return _claseCard(clase, tipoUsuario);
          },
        ),
      ),
    );
  }

  Widget _claseCard(Map<String, dynamic> clase, String tipoUsuario) {
    final provider = Provider.of<ProviderClases>(context, listen: false);

    return Card(
      color: Color(clase["color"]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(clase["title"],
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(clase["desc"], style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (tipoUsuario == "profesor")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
    clase["estado"] == "activo"
        ? "Desactivar clase" // Si está 'activo', la acción será 'Desactivar'
        : "Volver a activar clase", // Si está 'inactivo', la acción será 'Volver a activar'
  ),
                  Switch(
                    value: clase["estado"] == "activo",
                    onChanged: (value) async {
                      final nuevoEstado = value ? "activo" : "inactivo";
                      await provider.cambiarEstadoClase(clase["id"], nuevoEstado);
                      cargarDatos();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dialogButton(
    BuildContext context,
    Responsive responsive,
    String text,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: responsive.fieldWidth * 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.backgroundColor,
          padding: EdgeInsets.symmetric(vertical: responsive.hp(1.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: responsive.scale(0.04, 0.03))),
      ),
    );
  }
}
