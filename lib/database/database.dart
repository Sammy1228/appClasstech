import 'package:cloud_firestore/cloud_firestore.dart';
// --- IMPORTACIONES DE STORAGE ELIMINADAS ---
import 'dart:io';
// --- file_picker y kIsWeb ya no son necesarios aquí ---

class DatabaseService {
  // ======================= Autenticación =======================
  // (Tu código existente de registroProfesor y registroAlumno va aquí)

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
  // (Tu código existente de crearClase, actualizarEstadoClase, etc. va aquí)

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
      await FirebaseFirestore.instance.collection('clases').doc(claseId).update(
        {'estado': nuevoEstado},
      );
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

      // --- LÓGICA EXISTENTE MODIFICADA (Check de estado) ---
      if (data['estado'] == 'inactivo') {
        return "clase_inactiva";
      }
      // --- FIN MODIFICACIÓN ---

      List<dynamic> alumnos = List.from(data['alumnos'] ?? []);

      if (alumnos.contains(uidAlumno)) return "ya_inscrito";

      // Agregar alumno a la clase
      alumnos.add(uidAlumno);
      await FirebaseFirestore.instance.collection('clases').doc(claseId).update(
        {'alumnos': alumnos},
      );

      // Agregar clase al alumno
      final userRef = FirebaseFirestore.instance
          .collection('alumnos')
          .doc(uidAlumno);
      await userRef.set({
        'clases': FieldValue.arrayUnion([claseId]),
      }, SetOptions(merge: true));

      return "ok";
    } catch (e) {
      print("Error en DatabaseService.agregarAlumnoAClase: $e");
      return "error";
    }
  }

  // ======================= Actividades =======================
  // (Tu código existente de crearActividad va aquí)

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
      'fechaEntrega': fechaEntrega,
    });
  }

  // =======================================================
  // --- INICIO DE NUEVOS MÉTODOS PARA ENTREGAS/COMENTARIOS ---
  // =======================================================

  // --- SE HAN ELIMINADO LAS FUNCIONES DE STORAGE ---

  // --- ENTREGAS (FIRESTORE) ---

  /// Crea o actualiza el documento de entrega de un alumno
  Future<void> guardarEntrega(
    String actividadId,
    String uidAlumno,
    String nombreAlumno,
    String claseNombre,
    List<Map<String, dynamic>> archivos,
  ) async {
    // <-- TIPO DE DATO CAMBIADO
    final firestore = FirebaseFirestore.instance;
    // Buscamos si ya existe una entrega para este alumno y actividad
    final query = await firestore
        .collection('entregas')
        .where('actividadId', isEqualTo: actividadId)
        .where('uidAlumno', isEqualTo: uidAlumno)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Si existe, actualizamos los archivos (permite re-entregar)
      final docId = query.docs.first.id;
      await firestore.collection('entregas').doc(docId).update({
        'archivos': FieldValue.arrayUnion(archivos), // Agrega los nuevos
        'fechaEntrega': FieldValue.serverTimestamp(),
        'estado': 'entregado',
      });
    } else {
      // Si no existe, creamos un nuevo documento de entrega
      await firestore.collection('entregas').add({
        'actividadId': actividadId,
        'uidAlumno': uidAlumno,
        'nombreAlumno': nombreAlumno,
        'claseNombre': claseNombre, // Guardamos el nombre de la clase
        'fechaEntrega': FieldValue.serverTimestamp(),
        'estado': 'entregado',
        'archivos': archivos, // <-- Aquí se guardan los Blobs
        'calificacion': null,
        'comentarioProfesor': null,
      });
    }
  }

  /// Califica una entrega (Profesor)
  Future<void> calificarEntrega(
    String entregaId,
    int calificacion,
    String comentario,
  ) async {
    await FirebaseFirestore.instance
        .collection('entregas')
        .doc(entregaId)
        .update({
          'calificacion': calificacion,
          'comentarioProfesor': comentario,
          'estado': 'calificado',
        });
  }

  // --- COMENTARIOS (Actividad) ---
  // (Tu código existente de agregarComentarioActividad va aquí)

  /// Agrega un comentario a la subcolección de una actividad
  Future<void> agregarComentarioActividad(
    String actividadId,
    Map<String, dynamic> comentarioData,
  ) async {
    await FirebaseFirestore.instance
        .collection('actividades')
        .doc(actividadId)
        .collection('comentarios')
        .add(comentarioData);
  }

  // --- RETROALIMENTACIÓN (Clase) ---
  // (Tu código existente de agregarRetroClase va aquí)

  /// Agrega retroalimentación a la subcolección de una clase
  Future<void> agregarRetroClase(
    String claseId,
    Map<String, dynamic> retroData,
  ) async {
    await FirebaseFirestore.instance
        .collection('clases')
        .doc(claseId)
        .collection('retroalimentacion')
        .add(retroData);
  }
}
