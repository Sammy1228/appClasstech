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
            return _claseCard(clase, tipoUsuario, responsive);
          },
        ),
      ),
    );
  }

  // ✅ CAMBIO: Añadido Responsive r y clamp() a fuentes
  Widget _claseCard(
    Map<String, dynamic> clase,
    String tipoUsuario,
    Responsive r,
  ) {
    final provider = Provider.of<ProviderClases>(context, listen: false);
    final index = clases.indexOf(clase);

    // Color base (si está inactiva, será gris)
    final baseColor = clase["estado"] == "inactivo"
        ? Colors.grey
        : AppTheme.claseColors[index % AppTheme.claseColors.length];

    // Función para oscurecer el color de la franja superior
    Color darken(Color c, [double amount = 0.1]) {
      final hsl = HSLColor.fromColor(c);
      final hslDark = hsl.withLightness(
        (hsl.lightness - amount).clamp(0.0, 1.0),
      );
      return hslDark.toColor();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con color más oscuro e ícono
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: darken(baseColor, 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                AppTheme.themedIcon(
                  Icons.book,
                  color: Colors.white,
                  size: r.dp(6).clamp(28, 34),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clase["title"] ?? 'Sin título',
                    style: TextStyle(
                      fontSize: r.dp(4.5).clamp(16, 19), // ✅ CAMBIO
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Descripción
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              clase["desc"] ?? 'Sin descripción',
              style: TextStyle(
                fontSize: r.dp(3.8).clamp(14, 16), // ✅ CAMBIO
                color: Colors.black87,
              ),
            ),
          ),

          // Si es profesor, mostrar switch de estado
          if (tipoUsuario == "profesor")
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: darken(baseColor, 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clase["estado"] == "activo"
                        ? "Desactivar clase"
                        : "Activar clase",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.dp(3.8).clamp(14, 16), // ✅ CAMBIO
                    ),
                  ),
                  Switch(
                    value: clase["estado"] == "activo",
                    onChanged: (value) async {
                      final nuevoEstado = value ? "activo" : "inactivo";
                      await provider.cambiarEstadoClase(
                        clase["id"],
                        nuevoEstado,
                      );
                      cargarDatos(); // recarga la lista de clases
                    },
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white54,
                    inactiveTrackColor: Colors.black26,
                  ),
                ],
              ),
            ),
        ],
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
