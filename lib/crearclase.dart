import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class CrearClasePage extends StatefulWidget {
  const CrearClasePage({super.key});

  @override
  State<CrearClasePage> createState() => _CrearClasePageState();
}

class _CrearClasePageState extends State<CrearClasePage> {
  String? institucionSeleccionada;
  final List<String> instituciones = [
    'Instituto Tecnológico Superior de Uruapan',
    'Universidad Michoacana',
    'Universidad de Guadalajara',
    'Otra institución'
  ];

  // Controladores
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _carreraCtrl = TextEditingController();
  final TextEditingController _semestreCtrl = TextEditingController();
  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _institucionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Obtener el nombre del profesor y sus instituciones desde provider
    final nombreProfesor = Provider.of<Authentication>(context, listen: false).nombre;
    final instituciones = Provider.of<Authentication>(context, listen: false).instituciones;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Crear clase"),
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
                  decoration: AppTheme.inputDecoration("Título de la clase"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descripcionCtrl,
                  decoration: AppTheme.inputDecoration("Descripción"),
                ),
                const SizedBox(height: 12),
                TextField(
                  enabled: false, // Solo lectura
                  decoration: AppTheme.inputDecoration("Nombre de profesor"),
                  controller: TextEditingController(text: nombreProfesor),
                ),
                const SizedBox(height: 12),

                // Campo desplegable de Institución
                InputDecorator(
                  decoration: AppTheme.inputDecoration("Seleccionar institución"),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: institucionSeleccionada,
                            hint: const Text("Seleccionar institución"),
                            items: instituciones
                                .map(
                                  (inst) => DropdownMenuItem<String>(
                                    value: inst,
                                    child: Text(inst),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                institucionSeleccionada = value;
                                _institucionCtrl.text = "";
                              });
                            },
                          ),
                        ),
                      ),
                      if (institucionSeleccionada != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          tooltip: "Borrar selección",
                          onPressed: () {
                            setState(() {
                              institucionSeleccionada = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: _carreraCtrl,
                  decoration: AppTheme.inputDecoration("Carrera"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _semestreCtrl,
                  decoration: AppTheme.inputDecoration("Semestre"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _codigoCtrl,
                  decoration: AppTheme.inputDecoration("Código"),
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
                    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);

                    clasesProvider.setTitulo = _tituloCtrl.text.trim();
                    clasesProvider.setDescripcion = _descripcionCtrl.text.trim();
                    clasesProvider.setNombreProfesor = nombreProfesor;
                    clasesProvider.setInstitucion = institucionSeleccionada ?? _institucionCtrl.text.trim();
                    clasesProvider.setCarrera = _carreraCtrl.text.trim();
                    clasesProvider.setSemestre = _semestreCtrl.text.trim();
                    clasesProvider.setCodigoAcceso = _codigoCtrl.text.trim();

                    try {
                      await clasesProvider.createClass();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Clase creada exitosamente")),
                      );
                      // limpiar campos
                      _tituloCtrl.clear();
                      _descripcionCtrl.clear();
                      _carreraCtrl.clear();
                      _semestreCtrl.clear();
                      _codigoCtrl.clear();
                      setState(() {
                        institucionSeleccionada = null;
                      });
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
