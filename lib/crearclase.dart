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
  final _formKey = GlobalKey<FormState>();
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
  final TextEditingController _cicloEscolarCtrl = TextEditingController();

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio.';
    return null;
  }

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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: AppTheme.inputDecoration("Título de la clase"),
                    validator: _required,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: AppTheme.inputDecoration("Descripción"),
                    validator: _required,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    enabled: false,
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
                  TextFormField(
                    controller: _carreraCtrl,
                    decoration: AppTheme.inputDecoration("Carrera"),
                    validator: _required,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _semestreCtrl,
                    decoration: AppTheme.inputDecoration("Semestre"),
                    validator: _required,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _cicloEscolarCtrl,
                      decoration: AppTheme.inputDecoration("Ciclo Escolar (Ej: Agosto 2024 - Dic 2024)"),
                      validator: validateCicloEscolar,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _codigoCtrl,
                    decoration: AppTheme.inputDecoration("Código"),
                    validator: _required,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      if (!_formKey.currentState!.validate()) return;
                      final clasesProvider = Provider.of<ProviderClases>(context, listen: false);

                      clasesProvider.setTitulo = _tituloCtrl.text.trim();
                      clasesProvider.setDescripcion = _descripcionCtrl.text.trim();
                      clasesProvider.setNombreProfesor = nombreProfesor;
                      clasesProvider.setInstitucion = institucionSeleccionada ?? _institucionCtrl.text.trim();
                      clasesProvider.setCarrera = _carreraCtrl.text.trim();
                      clasesProvider.setSemestre = _semestreCtrl.text.trim();
                      clasesProvider.setCicloEscolar = _cicloEscolarCtrl.text.trim();
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
                        _institucionCtrl.clear();
                        _cicloEscolarCtrl.clear();

                        _formKey.currentState!.reset();

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
      ),
    );
  }
}

String? validateCicloEscolar(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El ciclo escolar es obligatorio.';
  }
  final RegExp regex = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚ\s]{3,}\s\d{4}\s-\s[a-zA-ZáéíóúÁÉÍÓÚ\s]{3,}\s\d{4}$',
    caseSensitive: false,
  );

  if (!regex.hasMatch(value.trim())) {
    return 'Formato inválido. Use "Mes AAAA - Mes AAAA" (Ej: Agosto 2024 - Dic 2024).';
  }
  return null;
}
