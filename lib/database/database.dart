import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  //======================= Autenticación =======================

  // nuevo profesor (registro)
  Future<void> registroProfesor({
    required String uid,
    required String nombre,
    required String apellidos,
    required String email,
    required List<String> instituciones,
  }) async {
    await FirebaseFirestore.instance.collection('profesores').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'apellidos': apellidos,
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
    required String apellidos,
    required String email,
    required String carrera,
    required String semestre
  }) async {
    await FirebaseFirestore.instance.collection('alumnos').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'apellidos': apellidos,
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
    required String cicloEscolar,
    required String codigoAcceso,
  }) async {
    await FirebaseFirestore.instance.collection('clases').add({
      'titulo': titulo,
      'descripcion': descripcion,
      'nombreProfesor': nombreProfesor,
      'institucion': institucion,
      'carrera': carrera,
      'semestre': semestre,
      'cicloEscolar': cicloEscolar,
      'codigoAcceso': codigoAcceso,
    });
  }

  // Obtener clases por profesor
  Future<List<String>> obtenerClasesProfesor(String nombreProfesor) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clases')
        .where('nombreProfesor', isEqualTo: nombreProfesor)
        .get();

    return snapshot.docs.map((doc) => doc['titulo'] as String).toList();
  }



  //======================= Actividades =======================
  
  //Crear actividad
  Future<void> crearActividad({
    required String titulo,
    required String descripcion,
    required String url,
    required String clase,
    required DateTime? fechaEntrega,
  }) async {
    await FirebaseFirestore.instance.collection('actividades').add({
      'titulo': titulo,
      'descripcion': descripcion,
      'url': url,
      'clase': clase,
      'fechaEntrega': fechaEntrega
    });
  }

  
}
