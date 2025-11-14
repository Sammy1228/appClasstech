import 'package:appzacek/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProviderActividades extends ChangeNotifier {
  String _titulo = "";
  String _descripcion = "";
  String _url = "";
  String _clase = "";
  DateTime? _fechaEntrega;

  String get titulo => _titulo;
  String get descripcion => _descripcion;
  String get url => _url;
  String get clase => _clase;
  DateTime? get fechaEntrega => _fechaEntrega;

  set setTitulo(String titulo) {
    _titulo = titulo;
    notifyListeners();
  }

  set setDescripcion(String descripcion) {
    _descripcion = descripcion;
    notifyListeners();
  }

  set setUrl(String url) {
    _url = url;
    notifyListeners();
  }

  set setClase(String clase) {
    _clase = clase;
    notifyListeners();
  }

  set setFechaEntrega(DateTime? fechaEntrega) {
    _fechaEntrega = fechaEntrega;
    notifyListeners();
  }

  final DatabaseService _dbService = DatabaseService();

  //Método para crear actividad
  Future<void> createActivity() async {
    try {
      await _dbService.crearActividad(
        titulo: _titulo,
        descripcion: _descripcion,
        url: _url,
        clase: _clase,
        fechaEntrega: _fechaEntrega,
      );

      //limpiar campos
      _titulo = "";
      _descripcion = "";
      _url = "";
      _clase = "";
      _fechaEntrega = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Error al crear la actividad: $e');
    }
  }

  Stream<QuerySnapshot> obtenerActividadesStream() {
    try {
      final firestore = FirebaseFirestore.instance;
      // .snapshots() devuelve un Stream en tiempo real
      return firestore.collection('actividades').snapshots();
    } catch (e) {
      debugPrint("⚠️ Error al obtener stream de actividades: $e");
      throw Exception("No se pudo obtener el stream de actividades.");
    }
  }

  // 👇 --- MÉTODO NUEVO --- 👇
  // Obtiene stream de actividades filtradas por el nombre de la clase
  Stream<QuerySnapshot> obtenerActividadesStreamPorClase(String nombreClase) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('actividades')
          .where('clase', isEqualTo: nombreClase)
          .snapshots();
    } catch (e) {
      debugPrint("⚠️ Error al obtener stream de actividades por clase: $e");
      throw Exception("No se pudo obtener el stream de actividades.");
    }
  }

  // 👇 --- MÉTODO NUEVO --- 👇
  // Obtiene el stream de UN SOLO documento de actividad
  Stream<DocumentSnapshot> obtenerActividadStreamPorId(String actividadId) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore.collection('actividades').doc(actividadId).snapshots();
    } catch (e) {
      debugPrint("⚠️ Error al obtener stream de la actividad $actividadId: $e");
      throw Exception("No se pudo obtener el stream de la actividad.");
    }
  }

  // =======================================================
  // --- INICIO DE NUEVOS MÉTODOS PARA COMENTARIOS ---
  // =======================================================

  /// Obtiene los comentarios de una actividad
  Stream<QuerySnapshot> getComentariosActividadStream(String actividadId) {
    return FirebaseFirestore.instance
        .collection('actividades')
        .doc(actividadId)
        .collection('comentarios')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Envía un comentario a una actividad
  Future<void> enviarComentarioActividad({
    required String actividadId,
    required String uidUsuario,
    required String nombreUsuario,
    required String comentario,
  }) async {
    try {
      await _dbService.agregarComentarioActividad(actividadId, {
        'uidUsuario': uidUsuario,
        'nombreUsuario': nombreUsuario,
        'comentario': comentario,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al enviar comentario: $e");
      rethrow;
    }
  }
}
