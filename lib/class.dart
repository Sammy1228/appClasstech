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
  bool mostrarInactivas = false; // ✅ Control para el profesor

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
                "color": estado == "activo"
                    ? 0xFFC8E6C9
                    : 0xFFBDBDBD, // gris si inactiva
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
                  mostrarInactivas
                      ? "Ocultar clases inactivas"
                      : "Mostrar clases inactivas",
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
        padding: EdgeInsets.all(responsive.wp(3).clamp(12, 20)),
        child: GridView.builder(
          // ✅ CAMBIO: De FixedCrossAxisCount a MaxCrossAxisExtent
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400, // Ancho máx de cada tarjeta
            crossAxisSpacing: responsive.wp(3).clamp(12, 20),
            mainAxisSpacing: responsive.hp(2).clamp(12, 20),
            childAspectRatio: isPortrait ? 1 : 1.2,
          ),
          itemCount: clases.length,
          itemBuilder: (context, index) {
            final clase = clases[index];
            // ✅ CAMBIO: Pasamos 'responsive' a _claseCard
           final color = AppTheme.claseColors[index % AppTheme.claseColors.length];

return ClaseCard(
  title: clase["title"],
  description: clase["desc"],
  color: color,
  isInactive: clase["estado"] == "inactivo", // 👈 NUEVO
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MostrarClasePage(
          claseId: clase["id"],
          titulo: clase["title"],
          descripcion: clase["desc"],
        ),
      ),
    );
  },
  footerWidget: tipoUsuario == "profesor"
      ? _footerSwitch(clase, responsive)
      : null,
);
          },
        ),
      ),
    );
  }

Widget _footerSwitch(Map<String, dynamic> clase, Responsive r) {
  final provider = Provider.of<ProviderClases>(context, listen: false);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        clase["estado"] == "activo"
            ? "Desactivar clase"
            : "Activar clase",
        style: TextStyle(
          color: Colors.white,
          fontSize: r.dp(3.8).clamp(14, 16),
        ),
      ),
      Switch(
        value: clase["estado"] == "activo",
        onChanged: (value) async {
          final nuevoEstado = value ? "activo" : "inactivo";
          await provider.cambiarEstadoClase(clase["id"], nuevoEstado);
          cargarDatos(); // recargar lista
        },
        activeColor: Colors.white,
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.black26,
      ),
    ],
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
        // ✅ CAMBIO: Añadido clamp
        child: Text(
          text,
          style: TextStyle(
            fontSize: responsive.scale(0.04, 0.03).clamp(14, 18),
          ),
        ),
      ),
    );
  }
}
