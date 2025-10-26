import 'package:appzacek/database/database.dart';
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
    try{
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
    }catch(e){
      throw Exception('Error al crear la actividad: $e');
    }
  }
}