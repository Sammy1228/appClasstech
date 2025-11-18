import 'package:appzacek/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProviderClases extends ChangeNotifier {
  String _titulo = "";
  String _descripcion = "";
  String _nombreProfesor = "";
  String _institucion = "";
  String _carrera = "";
  String _semestre = "";
  String _cicloEscolar = "";
  String _codigoAcceso = "";
  String _uidProfesor = ""; // ✅ Nuevo campo

  // Getters
  String get titulo => _titulo;
  String get descripcion => _descripcion;
  String get nombreProfesor => _nombreProfesor;
  String get institucion => _institucion;
  String get carrera => _carrera;
  String get semestre => _semestre;
  String get cicloEscolar => _cicloEscolar;
  String get codigoAcceso => _codigoAcceso;
  String get uidProfesor => _uidProfesor; // ✅ Getter

  // Setters
  set setTitulo(String titulo) {
    _titulo = titulo;
    notifyListeners();
  }

  set setDescripcion(String descripcion) {
    _descripcion = descripcion;
    notifyListeners();
  }

  set setNombreProfesor(String nombreProfesor) {
    _nombreProfesor = nombreProfesor;
    notifyListeners();
  }

  set setInstitucion(String institucion) {
    _institucion = institucion;
    notifyListeners();
  }

  set setCarrera(String carrera) {
    _carrera = carrera;
    notifyListeners();
  }

  set setSemestre(String semestre) {
    _semestre = semestre;
    notifyListeners();
  }

  set setCicloEscolar(String cicloEscolar) {
    _cicloEscolar = cicloEscolar;
    notifyListeners();
  }

  set setCodigoAcceso(String codigoAcceso) {
    _codigoAcceso = codigoAcceso;
    notifyListeners();
  }

  set setUidProfesor(String uid) {
    _uidProfesor = uid;
    notifyListeners();
  }

  final DatabaseService _dbService = DatabaseService();

  // Crear clase
  Future<void> createClass() async {
    try {
      await _dbService.crearClase(
        titulo: _titulo,
        descripcion: _descripcion,
        nombreProfesor: _nombreProfesor,
        institucion: _institucion,
        carrera: _carrera,
        semestre: _semestre,
        cicloEscolar: _cicloEscolar,
        codigoAcceso: _codigoAcceso,
        uidProfesor: _uidProfesor, // ✅ Se envía el UID del profesor
        alumnos: [],
      );

      // Limpiar campos
      _titulo = "";
      _descripcion = "";
      _nombreProfesor = "";
      _institucion = "";
      _carrera = "";
      _semestre = "";
      _cicloEscolar = "";
      _codigoAcceso = "";
      _uidProfesor = "";
      notifyListeners();
    } catch (e) {
      throw Exception('Error al crear la clase: $e');
    }
  }

  // Obtener clases del profesor actual
  Future<List<String>> getProfessorClasses(String nombreProfesor) async {
    return await _dbService.obtenerClasesProfesor(nombreProfesor);
  }

  // Unirse a clase
  Future<String> unirseAClase(String codigoClase, String uidUsuario) async {
    // --- LÓGICA MODIFICADA (Check de estado movido a database.dart) ---
    final resultado = await _dbService.agregarAlumnoAClase(
      codigoClase: codigoClase,
      uidAlumno: uidUsuario,
    );

    notifyListeners();
    return resultado;
  }

  Future<void> eliminarClasesPorInstitucion(String institucion) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final snapshot = await firestore
          .collection('clases')
          .where('institucion', isEqualTo: institucion)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint(
          "No hay clases para eliminar en la institución '$institucion'.",
        );
        return;
      }

      for (var doc in snapshot.docs) {
        await firestore.collection('clases').doc(doc.id).delete();
      }

      debugPrint("✅ Clases eliminadas correctamente para '$institucion'");
    } catch (e) {
      debugPrint("⚠️ Error al eliminar clases de '$institucion': $e");
      throw Exception(
        "No se pudieron eliminar las clases asociadas a la institución.",
      );
    }
  }

  Future<QuerySnapshot> obtenerClases() async {
    try {
      final firestore = FirebaseFirestore.instance;
      return await firestore.collection('clases').get();
    } catch (e) {
      debugPrint("⚠️ Error al obtener las clases!!!: $e");
      throw Exception("No se pudieron obtener las clases!!!.");
    }
  }

  Stream<QuerySnapshot> obtenerClasesStream() {
    try {
      final firestore = FirebaseFirestore.instance;
      // .snapshots() devuelve un Stream en tiempo real
      return firestore.collection('clases').snapshots();
    } catch (e) {
      debugPrint("⚠️ Error al obtener stream de clases: $e");
      throw Exception("No se pudo obtener el stream de clases.");
    }
  }

  // 👇 --- MÉTODO NUEVO --- 👇
  // Obtiene el stream de UN SOLO documento de clase
  Stream<DocumentSnapshot> obtenerClaseStreamPorId(String claseId) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore.collection('clases').doc(claseId).snapshots();
    } catch (e) {
      debugPrint("⚠️ Error al obtener stream de la clase $claseId: $e");
      throw Exception("No se pudo obtener el stream de la clase.");
    }
  }

  // ✅ Nuevo método: cambiar estado de clase
  Future<void> cambiarEstadoClase(String claseId, String nuevoEstado) async {
    try {
      await _dbService.actualizarEstadoClase(claseId, nuevoEstado);
      notifyListeners();
    } catch (e) {
      throw Exception("Error al cambiar el estado de la clase: $e");
    }
  }
  // 🆕 ELIMINAR UNA CLASE POR ID
Future<void> eliminarClase(String claseId) async {
  try {
    await FirebaseFirestore.instance
        .collection('clases')
        .doc(claseId)
        .delete();

    notifyListeners();
    debugPrint("✅ Clase eliminada correctamente: $claseId");
  } catch (e) {
    debugPrint("❌ Error al eliminar la clase: $e");
    throw Exception("Error al eliminar la clase: $e");
  }
}


  // =======================================================
  // --- INICIO DE NUEVOS MÉTODOS PARA RETROALIMENTACIÓN ---
  // =======================================================

  /// Obtiene la retroalimentación general de UNA clase
  Stream<QuerySnapshot> getRetroalimentacionClaseStream(String claseId) {
    return FirebaseFirestore.instance
        .collection('clases')
        .doc(claseId)
        .collection('retroalimentacion')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Envía retroalimentación a una clase
  Future<void> enviarRetroalimentacionClase({
    required String claseId,
    required String uidAlumno,
    required String nombreAlumno,
    required String comentario,
  }) async {
    try {
      await _dbService.agregarRetroClase(claseId, {
        'uidAlumno': uidAlumno,
        'nombreAlumno': nombreAlumno,
        'comentario': comentario,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al enviar retroalimentación: $e");
      rethrow;
    }
  }
}
