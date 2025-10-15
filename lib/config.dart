import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import '../Utils/responsive.dart';

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

  void _showCustomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    final responsive = Responsive(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.dp(2))),
        title: Column(
          children: [
            Icon(icon, color: iconColor, size: responsive.dp(6)),
            SizedBox(height: responsive.hp(1)),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: responsive.dp(2.2))),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: responsive.dp(1.8))),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.dp(3)),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: TextStyle(color: AppTheme.backgroundColor, fontSize: responsive.dp(1.8))),
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final responsive = Responsive(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.dp(2))),
        title: Text("Añadir Configuración", textAlign: TextAlign.center, style: TextStyle(fontSize: responsive.dp(2.2))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField("Semestre", semestreController, responsive),
              SizedBox(height: responsive.hp(1.5)),
              _inputField("Carrera", carreraController, responsive),
              SizedBox(height: responsive.hp(1.5)),
              _inputField("Periodo", periodoController, responsive),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.dp(3)),
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
              child: Text("Añadir", style: TextStyle(color: AppTheme.backgroundColor, fontSize: responsive.dp(1.8))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, Responsive responsive) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(responsive.dp(2))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text("Configuración", style: TextStyle(fontSize: responsive.dp(2.4))),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(responsive.wp(4)),
        child: Column(
          children: [
            SizedBox(height: responsive.hp(2)),
            Text(
              "Configuración de semestres,\ncarreras y periodos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.dp(2.6),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(responsive.dp(1.2)),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(responsive.dp(2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(responsive.dp(2)),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: responsive.wp(4),
                      columns: const [
                        DataColumn(label: Text("Semestre")),
                        DataColumn(label: Text("Carrera")),
                        DataColumn(label: Text("Periodo")),
                      ],
                      rows: _data.isEmpty
                          ? const [DataRow(cells: [DataCell(Text("-")), DataCell(Text("-")), DataCell(Text("-"))])]
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
            SizedBox(height: responsive.hp(2)),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.dp(3)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(5),
                  vertical: responsive.hp(1.5),
                ),
              ),
              onPressed: () => _showInputDialog(context),
              child: Text("Añadir Configuración", style: TextStyle(fontSize: responsive.dp(2), color: Colors.white)),
            ),

            SizedBox(height: responsive.hp(2)),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.dp(3)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(8),
                  vertical: responsive.hp(1.5),
                ),
              ),
              onPressed: () {
                bool exito = _data.isNotEmpty;
                _showCustomDialog(
                  context,
                  title: exito ? "Datos guardados" : "Error",
                  message: exito
                      ? "Datos guardados con éxito"
                      : "Error al guardar la configuración",
                  icon: exito ? Icons.check_circle : Icons.cancel,
                  iconColor: exito ? Colors.green : Colors.red,
                );
              },
              child: Text("Guardar", style: TextStyle(fontSize: responsive.dp(1.8), color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
