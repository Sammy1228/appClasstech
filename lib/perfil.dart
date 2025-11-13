import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_autenticacion.dart';
import '../providers/provider_clases.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  //controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nuevaInstitucionController =
      TextEditingController();

  bool _isSaving = false;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _forzarCargaDatos();
  }

  Future<void> _forzarCargaDatos() async {
    final auth = Provider.of<Authentication>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (auth.tipoUsuario == 'profesor') {
        await auth.cargarDatosProfesor(user.uid);
      } else if (auth.tipoUsuario == 'alumno') {
        await auth.cargarDatosAlumno(user.uid);
      }
      setState(() {
        _cargarDatos(auth); // Carga en los controladores
        _datosCargados = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ya no cargar datos aquí para evitar sobrescribir campos cuando el provider notifique cambios.
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _nuevaInstitucionController.dispose();
    super.dispose();
  }

  void _cargarDatos(Authentication auth) {
    _nombreController.text = auth.nombre;
    _apellidosController.text = auth.apellidos;
    _correoController.text = auth.email;
    _passwordController.text = auth.password;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Authentication>(context);
    final responsive = Responsive(context);

    // Cargar datos en controllers solo una vez cuando el provider tenga los datos.
    if (auth.isLoggedIn && !_datosCargados) {
      _cargarDatos(auth);
      _datosCargados = true;
    }

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: AppTheme.primaryColor,
          titleTextStyle: const TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: 20,
          ),
          iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        ),
        body: const Center(child: Text("Inicia sesión para ver tu perfil.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            // ✅ CAMBIO: maxWidth fijo para el formulario
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                SizedBox(height: (responsive.size.height * 0.04).clamp(15, 30)),

                // 🧑 Avatar de perfil
                CircleAvatar(
                  // ✅ CAMBIO: Añadido clamp
                  radius: (responsive.size.width * 0.15).clamp(50, 80),
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.7),
                  child: Text(
                    _getIniciales(auth.nombre, auth.apellidos),
                    style: TextStyle(
                      // ✅ CAMBIO: Añadido clamp
                      fontSize: (responsive.size.width * 0.1).clamp(30, 45),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: (responsive.size.height * 0.04).clamp(15, 30)),

                // Campos comunes
                _buildTextField("Nombres", _nombreController),
                SizedBox(height: (responsive.size.height * 0.02).clamp(10, 16)),
                _buildTextField("Apellidos", _apellidosController),
                SizedBox(height: (responsive.size.height * 0.02).clamp(10, 16)),

                if (auth.tipoUsuario == "profesor") ...[
                  // ✅ CAMBIO: Pasado 'responsive'
                  _buildInstitucionesList(context, auth, responsive),
                  SizedBox(
                    height: (responsive.size.height * 0.02).clamp(10, 16),
                  ),
                  _buildTextField("Correo", _correoController),
                  SizedBox(
                    height: (responsive.size.height * 0.02).clamp(10, 16),
                  ),
                  _buildTextField(
                    "Contraseña",
                    _passwordController,
                    obscure: true,
                  ),
                ] else if (auth.tipoUsuario == "alumno") ...[
                  _buildTextField("Correo", _correoController),
                  SizedBox(
                    height: (responsive.size.height * 0.02).clamp(10, 16),
                  ),
                  SizedBox(
                    height: (responsive.size.height * 0.02).clamp(10, 16),
                  ),
                  _buildTextField(
                    "Contraseña",
                    _passwordController,
                    obscure: true,
                  ),
                ],

                SizedBox(height: (responsive.size.height * 0.04).clamp(20, 30)),

                ElevatedButton(
                  onPressed: _isSaving ? null : () => _guardarCambios(auth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      // ✅ CAMBIO: Añadido clamp
                      vertical: (responsive.size.height * 0.018).clamp(14, 18),
                      horizontal: (responsive.size.width * 0.1).clamp(30, 50),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: AppTheme.backgroundColor,
                        )
                      : Text(
                          "Guardar",
                          style: TextStyle(
                            // ✅ CAMBIO: Añadido clamp
                            fontSize: responsive.dp(3.5).clamp(14, 16),
                            color: AppTheme.backgroundColor,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: AppTheme.inputDecoration(label),
    );
  }

  // ✅ CAMBIO: Añadido Responsive y clamp() a fuentes
  Widget _buildInstitucionesList(
    BuildContext context,
    Authentication auth,
    Responsive responsive,
  ) {
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
              label: Text(
                "Agregar institución",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: responsive.dp(3.5).clamp(14, 16),
                ),
              ),
              onPressed: () => _mostrarDialogoAgregar(context, auth),
            ),
          ),
          const SizedBox(height: 8),
          if (instituciones.isEmpty)
            const Text(
              "No hay instituciones registradas",
              style: TextStyle(color: Colors.grey),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: instituciones.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 8, color: Colors.grey),
              itemBuilder: (context, index) {
                final institucion = instituciones[index];
                final estado = institucion['estado'];
                final nombre = institucion['nombre'];

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.school,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(
                    nombre,
                    style: TextStyle(
                      fontSize: responsive.dp(3.5).clamp(14, 16),
                      color: estado == 'inactivo' ? Colors.grey : Colors.black,
                      decoration: estado == 'inactivo'
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: estado == 'activo'
                      ? IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Desactivar institución'),
                                content: const Text(
                                  '¿Deseas marcar esta institución como inactiva?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmar == true) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await auth.desactivarInstitucion(
                                  user.uid,
                                  institucion['id'],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Institución '$nombre' marcada como inactiva.",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.autorenew,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Activar institución'),
                                content: const Text(
                                  '¿Deseas volver a activar esta institución?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmar == true) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await auth.activarInstitucion(
                                  user.uid,
                                  institucion['id'],
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Institución '$nombre' activada correctamente.",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
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
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () async {
                final nombre = _nuevaInstitucionController.text.trim();
                if (nombre.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await auth.agregarInstitucion(user.uid, nombre);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Institución '$nombre' agregada correctamente.",
                        ),
                      ),
                    );
                  }
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

  Future<void> _guardarCambios(Authentication auth) async {
    try {
      setState(() => _isSaving = true);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      // Actualizar datos en Authentication si hay cambios
      if (_correoController.text.trim() != user.email) {
        // await user.updateEmail(_correoController.text.trim());
      }
      if (_passwordController.text.trim().isNotEmpty &&
          _passwordController.text.trim() != auth.password) {
        await user.updatePassword(_passwordController.text.trim());
      }

      // Actualizar en Firestore
      final firestore = FirebaseFirestore.instance;
      final uid = user.uid;

      if (auth.tipoUsuario == "profesor") {
        await firestore.collection('profesores').doc(uid).update({
          'nombre': _nombreController.text,
          'apellidos': _apellidosController.text,
          'email': _correoController.text,
          'instituciones': auth.instituciones,
        });
      } else if (auth.tipoUsuario == "alumno") {
        await firestore.collection('alumnos').doc(uid).update({
          'nombre': _nombreController.text,
          'apellidos': _apellidosController.text,
          'email': _correoController.text,
        });
      }

      // 🔄 Recargar los datos actualizados desde la BD
      if (auth.tipoUsuario == "profesor") {
        await auth.cargarDatosProfesor(uid);
      } else if (auth.tipoUsuario == "alumno") {
        final doc = await firestore.collection('alumnos').doc(uid).get();
        if (doc.exists) {
          auth
            ..setNombre = doc['nombre'] ?? ''
            ..setApellidos = doc['apellidos'] ?? ''
            ..setEmail = doc['email'] ?? '';
        }
      }

      _cargarDatos(auth);
      _datosCargados = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cambios guardados correctamente.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar cambios: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _getIniciales(String nombre, String apellidos) {
    String inicialNombre = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    String inicialApellido = apellidos.isNotEmpty
        ? apellidos[0].toUpperCase()
        : '';
    return "$inicialNombre$inicialApellido";
  }
}
