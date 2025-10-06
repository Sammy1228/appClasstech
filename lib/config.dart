import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final TextEditingController semestreController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();

  // Datos para la tabla
  final List<Map<String, String>> _data = [];

  // 🔹 Modal genérico
  void _showCustomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(icon, color: iconColor, size: 50),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(color: AppTheme.backgroundColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modal con TextFields (para añadir datos a la tabla)
  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Añadir Configuración", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: semestreController,
              decoration: InputDecoration(
                labelText: "Semestre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: carreraController,
              decoration: InputDecoration(
                labelText: "Carrera",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: periodoController,
              decoration: InputDecoration(
                labelText: "Periodo",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  _data.add({
                    "semestre": semestreController.text,
                    "carrera": carreraController.text,
                    "periodo": periodoController.text,
                  });
                });

                semestreController.clear();
                carreraController.clear();
                periodoController.clear();

                Navigator.of(context).pop();

                _showCustomDialog(
                  context,
                  title: "Éxito",
                  message: "Datos añadidos con éxito",
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                );
              },
              child: const Text(
                "Añadir",
                style: TextStyle(color: AppTheme.backgroundColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Configuración"),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Configuración de semestres,\ncarreras y periodos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Tabla
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.primaryColor,
                      ),
                      headingTextStyle: const TextStyle(
                        color: AppTheme.backgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                      dataRowColor: WidgetStateProperty.all(
                        AppTheme.backgroundColor,
                      ),
                      dividerThickness: 1,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: DataTable(
                      border: TableBorder.all(width: 1),
                      columns: const [
                        DataColumn(label: Text("Semestre")),
                        DataColumn(label: Text("Carrera")),
                        DataColumn(label: Text("Periodo")),
                      ],
                      rows: _data.isEmpty
                          ? const [
                              DataRow(
                                cells: [
                                  DataCell(Text("-")),
                                  DataCell(Text("-")),
                                  DataCell(Text("-")),
                                ],
                              ),
                            ]
                          : _data.map((row) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(row["semestre"] ?? "-")),
                                  DataCell(Text(row["carrera"] ?? "-")),
                                  DataCell(Text(row["periodo"] ?? "-")),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Añadir Configuración
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                _showInputDialog(context);
              },
              child: const Text("Añadir Configuración"),
            ),

            const SizedBox(height: 20),

            // Botón Guardar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                bool exito = _data.isNotEmpty;
                if (exito) {
                  _showCustomDialog(
                    context,
                    title: "Datos guardados",
                    message: "Datos guardados con éxito",
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                  );
                } else {
                  _showCustomDialog(
                    context,
                    title: "Error",
                    message: "Error al guardar la configuración",
                    icon: Icons.cancel,
                    iconColor: Colors.red,
                  );
                }
              },

              child: const Text(
                "Guardar",
                style: TextStyle(fontSize: 16, color: AppTheme.backgroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
