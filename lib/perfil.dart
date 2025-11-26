import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_autenticacion.dart';
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
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nuevaInstitucionCtrl = TextEditingController();
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
      if (auth.tipoUsuario == 'profesor')
        await auth.cargarDatosProfesor(user.uid);
      else
        await auth.cargarDatosAlumno(user.uid);

      setState(() {
        _nombreCtrl.text = auth.nombre;
        _apellidosCtrl.text = auth.apellidos;
        _correoCtrl.text = auth.email;
        _datosCargados = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Authentication>(context);
    final r = Responsive(context);

    if (auth.isLoggedIn && !_datosCargados) {
      _nombreCtrl.text = auth.nombre;
      _apellidosCtrl.text = auth.apellidos;
      _correoCtrl.text = auth.email;
      _datosCargados = true;
    }

    if (!auth.isLoggedIn)
      return const Scaffold(body: Center(child: Text("No autorizado")));

    return Scaffold(
      appBar: AppBar(
        // ✅ CORREGIDO: Fuente adaptable
        title: Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontSize: r.headerFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxFormWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.horizontalPadding),
            child: Column(
              children: [
                CircleAvatar(
                  radius: r.value(mobile: 50.0, desktop: 70.0),
                  backgroundColor: AppTheme.secondaryColor,
                  child: Text(
                    auth.nombre.isNotEmpty ? auth.nombre[0] : "U",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _nombreCtrl,
                  decoration: AppTheme.inputDecoration("Nombre"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _apellidosCtrl,
                  decoration: AppTheme.inputDecoration("Apellidos"),
                ),
                const SizedBox(height: 15),

                if (auth.tipoUsuario == "profesor") ...[
                  _institucionesList(context, auth),
                  const SizedBox(height: 15),
                ],

                TextField(
                  controller: _correoCtrl,
                  decoration: AppTheme.inputDecoration("Correo"),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordCtrl,
                  decoration: AppTheme.inputDecoration("Nueva Contraseña"),
                  obscureText: true,
                ),

                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  onPressed: _isSaving ? null : () => _guardar(auth),
                  child: const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _institucionesList(BuildContext context, Authentication auth) {
    return InputDecorator(
      decoration: AppTheme.inputDecoration("Instituciones"),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _addInst(context, auth),
              child: const Text("Agregar"),
            ),
          ),
          ...auth.instituciones.map(
            (i) => ListTile(
              title: Text(i['nombre']),
              trailing: IconButton(
                icon: Icon(
                  i['estado'] == 'activo' ? Icons.remove_circle : Icons.refresh,
                  color: i['estado'] == 'activo' ? Colors.red : Colors.green,
                ),
                onPressed: () => i['estado'] == 'activo'
                    ? auth.desactivarInstitucion(
                        FirebaseAuth.instance.currentUser!.uid,
                        i['id'],
                      )
                    : auth.activarInstitucion(
                        FirebaseAuth.instance.currentUser!.uid,
                        i['id'],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addInst(BuildContext context, Authentication auth) {
    _nuevaInstitucionCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar"),
        content: TextField(controller: _nuevaInstitucionCtrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              auth.agregarInstitucion(
                FirebaseAuth.instance.currentUser!.uid,
                _nuevaInstitucionCtrl.text,
              );
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar(Authentication auth) async {
    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (auth.tipoUsuario == 'profesor')
        await auth.cargarDatosProfesor(user.uid);
      else
        await auth.cargarDatosAlumno(user.uid);
    }
    setState(() => _isSaving = false);
  }
}
