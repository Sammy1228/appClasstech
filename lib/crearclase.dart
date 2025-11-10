import 'dart:math';
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

  // Controladores
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _cicloEscolarCtrl = TextEditingController();
  final TextEditingController _codigoCtrl = TextEditingController();
  final TextEditingController _carreraCtrl = TextEditingController();
  final TextEditingController _semestreCtrl = TextEditingController();

  bool _carreraNA = false;
  bool _semestreNA = false;

  String generarCodigoUnico() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obligatorio.';
    return null;
  }

  @override
  void initState() {
    super.initState();
    _codigoCtrl.text = generarCodigoUnico();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    final authProvider = Provider.of<Authentication>(context, listen: false);
    final nombreProfesor = authProvider.nombre;

    List<String> institucionesDisponibles = authProvider.instituciones
        .map<String>((inst) {
      if (inst is Map<String, dynamic>) {
        final nombre = inst['nombre'];
        return nombre != null ? nombre.toString() : '';
      }
      return '';
    }).where((s) => s.trim().isNotEmpty).toList();

    if (institucionesDisponibles.isEmpty) {
      institucionesDisponibles = [
        'Instituto Tecnológico Superior de Uruapan',
        'Universidad Michoacana',
        'Universidad de Guadalajara',
        'Otra institución'
      ];
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Crear clase"),
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding, vertical: 16),
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

                  // Nombre del profesor
                  TextField(
                    enabled: false,
                    decoration: AppTheme.inputDecoration("Nombre del profesor"),
                    controller: TextEditingController(text: nombreProfesor),
                  ),
                  const SizedBox(height: 12),

                  // Selección de institución
                  DropdownButtonFormField<String>(
                    value: institucionSeleccionada,
                    items: institucionesDisponibles
                        .map((inst) => DropdownMenuItem<String>(
                              value: inst,
                              child: Text(inst),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        institucionSeleccionada = value;
                      });
                    },
                    decoration: AppTheme.inputDecoration("Seleccionar institución"),
                    validator: _required,
                  ),

                  const SizedBox(height: 12),

                  // CAMPO DE CARRERA
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _carreraCtrl,
                          enabled: !_carreraNA,
                          decoration:
                              AppTheme.inputDecoration("Carrera (escribir o marcar N/A)"),
                          validator: (value) {
                            if (!_carreraNA && (value == null || value.trim().isEmpty)) {
                              return 'Campo obligatorio o marque N/A.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Checkbox(
                            value: _carreraNA,
                            onChanged: (value) {
                              setState(() {
                                _carreraNA = value ?? false;
                                if (_carreraNA) {
                                  _carreraCtrl.text = 'N/A';
                                } else {
                                  _carreraCtrl.clear();
                                }
                              });
                            },
                          ),
                          const Text("N/A", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // CAMPO DE SEMESTRE
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _semestreCtrl,
                          enabled: !_semestreNA,
                          decoration:
                              AppTheme.inputDecoration("Semestre (escribir o marcar N/A)"),
                          validator: (value) {
                            if (!_semestreNA && (value == null || value.trim().isEmpty)) {
                              return 'Campo obligatorio o marque N/A.';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Checkbox(
                            value: _semestreNA,
                            onChanged: (value) {
                              setState(() {
                                _semestreNA = value ?? false;
                                if (_semestreNA) {
                                  _semestreCtrl.text = 'N/A';
                                } else {
                                  _semestreCtrl.clear();
                                }
                              });
                            },
                          ),
                          const Text("N/A", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ciclo escolar
                  TextFormField(
                    controller: _cicloEscolarCtrl,
                    decoration: AppTheme.inputDecoration(
                        "Ciclo Escolar (Ej: Agosto 2024 - Dic 2024)"),
                    validator: validateCicloEscolar,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 12),

                  // Código generado automáticamente
                  TextField(
                    enabled: false,
                    decoration: AppTheme.inputDecoration("Código generado"),
                    controller: _codigoCtrl,
                  ),
                  const SizedBox(height: 20),

                  // Botón de crear clase
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final clasesProvider =
                          Provider.of<ProviderClases>(context, listen: false);
                      final codigoGenerado = _codigoCtrl.text.trim();

                      clasesProvider.setTitulo = _tituloCtrl.text.trim();
                      clasesProvider.setDescripcion = _descripcionCtrl.text.trim();
                      clasesProvider.setNombreProfesor = nombreProfesor;
                      clasesProvider.setInstitucion =
                          institucionSeleccionada ?? "";
                      clasesProvider.setCarrera = _carreraCtrl.text.trim();
                      clasesProvider.setSemestre = _semestreCtrl.text.trim();
                      clasesProvider.setCicloEscolar =
                          _cicloEscolarCtrl.text.trim();
                      clasesProvider.setCodigoAcceso = codigoGenerado;

                      try {
                        await clasesProvider.createClass();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Clase creada exitosamente")),
                        );

                        // Limpiar campos
                        _tituloCtrl.clear();
                        _descripcionCtrl.clear();
                        _cicloEscolarCtrl.clear();
                        _codigoCtrl.text = generarCodigoUnico();
                        _carreraCtrl.clear();
                        _semestreCtrl.clear();
                        setState(() {
                          _carreraNA = false;
                          _semestreNA = false;
                          institucionSeleccionada = null;
                        });

                        _formKey.currentState!.reset();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      child:
                          Text("Crear", style: TextStyle(color: Colors.white)),
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

// Validación de ciclo escolar
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
