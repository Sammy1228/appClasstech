import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  final String tipoUsuario; // "estudiante" o "profesor"

  const PerfilScreen({
    super.key,
    required this.tipoUsuario,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  List<String> institucionesProfesor = [
    "Instituto Tecnológico Superior de Uruapan",
    "Universidad Michoacana de San Nicolás de Hidalgo",
  ];

  // Controlador temporal para nueva institución
  final TextEditingController _nuevaInstitucionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    //  MediaQuery para diseño responsive
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final double horizontalPadding =
        orientation == Orientation.portrait ? 16.0 : size.width * 0.2;
    final double fieldWidth =
        orientation == Orientation.portrait ? size.width * 0.9 : size.width * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: fieldWidth),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.04),

                // 🧑 Avatar de perfil
                CircleAvatar(
                  radius: size.width * 0.15,
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.7),
                  child: const Text(
                    "NA",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                //  Campos comunes
                _buildTextField("Nombres"),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Apellido P")),
                    SizedBox(width: size.width * 0.02),
                    Expanded(child: _buildTextField("Apellido M")),
                  ],
                ),
                SizedBox(height: size.height * 0.02),

                //  Si es profesor, mostrar instituciones
                if (widget.tipoUsuario == "profesor") ...[
                  _buildInstitucionesList(context),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField("Correo"),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField("Contraseña"),
                ] else ...[
                  // Si es estudiante
                  _buildTextField("Correo"),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField("Semestre"),
                  SizedBox(height: size.height * 0.02),
                  _buildTextField("Carrera"),
                ],

                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.018,
                      horizontal: size.width * 0.1,
                    ),
                  ),
                  child: const Text(
                    "Guardar",
                    style: TextStyle(fontSize: 14, color: AppTheme.backgroundColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Campo de texto con estilo personalizado
  Widget _buildTextField(String label) {
    return TextField(
      decoration: AppTheme.inputDecoration(label),
    );
  }

  // Listado de instituciones con opción de agregar y eliminar
  Widget _buildInstitucionesList(BuildContext context) {
    return InputDecorator(
      decoration: AppTheme.inputDecoration("Instituciones registradas"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Botón agregar institución
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              label: const Text(
                "Agregar institución",
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: () => _mostrarDialogoAgregar(context),
            ),
          ),
          const SizedBox(height: 8),
          if (institucionesProfesor.isEmpty)
            const Text(
              "No hay instituciones registradas",
              style: TextStyle(color: Colors.grey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: institucionesProfesor.length,
              separatorBuilder: (_, __) => const Divider(height: 8, color: Colors.grey),
              itemBuilder: (context, index) {
                final institucion = institucionesProfesor[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                  title: Text(institucion, style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        institucionesProfesor.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Diálogo para agregar una nueva institución
  void _mostrarDialogoAgregar(BuildContext context) {
    _nuevaInstitucionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar institución"),
          content: TextField(
            controller: _nuevaInstitucionController,
            decoration: const InputDecoration(
              hintText: "Nombre de la institución",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () {
                final nueva = _nuevaInstitucionController.text.trim();
                if (nueva.isNotEmpty) {
                  setState(() {
                    institucionesProfesor.add(nueva);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }
}
