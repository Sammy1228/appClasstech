import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/theme/app_theme.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:appzacek/Utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  bool _loading = true;
  bool _isProfessor = false;

  // Datos maestros
  List<Map<String, dynamic>> _misClases =
      []; // cada item: {id, titulo, institucion, carrera, semestre, ciclo, estado}
  List<String> _instituciones = [];
  List<String> _carreras = [];
  List<String> _semestres = [];
  List<String> _ciclos = [];

  // Filtros
  String? _filtroClaseId;
  String? _filtroInstitucion;
  String? _filtroCarrera;
  String? _filtroSemestre;
  String? _filtroCiclo;
  String _busqueda = '';

  // Tabla alumnos
  List<Map<String, dynamic>> _alumnos =
      []; // cada item: {uid, nombre, apellidos, email}
  int _totalAlumnos = 0;

  // Paginación simple
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  Future<void> _initLoad() async {
    final auth = Provider.of<Authentication>(context, listen: false);
    setState(() => _loading = true);
    try {
      _isProfessor = auth.tipoUsuario == 'profesor';

      if (!_isProfessor) {
        // No es profesor — no cargamos datos
        setState(() => _loading = false);
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      // Obtener las clases del profesor (solo activas por defecto)
      final q = await _fire
          .collection('clases')
          .where('uidProfesor', isEqualTo: uid)
          .get();

      // 🔹 Ordenamos manualmente por fecha de creación (descendente)
      final docs = q.docs;
      docs.sort((a, b) {
        final fechaA =
            (a['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime(0);
        final fechaB =
            (b['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime(0);
        return fechaB.compareTo(fechaA); // orden descendente
      });

      final clases = docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'titulo': data['titulo'] ?? 'Sin título',
          'descripcion': data['descripcion'] ?? 'Sin descripción',
          'institucion': data['institucion'] ?? 'Sin institución',
          'carrera': data['carrera'] ?? 'Sin carrera',
          'semestre': data['semestre'] ?? 'Sin semestre',
          'ciclo': data['cicloEscolar'] ?? 'Sin ciclo',
          'estado': data['estado'] ?? 'activo',
          'fechaCreacion': (data['fechaCreacion'] is Timestamp)
              ? (data['fechaCreacion'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(0),
        };
      }).toList();

      // 🔹 Asignar correctamente la lista
      _misClases = clases;

      // 🔹 Llenar listas de filtros (únicos)
      _instituciones = _misClases
          .map((c) => c['institucion'] as String)
          .toSet()
          .toList();
      _carreras = _misClases
          .map((c) => c['carrera'] as String)
          .toSet()
          .toList();
      _semestres = _misClases
          .map((c) => c['semestre'] as String)
          .toSet()
          .toList();
      _ciclos = _misClases.map((c) => c['ciclo'] as String).toSet().toList();

      // Estadísticas iniciales
      _totalAlumnos = 0;
      // por defecto seleccionar la primera clase activa si existe
      final primeraActiva = _misClases.firstWhere(
        (c) => c['estado'] == 'activo',
        orElse: () => (_misClases.isNotEmpty ? _misClases.first : {}),
      );
      if (primeraActiva != null && primeraActiva.isNotEmpty) {
        _filtroClaseId = primeraActiva['id'] as String?;
      }

      // Cargar alumnos para la clase seleccionada (si hay)
      if (_filtroClaseId != null) {
        await _cargarAlumnosDeClase(_filtroClaseId!);
      } else {
        _alumnos = [];
      }
    } catch (e, s) {
      debugPrint('Error initLoad ControlAlumnos: $e\n$s');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _cargarAlumnosDeClase(String claseId) async {
    setState(() {
      _loading = true;
      _alumnos = [];
      _currentPage = 0;
    });

    try {
      final doc = await _fire.collection('clases').doc(claseId).get();
      if (!doc.exists) {
        setState(() {
          _alumnos = [];
          _totalAlumnos = 0;
          _loading = false;
        });
        return;
      }

      final data = doc.data()!;
      final List<dynamic> alumnosUids = List<dynamic>.from(
        data['alumnos'] ?? [],
      );
      _totalAlumnos = alumnosUids.length;

      // Cargar datos de cada alumno (paralelo)
      final futures = alumnosUids.map(
        (uid) => _fire.collection('alumnos').doc(uid.toString()).get(),
      );
      final snapshots = await Future.wait(futures);

      final alumnosFull = <Map<String, dynamic>>[];
      for (final s in snapshots) {
        if (!s.exists) continue;
        final d = s.data()!;
        alumnosFull.add({
          'uid': s.id,
          'nombre': d['nombre'] ?? '',
          'apellidos': d['apellidos'] ?? '',
          'email': d['email'] ?? '',
        });
      }

      // Aplicar busqueda local (nombre, apellidos, email)
      final filtered = _aplicarBusquedaYFiltrosALumnos(alumnosFull);

      setState(() {
        _alumnos = filtered;
        _totalAlumnos = alumnosFull.length;
      });
    } catch (e, s) {
      debugPrint('Error cargarAlumnosDeClase: $e\n$s');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar alumnos: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _aplicarBusquedaYFiltrosALumnos(
    List<Map<String, dynamic>> source,
  ) {
    final q = _busqueda.trim().toLowerCase();
    return source.where((a) {
      if (q.isNotEmpty) {
        final match =
            (a['nombre'] as String).toLowerCase().contains(q) ||
            (a['apellidos'] as String).toLowerCase().contains(q) ||
            (a['email'] as String).toLowerCase().contains(q);
        return match;
      }
      return true;
    }).toList();
  }

  // Aplicar filtros sobre las clases (no sobre alumnos)
  List<Map<String, dynamic>> _clasesFiltradas() {
    return _misClases.where((c) {
      if (_filtroClaseId != null && _filtroClaseId!.isNotEmpty) {
        // si se filtró por clase exacta, solo esa
        if (c['id'] != _filtroClaseId) return false;
      }
      if (_filtroInstitucion != null && _filtroInstitucion!.isNotEmpty) {
        if ((c['institucion'] ?? '') != _filtroInstitucion) return false;
      }
      if (_filtroCarrera != null && _filtroCarrera!.isNotEmpty) {
        if ((c['carrera'] ?? '') != _filtroCarrera) return false;
      }
      if (_filtroSemestre != null && _filtroSemestre!.isNotEmpty) {
        if ((c['semestre'] ?? '') != _filtroSemestre) return false;
      }
      if (_filtroCiclo != null && _filtroCiclo!.isNotEmpty) {
        if ((c['ciclo'] ?? '') != _filtroCiclo) return false;
      }
      // Solo clases activas (la pantalla pide "inscritos a las clases que este profesor haya creado y que actualmente esten activas")
      if ((c['estado'] ?? 'activo') != 'activo') return false;
      return true;
    }).toList();
  }

  void _onFiltroClaseChanged(String? id) async {
    _filtroClaseId = id;
    if (id != null) {
      await _cargarAlumnosDeClase(id);
    } else {
      setState(() {
        _alumnos = [];
        _totalAlumnos = 0;
      });
    }
  }

  void _onBuscarChanged(String v) {
    setState(() {
      _busqueda = v;
      // re-aplicar búsqueda sobre alumnos ya cargados
      _alumnos = _aplicarBusquedaYFiltrosALumnos(_alumnos);
    });
  }

  // Refrescar todo
  Future<void> _refreshAll() async {
    await _initLoad();
  }

  // Paginación: obtener subset
  List<Map<String, dynamic>> get _alumnosPagina {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _alumnos.length);
    if (start >= _alumnos.length) return [];
    return _alumnos.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    // ✅ CAMBIO: Aplicado clamp()
    final textSize = r.dp(3.6).clamp(13, 16).toDouble();
    final titleSize = r.dp(4.5).clamp(16, 20).toDouble();

    // Si no es profesor: mostrar mensaje
    if (!_loading && !_isProfessor) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: const Text('Control de alumnos'),
          iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        ),
        drawer: const CustomDrawer(),
        body: Center(
          child: Text(
            'Esta pantalla solo está disponible para profesores.',
            style: TextStyle(fontSize: textSize),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Control de alumnos',
          style: TextStyle(
            fontSize: titleSize,
            color: AppTheme.backgroundColor,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAll,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        // ✅ CAMBIO: Aplicado clamp()
        padding: EdgeInsets.all(r.wp(3).clamp(12, 20)),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ CAMBIO: Reemplazado Rows por Wrap
                  Wrap(
                    spacing: r.wp(2).clamp(10, 16), // Espacio horizontal
                    runSpacing: r.hp(1.5).clamp(10, 14), // Espacio vertical
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _filtroClaseId,
                          decoration: AppTheme.inputDecoration(
                            'Clase (título)',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas las clases'),
                            ),
                            ..._misClases.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['id'] as String,
                                child: Text(
                                  '${c['titulo']} (${c['institucion']})',
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (v) => _onFiltroClaseChanged(v),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _filtroInstitucion,
                          decoration: AppTheme.inputDecoration('Institución'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas'),
                            ),
                            ..._instituciones.map(
                              (i) => DropdownMenuItem(value: i, child: Text(i)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _filtroInstitucion = v);
                          },
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _filtroCarrera,
                          decoration: AppTheme.inputDecoration('Carrera'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas'),
                            ),
                            ..._carreras.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _filtroCarrera = v);
                          },
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _filtroSemestre,
                          decoration: AppTheme.inputDecoration('Semestre'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ..._semestres.map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _filtroSemestre = v);
                          },
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _filtroCiclo,
                          decoration: AppTheme.inputDecoration(
                            'Periodo (Ciclo)',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ..._ciclos.map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => _filtroCiclo = v);
                          },
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 250,
                          maxWidth: 350,
                        ),
                        child: TextField(
                          decoration: AppTheme.inputDecoration(
                            'Buscar alumno (nombre/apellidos/email)',
                          ),
                          onChanged: (v) {
                            _onBuscarChanged(v);
                          },
                        ),
                      ),
                    ],
                  ),

                  // ✅ CAMBIO: Aplicado clamp()
                  SizedBox(height: r.hp(2).clamp(16, 24)),

                  // --- Estadísticas ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Clases totales: ${_misClases.length}',
                        style: TextStyle(fontSize: textSize),
                      ),
                      Text(
                        'Clases visibles: ${_clasesFiltradas().length}',
                        style: TextStyle(fontSize: textSize),
                      ),
                      Text(
                        'Alumnos (clase seleccionada): $_totalAlumnos',
                        style: TextStyle(fontSize: textSize),
                      ),
                    ],
                  ),

                  // ✅ CAMBIO: Aplicado clamp()
                  SizedBox(height: r.hp(1).clamp(8, 12)),

                  // --- Tabla de alumnos ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(r.wp(2).clamp(8, 16)),
                      child: Column(
                        children: [
                          // Tabla encabezado
                          Expanded(
                            child: _alumnos.isEmpty
                                ? Center(
                                    child: Text(
                                      'No hay alumnos para la clase seleccionada.',
                                      style: TextStyle(fontSize: textSize),
                                    ),
                                  )
                                // ✅ CAMBIO: Añadido SingleChildScrollView horizontal
                                : SingleChildScrollView(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                              AppTheme.primaryColor,
                                            ),
                                        headingTextStyle: TextStyle(
                                          color: AppTheme.backgroundColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        columns: [
                                          DataColumn(
                                            label: Text(
                                              'Nombre',
                                              style: TextStyle(
                                                fontSize: textSize,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Apellidos',
                                              style: TextStyle(
                                                fontSize: textSize,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Email',
                                              style: TextStyle(
                                                fontSize: textSize,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: _alumnosPagina.map((a) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  a['nombre'] ?? '-',
                                                  style: TextStyle(
                                                    fontSize: textSize,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  a['apellidos'] ?? '-',
                                                  style: TextStyle(
                                                    fontSize: textSize,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  a['email'] ?? '-',
                                                  style: TextStyle(
                                                    fontSize: textSize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                          ),

                          // Paginador simple
                          if (_alumnos.isNotEmpty)
                            Padding(
                              // ✅ CAMBIO: Aplicado clamp()
                              padding: EdgeInsets.only(
                                top: r.hp(1).clamp(8, 12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mostrando ${_alumnosPagina.length} de ${_alumnos.length}',
                                    style: TextStyle(fontSize: textSize - 1),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _currentPage > 0
                                            ? () =>
                                                  setState(() => _currentPage--)
                                            : null,
                                        icon: const Icon(Icons.arrow_back_ios),
                                      ),
                                      Text(
                                        '${_currentPage + 1}',
                                        style: TextStyle(fontSize: textSize),
                                      ),
                                      IconButton(
                                        onPressed:
                                            (_currentPage + 1) * _rowsPerPage <
                                                _alumnos.length
                                            ? () =>
                                                  setState(() => _currentPage++)
                                            : null,
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
