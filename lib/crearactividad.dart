import 'package:appzacek/providers/provider_actividades.dart';
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'package:appzacek/providers/provider_clases.dart';

class CrearActividadPage extends StatefulWidget {
  const CrearActividadPage({super.key});

  @override
  State<CrearActividadPage> createState() => _CrearActividadPageState();
}

class _CrearActividadPageState extends State<CrearActividadPage> {
  // Controladores 
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _urlCtrl = TextEditingController();

  String? claseSeleccionada;
  List<String> clasesDelProfesor = [];
  bool cargandoClases = true;

  @override
  void initState() {
    super.initState();
    cargarClases();
  }

  // Cargar las clases del profesor desde providers
  Future<void> cargarClases() async {
    final nombreProfesor = Provider.of<Authentication>(context, listen: false).nombre;
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);
    final clases = await clasesProvider.getProfessorClasses(nombreProfesor);
    setState(() {
      clasesDelProfesor = clases;
      cargandoClases = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Crear actividad"),
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.fieldWidth),
            child: Column(
              children: [
                TextField(
                  controller: _tituloCtrl,
                  decoration: AppTheme.inputDecoration("Título de la actividad"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descripcionCtrl,
                  decoration: AppTheme.inputDecoration("Descripción"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _urlCtrl,
                  decoration: AppTheme.inputDecoration("Url de contenido"),
                ),
                const SizedBox(height: 12),
                cargandoClases
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        items: clasesDelProfesor
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        value: claseSeleccionada,
                        onChanged: (value) {
                          setState(() {
                            claseSeleccionada = value;
                          });
                        },
                        decoration: AppTheme.inputDecoration("Clase"),
                      ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final actividadesProvider = Provider.of<ProviderActividades>(context, listen: false);

                    actividadesProvider.setTitulo = _tituloCtrl.text.trim();
                    actividadesProvider.setDescripcion = _descripcionCtrl.text.trim();
                    actividadesProvider.setUrl = _urlCtrl.text.trim();
                    actividadesProvider.setClase = claseSeleccionada ?? "";

                    try {
                      await actividadesProvider.createActivity();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Actividad creada exitosamente")),
                      );
                      // Limpia los campos del formulario
                      _tituloCtrl.clear();
                      _descripcionCtrl.clear();
                      _urlCtrl.clear();
                      // Puedes limpiar la selección de clase si lo deseas
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    child: Text(
                      "Crear",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}