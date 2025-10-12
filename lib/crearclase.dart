import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    // MediaQuery para diseño responsive
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Ajustar padding y ancho según orientación
    final double horizontalPadding =
        orientation == Orientation.portrait ? 16.0 : size.width * 0.2;
    final double fieldWidth =
        orientation == Orientation.portrait ? size.width * 0.9 : size.width * 0.6;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Crear clase"),
        titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: fieldWidth),
            child: Column(
              children: [
                TextField(
                  decoration: AppTheme.inputDecoration("Título de la clase"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Descripción"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Nombre de profesor"),
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
                  decoration: AppTheme.inputDecoration("Carrera"),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: AppTheme.inputDecoration("Semestre"),
                ),
                const SizedBox(height: 12),
                TextField(
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
                  onPressed: () {
                    // Acción al crear clase
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
