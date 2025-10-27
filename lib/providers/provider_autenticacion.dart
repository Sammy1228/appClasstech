import 'package:appzacek/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication extends ChangeNotifier{
  bool _isLoggedIn = false;
  String _nombre = "";
  String _apellidos = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _tipoUsuario = "";
  List<String> _instituciones = [];

  bool get isLoggedIn => _isLoggedIn;
  String get nombre => _nombre;
  String get apellidos => _apellidos;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get tipoUsuario => _tipoUsuario;
  List<String> get instituciones => _instituciones;

  set setNombre(String nombre){
    _nombre = nombre;
  }

  set setApellidos(String apellidos){
    _apellidos = apellidos;
  }

  set setEmail(String email){
    _email = email;
  }

  set setPassword(String password){
    _password = password;
  }

  set setConfirmPassword(String confirmPassword){
    _confirmPassword = confirmPassword;
  }

  set setTipoUsuario(String tipoUsuario){
    _tipoUsuario = tipoUsuario;
  }

  set setInstituciones(List<String> instituciones){
    _instituciones = instituciones;
    notifyListeners();
  }


  final DatabaseService _dbService = DatabaseService();
  
  //Registro con correo y contraseña
  Future<User?> register() async{
    try{
      // verificar que las contraseñas coincidan
      if(_password != _confirmPassword){
        throw Exception("Las contraseñas no coinciden");
      }

      //crear usuario
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: password);

      final user = credential.user;
      if(user == null) return null;

      //validar tipo de usuario
      if(_tipoUsuario.toLowerCase() == 'profesor'){
        await _dbService.registroProfesor(
          uid: user.uid,
          nombre: _nombre,
          apellidos: _apellidos,
          email: _email,
          instituciones: _instituciones,
        );
      }else if(_tipoUsuario.toLowerCase() == 'estudiante'){
        await _dbService.registroAlumno(
          uid: user.uid,
          nombre: _nombre,
          apellidos: _apellidos,
          email: _email,
        );
      } else{
        throw Exception("Tipo de usuario no válido");
      }

      //actualizar estado
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
      return Future.error(e.toString());
    }
  }


  //Inicio de sesión 
Future<User?> login() async {
    try {
      print("Intentando iniciar sesión con $_email");
      _tipoUsuario = ''; // limpiar tipo antes del intento

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password,
      );

      final user = credential.user;
      print("Usuario obtenido: $user");
      if (user == null) throw Exception("Correo o contraseña incorrectos");

      // Buscar tipo de usuario en Firestore
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('profesores').doc(user.uid).get(),
        FirebaseFirestore.instance.collection('alumnos').doc(user.uid).get(),
      ]);

      final docProfesor = results[0];
      final docAlumno = results[1];

if (docProfesor.exists) {
  _tipoUsuario = 'profesor';
  await cargarDatosProfesor(user.uid);
} else if (docAlumno.exists) {
  _tipoUsuario = 'alumno';
  await cargarDatosAlumno(user.uid);
}else {
        throw Exception("Usuario no encontrado en la base de datos");
      }

      _isLoggedIn = true;
      notifyListeners();
      return user;
    } on FirebaseAuthException catch (e) {
      _isLoggedIn = false;
      _tipoUsuario = ''; // limpiar al fallar
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception("Correo o contraseña incorrectos");
      } else {
        throw Exception("Error de autenticación: ${e.message}");
      }
    } catch (e) {
      _isLoggedIn = false;
      _tipoUsuario = '';
      throw Exception("Error de autenticación: ${e.toString()}"); // <-- Lanza la excepción
    }
  }



  // cerrar sesión
  Future<void> logout() async{
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    _tipoUsuario = '';
    notifyListeners();
  }

  Future<void> cargarDatosProfesor(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('profesores').doc(uid).get();
    if (doc.exists) {
      _nombre = doc['nombre'] ?? '';
      _apellidos = doc['apellidos'] ?? '';
      _instituciones = List<String>.from(doc['instituciones'] ?? []);
       _email = doc['email'] ?? '';
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
}