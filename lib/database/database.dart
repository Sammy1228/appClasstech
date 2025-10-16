import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  //======================= Autenticación =======================

  // nuevo profesor (registro)
  Future<void> registroProfesor({
    required String uid,
    required String nombre,
    required String email,
    required List<String> instituciones,
  }) async {
    await FirebaseFirestore.instance.collection('profesores').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'tipoUsuario': 'profesor',
      'instituciones': instituciones,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // nuevo alumno (registro)
  Future<void> registroAlumno({
    required String uid,
    required String nombre,
    required String email,
    required String carrera,
    required String semestre
  }) async {
    await FirebaseFirestore.instance.collection('alumnos').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'tipoUsuario': 'alumno', 
      'carrera': carrera,
      'semestre': semestre,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }


  //======================= Clases =======================

  //Crear clase
  Future<void> crearClase({
    required String titulo,
    required String descripcion,
    required String nombreProfesor,
    required String institucion,
    required String carrera,
    required String semestre,
    required String codigoAcceso,
  }) async {
    await FirebaseFirestore.instance.collection('clases').add({
      'titulo': titulo,
      'descripcion': descripcion,
      'nombreProfesor': nombreProfesor,
      'institucion': institucion,
      'carrera': carrera,
      'semestre': semestre,
      'codigoAcceso': codigoAcceso,
    });
  }


}
