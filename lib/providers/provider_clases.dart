import 'package:appzacek/database/database.dart';
import 'package:flutter/material.dart';

class ProviderClases extends ChangeNotifier{
  String _titulo = "";
  String _descripcion = "";
  String _nombreProfesor = "";
  String _institucion = "";
  String _carrera = "";
  String _semestre = "";
  String _codigoAcceso = "";


  String get titulo => _titulo;
  String get descripcion => _descripcion;
  String get nombreProfesor => _nombreProfesor;
  String get institucion => _institucion;
  String get carrera => _carrera;
  String get semestre => _semestre;
  String get codigoAcceso => _codigoAcceso;

  set setTitulo(String titulo){
    _titulo = titulo;
    notifyListeners();
  }

  set setDescripcion(String descripcion){
    _descripcion = descripcion;
    notifyListeners();
  }

  set setNombreProfesor(String nombreProfesor){
    _nombreProfesor = nombreProfesor;
    notifyListeners();
  }

  set setInstitucion(String institucion){
    _institucion = institucion;
    notifyListeners();
  }

  set setCarrera(String carrera){
    _carrera = carrera;
    notifyListeners();
  }

  set setSemestre(String semestre){
    _semestre = semestre;
    notifyListeners();
  }

  set setCodigoAcceso(String codigoAcceso){
    _codigoAcceso = codigoAcceso;
    notifyListeners();
  }

  final DatabaseService _dbService = DatabaseService();
  
  //Crear clase
  Future<void> createClass() async{
    try{
      await _dbService.crearClase(
        titulo: _titulo,
        descripcion: _descripcion,
        nombreProfesor: _nombreProfesor,
        institucion: _institucion,
        carrera: _carrera,
        semestre: _semestre,
        codigoAcceso: _codigoAcceso,
      );

      // Limpiar campos
    _titulo = "";
    _descripcion = "";
    _nombreProfesor = "";
    _institucion = "";
    _carrera = "";
    _semestre = "";
    _codigoAcceso = "";
    notifyListeners();
    }catch(e){
      throw Exception('Error al crear la clase: $e');
    }
  }

  // Obtener clases del profesor actual
  Future<List<String>> getProfessorClasses(String nombreProfesor) async {
    return await _dbService.obtenerClasesProfesor(nombreProfesor);
  } 
}