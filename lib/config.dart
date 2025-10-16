import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_drawer.dart';
import 'Utils/responsive.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final TextEditingController semestreController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();

  final List<Map<String, String>> _data = [];

  // 🔹 Modal genérico
  void _showCustomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    final r = Responsive(context);
    final double iconSize = r.dp(12).clamp(40, 60);
    final double fontSize = r.dp(4).clamp(14, 18);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            SizedBox(height: r.hp(1.5).clamp(8, 14)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize - 2),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(8).clamp(20, 40),
                  vertical: r.hp(1.2).clamp(8, 14),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: AppTheme.backgroundColor,
                  fontSize: fontSize - 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modal con TextFields (para añadir datos a la tabla)
  void _showInputDialog(BuildContext context) {
    final r = Responsive(context);
    final double spacing = r.hp(1.5).clamp(8, 14);
    final double fontSize = r.dp(3.8).clamp(14, 18);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Añadir Configuración",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            SizedBox(height: spacing),
            TextField(
              controller: carreraController,
              decoration: InputDecoration(
                labelText: "Carrera",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: spacing),
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
                padding: EdgeInsets.symmetric(
                  horizontal: r.wp(10).clamp(24, 40),
                  vertical: r.hp(1.5).clamp(10, 14),
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
              child: Text(
                "Añadir",
                style: TextStyle(
                  color: AppTheme.backgroundColor,
                  fontSize: fontSize - 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final double basePadding = r.hp(2).clamp(12, 20);
    final double titleSize = r.dp(5).clamp(22, 30);
    final double textSize = r.dp(3.8).clamp(14, 18);
    final double buttonPaddingV = r.hp(1.5).clamp(10, 14);
    final double buttonPaddingH = r.wp(8).clamp(24, 40);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Configuración",
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: textSize + 2,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(basePadding),
        child: Column(
          children: [
            SizedBox(height: r.hp(2).clamp(12, 20)),
            Text(
              "Configuración de semestres,\ncarreras y periodos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: r.hp(2).clamp(12, 20)),

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
                padding: EdgeInsets.all(r.wp(2).clamp(8, 14)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: DataTableTheme(
                    data: DataTableThemeData(
                      headingRowColor: WidgetStateProperty.all(
                        AppTheme.primaryColor,
                      ),
                      headingTextStyle: TextStyle(
                        color: AppTheme.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: textSize,
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
                      columns: [
                        DataColumn(label: Text("Semestre", style: TextStyle(fontSize: textSize))),
                        DataColumn(label: Text("Carrera", style: TextStyle(fontSize: textSize))),
                        DataColumn(label: Text("Periodo", style: TextStyle(fontSize: textSize))),
                      ],
                      rows: _data.isEmpty
                          ? [
                              DataRow(
                                cells: [
                                  DataCell(Text("-", style: TextStyle(fontSize: textSize))),
                                  DataCell(Text("-", style: TextStyle(fontSize: textSize))),
                                  DataCell(Text("-", style: TextStyle(fontSize: textSize))),
                                ],
                              ),
                            ]
                          : _data.map((row) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(row["semestre"] ?? "-", style: TextStyle(fontSize: textSize))),
                                  DataCell(Text(row["carrera"] ?? "-", style: TextStyle(fontSize: textSize))),
                                  DataCell(Text(row["periodo"] ?? "-", style: TextStyle(fontSize: textSize))),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: r.hp(2).clamp(12, 20)),

            // Botón Añadir Configuración
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH,
                  vertical: buttonPaddingV,
                ),
              ),
              onPressed: () {
                _showInputDialog(context);
              },
              child: Text(
                "Añadir Configuración",
                style: TextStyle(
                  fontSize: textSize,
                  color: AppTheme.backgroundColor,
                ),
              ),
            ),

            SizedBox(height: r.hp(2).clamp(12, 20)),

            // Botón Guardar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH + 10,
                  vertical: buttonPaddingV,
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
              child: Text(
                "Guardar",
                style: TextStyle(
                  fontSize: textSize,
                  color: AppTheme.backgroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
