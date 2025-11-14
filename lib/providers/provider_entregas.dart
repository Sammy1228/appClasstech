// ignore_for_file: avoid_print
import 'dart:io';
import 'package:appzacek/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- IMPORTACIÓN DE STORAGE ELIMINADA ---
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ProviderEntregas extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // --- ESTADO DE PROGRESO SIMPLIFICADO ---
  bool _isUploading = false;
  bool get isUploading => _isUploading;
  // --- Se eliminaron uploadProgress y uploadStatus ---

  void _setLoading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  /// Convierte archivos y los guarda en Firestore
  Future<void> subirEvidencia({
    required List<PlatformFile> archivos,
    required String actividadId,
    required String uidAlumno,
    required String nombreAlumno,
    required String claseNombre,
  }) async {
    _setLoading(true);

    try {
      final List<Map<String, dynamic>> archivosParaGuardar = [];
      int totalSize = 0;

      // 1. Calcular tamaño total y preparar los archivos
      for (final archivo in archivos) {
        if (archivo.bytes == null) {
          throw Exception("Error al leer el archivo ${archivo.name}");
        }
        totalSize += archivo.size;

        archivosParaGuardar.add({
          'nombre': archivo.name,
          'tipo': archivo.extension ?? 'desconocido',
          'size': archivo.size, // Guardamos el tamaño
          'bytes': Blob(archivo.bytes!), // Guardamos los bytes como Blob
        });
      }

      // 2. Comprobar el límite de 1 MiB
      // (1,000,000 bytes para darnos un pequeño margen)
      if (totalSize > 1000000) {
        throw Exception(
          "Error: El tamaño total (${(totalSize / 1000000).toStringAsFixed(2)} MB) supera el límite de 1 MB.",
        );
      }

      // 3. Guardar la data en Firestore
      await _dbService.guardarEntrega(
        actividadId,
        uidAlumno,
        nombreAlumno,
        claseNombre,
        archivosParaGuardar,
      );
    } catch (e) {
      print("Error en ProviderEntregas.subirEvidencia: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Califica la entrega de un alumno
  Future<void> calificarEntrega({
    required String entregaId,
    required int calificacion,
    required String comentario,
  }) async {
    _setLoading(true); // Reusamos el loading state
    notifyListeners();
    try {
      await _dbService.calificarEntrega(entregaId, calificacion, comentario);
    } catch (e) {
      print("Error en ProviderEntregas.calificarEntrega: $e");
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // --- STREAMS (Para la UI) ---

  /// Obtiene la entrega específica de UN alumno para UNA actividad
  Stream<DocumentSnapshot?> getMiEntregaStream(
    String actividadId,
    String uidAlumno,
  ) {
    try {
      final stream = FirebaseFirestore.instance
          .collection('entregas')
          .where('actividadId', isEqualTo: actividadId)
          .where('uidAlumno', isEqualTo: uidAlumno)
          .limit(1)
          .snapshots();

      // Mapeamos para devolver solo el documento (o null si está vacío)
      return stream.map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }
        return snapshot.docs.first;
      });
    } catch (e) {
      print("Error al obtener stream de mi entrega: $e");
      return Stream.value(null);
    }
  }

  /// Obtiene TODAS las entregas de UNA actividad (para el profesor)
  Stream<QuerySnapshot> getEntregasPorActividadStream(String actividadId) {
    return FirebaseFirestore.instance
        .collection('entregas')
        .where('actividadId', isEqualTo: actividadId)
        .snapshots();
  }

  /// Obtiene el stream de UNA entrega específica por su ID (para calificar)
  Stream<DocumentSnapshot> getEntregaPorIdStream(String entregaId) {
    return FirebaseFirestore.instance
        .collection('entregas')
        .doc(entregaId)
        .snapshots();
  }
}
