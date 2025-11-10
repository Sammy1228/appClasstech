import 'package:appzacek/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _nombre = "";
  String _apellidos = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _tipoUsuario = "";
  List<Map<String, dynamic>> _instituciones = []; // ← cambia a lista de mapas

  bool get isLoggedIn => _isLoggedIn;
  String get nombre => _nombre;
  String get apellidos => _apellidos;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get tipoUsuario => _tipoUsuario;
  List<Map<String, dynamic>> get instituciones => _instituciones;

  set setNombre(String nombre) => _nombre = nombre;
  set setApellidos(String apellidos) => _apellidos = apellidos;
  set setEmail(String email) => _email = email;
  set setPassword(String password) => _password = password;
  set setConfirmPassword(String confirmPassword) => _confirmPassword = confirmPassword;
  set setTipoUsuario(String tipoUsuario) => _tipoUsuario = tipoUsuario;

  set setInstituciones(List<Map<String, dynamic>> instituciones) {
    _instituciones = instituciones;
    notifyListeners();
  }

  final DatabaseService _dbService = DatabaseService();

  // Registro con correo y contraseña
Future<User?> register() async {
  try {
    if (_password != _confirmPassword) {
      throw Exception("Las contraseñas no coinciden");
    }

    // 🔹 Crear usuario en Firebase Authentication
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password);

    final user = credential.user;
    if (user == null) throw Exception("Error al crear la cuenta");

    // 🔹 Si el usuario es profesor
    if (_tipoUsuario.toLowerCase() == 'profesor') {
      // 🔸 Procesamos las instituciones
      final instituciones = _instituciones.map((inst) {
        if (inst is Map<String, dynamic>) return inst['nombre'] ?? '';
        if (inst is String) return inst;
        return '';
      }).where((s) => s.trim().isNotEmpty).toList();

      // 🔹 Crear documento principal del profesor SIN el campo de instituciones
      await FirebaseFirestore.instance.collection('profesores').doc(user.uid).set({
        'nombre': _nombre,
        'apellidos': _apellidos,
        'email': _email,
        'tipoUsuario': _tipoUsuario,
      });

      // 🔹 Crear subcolección "instituciones" (una por una)
      final institucionesRef = FirebaseFirestore.instance
          .collection('profesores')
          .doc(user.uid)
          .collection('instituciones');

      for (final nombre in instituciones) {
        await institucionesRef.add({
          'nombre': nombre,
          'estado': 'activo',
        });
      }

      // 🔹 Cargar datos del profesor recién creado
      await cargarDatosProfesor(user.uid);
      _tipoUsuario = 'profesor';
    }

    // 🔹 Si el usuario es alumno
    else if (_tipoUsuario.toLowerCase() == 'alumno' ||
        _tipoUsuario.toLowerCase() == 'estudiante') {
      await FirebaseFirestore.instance.collection('alumnos').doc(user.uid).set({
        'nombre': _nombre,
        'apellidos': _apellidos,
        'email': _email,
        'tipoUsuario': _tipoUsuario,
      });

      await cargarDatosAlumno(user.uid);
      _tipoUsuario = 'alumno';
    }

    // 🔹 Si el tipo de usuario no es válido
    else {
      throw Exception("Tipo de usuario no válido");
    }

    _isLoggedIn = true;
    notifyListeners();
    return user;

  } on FirebaseAuthException catch (e) {
    _isLoggedIn = false;
    if (e.code == 'weak-password') {
      throw Exception('La contraseña es demasiado débil.');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('El correo ya está en uso.');
    } else {
      throw Exception('Error de autenticación: ${e.message}');
    }
  } catch (e) {
    _isLoggedIn = false;
    return Future.error("Error en el registro: $e");
  }
}



  // Inicio de sesión
  Future<User?> login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      final user = credential.user;
      if (user == null) throw Exception("Correo o contraseña incorrectos");

      final docProfesor =
          await FirebaseFirestore.instance.collection('profesores').doc(user.uid).get();
      final docAlumno =
          await FirebaseFirestore.instance.collection('alumnos').doc(user.uid).get();

      if (docProfesor.exists) {
        _tipoUsuario = 'profesor';
        await cargarDatosProfesor(user.uid);
      } else if (docAlumno.exists) {
        _tipoUsuario = 'alumno';
        await cargarDatosAlumno(user.uid);
      } else {
        throw Exception("Usuario no encontrado en la base de datos");
      }

      _isLoggedIn = true;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoggedIn = false;
      _tipoUsuario = '';
      throw Exception("Error al iniciar sesión: $e");
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    _tipoUsuario = '';
    notifyListeners();
  }

  /// 🔹 Cargar datos de profesor y sus instituciones (solo activas o todas)
  Future<void> cargarDatosProfesor(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('profesores').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      _nombre = doc['nombre'] ?? '';
      _apellidos = doc['apellidos'] ?? '';
      _email = doc['email'] ?? '';

      // cargar subcolección de instituciones
      final snapshot = await docRef.collection('instituciones').get();
      _instituciones = snapshot.docs.map((d) {
        return {
          'id': d.id,
          'nombre': d['nombre'],
          'estado': d['estado'],
        };
      }).toList();

      notifyListeners();
    }
  }

  Future<void> cargarDatosAlumno(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('alumnos').doc(uid).get();
    if (doc.exists) {
      _nombre = doc['nombre'] ?? '';
      _apellidos = doc['apellidos'] ?? '';
      _email = doc['email'] ?? '';
      notifyListeners();
    }
  }

  /// 🔹 Agregar nueva institución
  Future<void> agregarInstitucion(String uid, String nombre) async {
    final docRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(uid)
        .collection('instituciones')
        .doc();

    await docRef.set({'nombre': nombre, 'estado': 'activo'});

    _instituciones.add({'id': docRef.id, 'nombre': nombre, 'estado': 'activo'});
    notifyListeners();
  }

  /// 🔹 Marcar institución como inactiva
  Future<void> desactivarInstitucion(String uid, String id) async {
    final instRef = FirebaseFirestore.instance
        .collection('profesores')
        .doc(uid)
        .collection('instituciones')
        .doc(id);

    await instRef.update({'estado': 'inactivo'});

    final index = _instituciones.indexWhere((i) => i['id'] == id);
    if (index != -1) _instituciones[index]['estado'] = 'inactivo';
    notifyListeners();
  }
}
