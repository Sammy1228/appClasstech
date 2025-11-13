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
    required String email
  }) async {
    await FirebaseFirestore.instance.collection('alumnos').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'tipoUsuario': 'alumno',
      'clases': [],
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }


// ======================= Clases =======================

// Crear clase
Future<void> crearClase({
  required String titulo,
  required String descripcion,
  required String nombreProfesor,
  required String institucion,
  required String carrera,
  required String semestre,
  required String cicloEscolar,
  required String codigoAcceso,
  required String uidProfesor,
  required List<String> alumnos,
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
    'uidProfesor': uidProfesor,
    'alumnos': alumnos,
    'estado': 'activo', // ✅ Nuevo campo por defecto
    'fechaCreacion': FieldValue.serverTimestamp(),
  });
}

// ✅ Nuevo método para actualizar el estado de la clase
Future<void> actualizarEstadoClase(String claseId, String nuevoEstado) async {
  try {
    await FirebaseFirestore.instance
        .collection('clases')
        .doc(claseId)
        .update({'estado': nuevoEstado});
  } catch (e) {
    print("⚠️ Error al actualizar estado de clase: $e");
    rethrow;
  }
}

  // Obtener clases por profesor
  Future<List<String>> obtenerClasesProfesor(String nombreProfesor) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('clases')
        .where('nombreProfesor', isEqualTo: nombreProfesor)
        .get();

    return snapshot.docs.map((doc) => doc['titulo'] as String).toList();
  }


 // Agregar alumno a clase por código de acceso
  Future<String> agregarAlumnoAClase({
    required String codigoClase,
    required String uidAlumno,
  }) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('clases')
          .where('codigoAcceso', isEqualTo: codigoClase)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return "no_existe";

      final claseDoc = query.docs.first;
      final claseId = claseDoc.id;
      final data = claseDoc.data();

      List<dynamic> alumnos = List.from(data['alumnos'] ?? []);

      if (alumnos.contains(uidAlumno)) return "ya_inscrito";

      // Agregar alumno a la clase
      alumnos.add(uidAlumno);
      await FirebaseFirestore.instance.collection('clases').doc(claseId).update({
        'alumnos': alumnos,
      });

      // Agregar clase al alumno
      final userRef = FirebaseFirestore.instance.collection('alumnos').doc(uidAlumno);
      await userRef.set({
        'clases': FieldValue.arrayUnion([claseId]),
      }, SetOptions(merge: true));

      return "ok";
    } catch (e) {
      print("Error en DatabaseService.agregarAlumnoAClase: $e");
      return "error";
    }
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
