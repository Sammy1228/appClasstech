import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String? _rolSeleccionado;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _repiteCtrl = TextEditingController();
  final TextEditingController _nuevaInstitucionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      if (_rolSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un rol')),
        );
        return;
      }

      if (_contrasenaCtrl.text != _repiteCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      setState(() => _isLoading = true);
      final auth = Provider.of<Authentication>(context, listen: false);

      auth.setNombre = _nombreCtrl.text.trim();
      auth.setApellidos = _apellidoCtrl.text.trim();
      auth.setEmail = _correoCtrl.text.trim();
      auth.setPassword = _contrasenaCtrl.text.trim();
      auth.setConfirmPassword = _repiteCtrl.text.trim();
      auth.setTipoUsuario = _rolSeleccionado!;

      try {
        final user = await auth.register();
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Registro exitoso: ${user.email}")),
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error en el registro: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final auth = Provider.of<Authentication>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: responsive.screenHeight * 0.08),
                Center(
                  child: Text(
                    "Registro",
                    style: TextStyle(
                      fontSize: responsive.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.backgroundColor,
                    ),
                  ),
                ),
                SizedBox(height: responsive.screenHeight * 0.04),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                      vertical: responsive.verticalPadding,
                    ),
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField("Nombre(s)", _nombreCtrl),
                            SizedBox(height: responsive.fieldSpacing),
                            _buildTextField("Apellidos", _apellidoCtrl),
                            SizedBox(height: responsive.fieldSpacing),
                            _buildTextField("Correo", _correoCtrl,
                                keyboardType: TextInputType.emailAddress),
                            SizedBox(height: responsive.fieldSpacing),
                            _buildTextField("Contraseña", _contrasenaCtrl,
                                obscure: true),
                            SizedBox(height: responsive.fieldSpacing),
                            _buildTextField(
                                "Repite la contraseña", _repiteCtrl,
                                obscure: true),
                            SizedBox(height: responsive.fieldSpacing * 1.5),
                            Text(
                              "Rol",
                              style: TextStyle(
                                  fontSize: responsive.screenWidth * 0.045),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRolCheck("Estudiante"),
                                _buildRolCheck("Profesor"),
                              ],
                            ),
                            SizedBox(height: responsive.fieldSpacing * 1.5),

                            if (_rolSeleccionado == "Profesor")
                              _buildInstitucionesList(context, auth),

                            SizedBox(height: responsive.fieldSpacing * 1.5),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: responsive.fieldSpacing * 1.2,
                                ),
                              ),
                              onPressed: _isLoading ? null : _registrar,
                              child: Text(
                                _isLoading
                                    ? "Registrando..."
                                    : "Registrarme",
                                style: TextStyle(
                                  fontSize: responsive.screenWidth * 0.045,
                                  color: AppTheme.backgroundColor,
                                ),
                              ),
                            ),
                            SizedBox(height: responsive.fieldSpacing * 1.2),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Ya tienes una cuenta, ",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize:
                                          responsive.screenWidth * 0.04,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "inicia sesión aquí",
                                        style: TextStyle(
                                          color: AppTheme.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: AppTheme.inputDecoration(label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor completa este campo';
        }
        return null;
      },
    );
  }

  Widget _buildRolCheck(String rol) {
    return Row(
      children: [
        Checkbox(
          value: _rolSeleccionado == rol,
          onChanged: (val) {
            setState(() {
              _rolSeleccionado = val! ? rol : null;
            });
          },
        ),
        Text(rol),
        const SizedBox(width: 10),
      ],
    );
  }

  // Lista de instituciones desde el provider
  Widget _buildInstitucionesList(BuildContext context, Authentication auth) {
    final instituciones = auth.instituciones;

    return InputDecorator(
      decoration: AppTheme.inputDecoration("Instituciones registradas"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              label: const Text("Agregar institución",
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () => _mostrarDialogoAgregar(context, auth),
            ),
          ),
          const SizedBox(height: 8),
          if (instituciones.isEmpty)
            const Text("No hay instituciones registradas",
                style: TextStyle(color: Colors.grey))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: instituciones.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 8, color: Colors.grey),
              itemBuilder: (context, index) {
                final institucion = instituciones[index];
                final nombre = institucion['nombre'];
                final estado = institucion['estado'];

                return ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.school, color: AppTheme.primaryColor),
                  title: Text(
                    nombre,
                    style: TextStyle(
                      fontSize: 14,
                      color: estado == 'inactivo'
                          ? Colors.grey
                          : Colors.black,
                      decoration: estado == 'inactivo'
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

void _mostrarDialogoAgregar(BuildContext context, Authentication auth) {
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
              child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              final nombre = _nuevaInstitucionController.text.trim();
              if (nombre.isNotEmpty) {
                // 🔹 Solo agregamos a memoria local del provider
                auth.instituciones.add({
                  'nombre': nombre,
                  'estado': 'activo',
                });
                auth.notifyListeners();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Institución '$nombre' agregada.")),
                );
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
