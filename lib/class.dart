import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'crearclase.dart';
import 'crearactividad.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class ClasesScreen extends StatefulWidget {
  const ClasesScreen({super.key});

  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
  List<Map<String, dynamic>> clases = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      final snapshot = await Provider.of<ProviderClases>(context, listen: false).obtenerClases();
      final nuevasClases = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> alumnos = data['alumnos'] ?? [];

        if (alumnos.contains(user?.uid)) {
          nuevasClases.add({
            "title": data['titulo'] ?? 'Sin título',
            "desc": data['descripcion'] ?? 'Sin descripción',
            "color": 0xFFBBDEFB,
          });
        }
      }

      setState(() {
        clases = nuevasClases;
      });

      print("Clases filtradas: $clases");
    } catch (e) {
      print("Error al cargar clases: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final isPortrait = responsive.isPortrait;
    final tipoUsuario = Provider.of<Authentication>(context).tipoUsuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Clases",
          style: TextStyle(
            fontSize: responsive.titleFontSize * 0.6,
            color: AppTheme.backgroundColor,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        actions: [
          if (tipoUsuario == 'profesor')
            IconButton(
              icon: AppTheme.themedIcon(
                Icons.add,
                color: AppTheme.backgroundColor,
                size: responsive.scale(0.08, 0.05),
              ),
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
            return AppTheme.claseCard(
              title: clase["title"],
              description: clase["desc"],
              color: Color(clase["color"]),
            );
          },
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
          padding: EdgeInsets.symmetric(
            vertical: responsive.hp(1.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: responsive.scale(0.04, 0.03)),
        ),
      ),
    );
  }
}
