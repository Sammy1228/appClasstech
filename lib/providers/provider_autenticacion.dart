import 'package:appzacek/database/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication extends ChangeNotifier{
  bool _isLoggedIn = false;
  String _nombre = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  String _tipoUsuario = "";
  String _carrera = "";
  String _semestre = "";
  List<String> _instituciones = [];

  bool get isLoggedIn => _isLoggedIn;
  String get nombre => _nombre;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get tipoUsuario => _tipoUsuario;
  String get carrera => _carrera;
  String get semestre => _semestre;
  List<String> get instituciones => _instituciones;

  set setNombre(String nombre){
    _nombre = nombre;
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

  set setCarrera(String carrera){
    _carrera = carrera;
  }

  set setSemestre(String semestre){
    _semestre = semestre;
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
          email: _email,
          instituciones: _instituciones,
        );
      }else if(_tipoUsuario.toLowerCase() == 'estudiante'){
        await _dbService.registroAlumno(
          uid: user.uid,
          nombre: _nombre,
          email: _email,
          carrera: _carrera,
          semestre: _semestre
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

  // cerrar sesión
  Future<void> logout() async{
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }
}