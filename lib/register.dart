import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String? _rolSeleccionado;
  List<String> institucionesProfesor = [];
    final TextEditingController _nuevaInstitucionController =
      TextEditingController();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _repiteCtrl = TextEditingController();
  final TextEditingController _carreraCtrl = TextEditingController();
  final TextEditingController _semestreCtrl = TextEditingController();
 

 void _agregarInstitucion() {
    final texto = _nuevaInstitucionController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        institucionesProfesor.add(texto);
        _nuevaInstitucionController.clear();
      });
    }
  }

  void _eliminarInstitucion(int index) {
    setState(() {
      institucionesProfesor.removeAt(index);
    });
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      if (_rolSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un rol')),
        );
        return;
      }
      // Validación adicional: contraseñas coinciden
      if (_contrasenaCtrl.text != _repiteCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      //  guardar los datos o enviar al backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro completado como $_rolSeleccionado')),
      );
    }
  }


@override
Widget build(BuildContext context) {
final responsive = Responsive(context);

return Scaffold(
  backgroundColor: AppTheme.primaryColor,
  body: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {


        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: responsive.screenHeight * 0.08),

            //  Título superior
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

            //  Contenedor blanco del formulario (ocupa el espacio restante)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                        _buildTextField("Contraseña", _contrasenaCtrl, obscure: true),
                        SizedBox(height: responsive.fieldSpacing),
                        _buildTextField("Repite la contraseña", _repiteCtrl, obscure: true),
                        SizedBox(height: responsive.fieldSpacing * 1.5),

                        //  Rol
                        Text(
                          "Rol",
                          style: TextStyle(fontSize: responsive.screenWidth * 0.045),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRolCheck("Estudiante"),
                            _buildRolCheck("Profesor"),
                          ],
                        ),
                        SizedBox(height: responsive.fieldSpacing * 1.5),

                        // Campos dinámicos según el rol
                        if (_rolSeleccionado == "Estudiante") ...[
                          _buildTextField("Carrera", _carreraCtrl),
                          SizedBox(height: responsive.fieldSpacing),
                          _buildTextField("Semestre", _semestreCtrl),
                        ] else if (_rolSeleccionado == "Profesor") ...[
                          Text(
                            "Instituciones",
                            style: TextStyle(fontSize: responsive.screenWidth * 0.045),
                          ),
                          SizedBox(height: responsive.fieldSpacing * 0.5),

                          //  Lista expandible de instituciones
                          SizedBox(
                            height: responsive.screenHeight * 0.25,
                            child: SizedBox.expand(
                              child: _buildInstitucionesList(
                                  responsive.screenHeight, responsive.screenWidth),
                            ),
                          ),
                        ],
                        SizedBox(height: responsive.fieldSpacing * 1.5),

                        // Botón de registro
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
                          onPressed: _registrar,
                          child: Text(
                            "Registrarme",
                            style: TextStyle(
                              fontSize: responsive.screenWidth * 0.045,
                              color: AppTheme.backgroundColor,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.fieldSpacing * 1.2),

                        //  Enlace de inicio de sesión
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text.rich(
                              TextSpan(
                                text: "Ya tienes una cuenta, ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: responsive.screenWidth * 0.04,
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

  // Sección de instituciones (solo para profesor)
  Widget _buildInstitucionesList(double screenHeight, double screenWidth) {
    return InputDecorator(
      decoration: AppTheme.inputDecoration("Instituciones"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              separatorBuilder: (_, __) =>
                  const Divider(height: 8, color: Colors.grey),
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
                        _eliminarInstitucion(index);
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

  // Diálogo para agregar nueva institución
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
                  _agregarInstitucion();
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