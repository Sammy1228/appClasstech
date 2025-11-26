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
  List<Map<String, dynamic>> _misClases = [];
  List<String> _instituciones = [];
  List<String> _carreras = [];
  List<String> _semestres = [];
  List<String> _ciclos = [];
  String? _filtroClaseId;
  String? _filtroInstitucion;
  String? _filtroCarrera;
  String? _filtroSemestre;
  String? _filtroCiclo;
  String _busqueda = '';
  List<Map<String, dynamic>> _alumnos = [];
  int _totalAlumnos = 0;
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
        setState(() => _loading = false);
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('No auth');

      final q = await _fire
          .collection('clases')
          .where('uidProfesor', isEqualTo: uid)
          .get();
      final docs = q.docs;
      docs.sort(
        (a, b) => ((b['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime(0))
            .compareTo(
              (a['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime(0),
            ),
      );

      _misClases = docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'titulo': data['titulo'] ?? 'Sin título',
          'institucion': data['institucion'] ?? '',
          'carrera': data['carrera'] ?? '',
          'semestre': data['semestre'] ?? '',
          'ciclo': data['cicloEscolar'] ?? '',
          'estado': data['estado'] ?? 'activo',
        };
      }).toList();

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

      final primeraActiva = _misClases.firstWhere(
        (c) => c['estado'] == 'activo',
        orElse: () => _misClases.isNotEmpty ? _misClases.first : {},
      );
      if (primeraActiva.isNotEmpty)
        _filtroClaseId = primeraActiva['id'] as String?;

      if (_filtroClaseId != null)
        await _cargarAlumnos(_filtroClaseId!);
      else
        _alumnos = [];
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cargarAlumnos(String claseId) async {
    setState(() {
      _loading = true;
      _alumnos = [];
      _currentPage = 0;
    });
    try {
      final doc = await _fire.collection('clases').doc(claseId).get();
      if (!doc.exists) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final uids = List<dynamic>.from(doc.data()!['alumnos'] ?? []);
      _totalAlumnos = uids.length;

      final futures = uids.map(
        (uid) => _fire.collection('alumnos').doc(uid.toString()).get(),
      );
      final snaps = await Future.wait(futures);

      final temp = <Map<String, dynamic>>[];
      for (final s in snaps) {
        if (!s.exists) continue;
        final d = s.data()!;
        temp.add({
          'uid': s.id,
          'nombre': d['nombre'] ?? '',
          'apellidos': d['apellidos'] ?? '',
          'email': d['email'] ?? '',
        });
      }

      setState(() {
        _alumnos = _filtrarLista(temp);
        _totalAlumnos = temp.length;
      });
    } catch (e) {
      // Error
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _filtrarLista(List<Map<String, dynamic>> source) {
    final q = _busqueda.trim().toLowerCase();
    return source
        .where(
          (a) =>
              q.isEmpty ||
              a['nombre'].toLowerCase().contains(q) ||
              a['email'].toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    if (!_loading && !_isProfessor) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Control'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(child: Text('Solo profesores')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        // ✅ CORREGIDO: Fuente adaptable
        title: Text(
          'Control de alumnos',
          style: TextStyle(
            fontSize: r.headerFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initLoad),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(r.horizontalPadding),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _dropdown(
                            "Clase",
                            _misClases
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c['id'].toString(),
                                    child: Text('${c['titulo']}'),
                                  ),
                                )
                                .toList(),
                            _filtroClaseId,
                            (v) => _cargarAlumnos(v!),
                          ),
                          _dropdown(
                            "Institución",
                            [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todas'),
                              ),
                              ..._instituciones.map(
                                (i) =>
                                    DropdownMenuItem(value: i, child: Text(i)),
                              ),
                            ],
                            _filtroInstitucion,
                            (v) => setState(() => _filtroInstitucion = v),
                          ),
                          SizedBox(
                            width: 250,
                            child: TextField(
                              decoration: AppTheme.inputDecoration("Buscar"),
                              onChanged: (v) {
                                setState(() {
                                  _busqueda = v;
                                  _alumnos = _filtrarLista(_alumnos);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: r.value(
                                  mobile: 20.0,
                                  desktop: 50.0,
                                ),
                                columns: const [
                                  DataColumn(label: Text('Nombre')),
                                  DataColumn(label: Text('Apellidos')),
                                  DataColumn(label: Text('Email')),
                                ],
                                rows: _alumnos
                                    .skip(_currentPage * _rowsPerPage)
                                    .take(_rowsPerPage)
                                    .map(
                                      (a) => DataRow(
                                        cells: [
                                          DataCell(Text(a['nombre'])),
                                          DataCell(Text(a['apellidos'])),
                                          DataCell(Text(a['email'])),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<DropdownMenuItem<String>> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: AppTheme.inputDecoration(label),
      ),
    );
  }
}
