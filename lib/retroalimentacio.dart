import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import '../Utils/responsive.dart';

class RetroalimentacionPage extends StatefulWidget {
  const RetroalimentacionPage({super.key});

  @override
  State<RetroalimentacionPage> createState() => _RetroalimentacionPageState();
}

class _RetroalimentacionPageState extends State<RetroalimentacionPage> {
  String? _claseSeleccionadaId;
  String? _claseSeleccionadaTitulo;
  final TextEditingController _retroCtrl = TextEditingController();

  late Stream<QuerySnapshot> _clasesStream;

  @override
  void initState() {
    super.initState();
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);
    _clasesStream = clasesProvider.obtenerClasesStream();
  }

  Future<void> _enviarRetro(BuildContext context) async {
    final auth = Provider.of<Authentication>(context, listen: false);
    final provider = Provider.of<ProviderClases>(context, listen: false);
    final comentario = _retroCtrl.text.trim();

    if (comentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío.')),
      );
      return;
    }
    if (_claseSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una clase primero.')),
      );
      return;
    }

    try {
      await provider.enviarRetroalimentacionClase(
        claseId: _claseSeleccionadaId!,
        uidAlumno: FirebaseAuth.instance.currentUser?.uid ?? '',
        nombreAlumno: '${auth.nombre} ${auth.apellidos}',
        comentario: comentario,
      );
      _retroCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar retroalimentación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final authProvider = Provider.of<Authentication>(context);
    final clasesProvider = Provider.of<ProviderClases>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        // ✅ CORREGIDO: Fuente adaptable
        title: Text(
          "Retroalimentación",
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: responsive.headerFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
              vertical: responsive.verticalPadding,
            ),
            child: Column(
              children: [
                // 1. Stream para obtener y filtrar las clases
                StreamBuilder<QuerySnapshot>(
                  stream: _clasesStream,
                  builder: (context, snapshotClases) {
                    if (!snapshotClases.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final misClases = <Map<String, dynamic>>[];
                    for (var doc in snapshotClases.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final estado = data['estado'] ?? 'activo';
                      final List<dynamic> alumnos = data['alumnos'] ?? [];

                      if (authProvider.tipoUsuario == "alumno") {
                        if (estado == "activo" && alumnos.contains(user?.uid)) {
                          misClases.add({
                            "id": doc.id,
                            "titulo": data['titulo'] ?? 'Sin título',
                          });
                        }
                      } else if (authProvider.tipoUsuario == "profesor") {
                        if (data['uidProfesor'] == user?.uid &&
                            estado == "activo") {
                          misClases.add({
                            "id": doc.id,
                            "titulo": data['titulo'] ?? 'Sin título',
                          });
                        }
                      }
                    }

                    if (misClases.isEmpty) {
                      return const Text(
                        "No estás inscrito en ninguna clase activa.",
                      );
                    }

                    // 2. Dropdown para seleccionar la clase
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: DropdownButtonFormField<String>(
                        value: _claseSeleccionadaId,
                        decoration: AppTheme.inputDecoration(
                          "Selecciona una clase",
                        ),
                        items: misClases.map((clase) {
                          return DropdownMenuItem<String>(
                            value: clase['id'] as String,
                            child: Text(clase['titulo'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _claseSeleccionadaId = value;
                            _claseSeleccionadaTitulo =
                                misClases.firstWhere(
                                      (c) => c['id'] == value,
                                    )['titulo']
                                    as String?;
                          });
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: responsive.hp(3)),

                // 3. Campo para escribir retroalimentación (solo alumnos)
                if (authProvider.tipoUsuario == 'alumno') ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _retroCtrl,
                            decoration: AppTheme.inputDecoration(
                              "Escribe tu retroalimentación...",
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: AppTheme.primaryColor,
                          onPressed: () => _enviarRetro(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.hp(3)),
                ],

                // 4. Stream para mostrar los comentarios
                if (_claseSeleccionadaId != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: clasesProvider.getRetroalimentacionClaseStream(
                      _claseSeleccionadaId!,
                    ),
                    builder: (context, snapshotRetro) {
                      if (snapshotRetro.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshotRetro.hasData ||
                          snapshotRetro.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No hay retroalimentación para '${_claseSeleccionadaTitulo ?? ''}'.",
                          ),
                        );
                      }

                      final comentarios = snapshotRetro.data!.docs;

                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comentarios.length,
                          itemBuilder: (context, index) {
                            final data =
                                comentarios[index].data()
                                    as Map<String, dynamic>;
                            final fecha = (data['timestamp'] as Timestamp?)
                                ?.toDate();

                            return _buildRetroCard(
                              data['nombreAlumno'] ?? 'Alumno',
                              data['comentario'] ?? '',
                              fecha,
                              responsive,
                            );
                          },
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Text(
                      "Selecciona una clase para ver la retroalimentación.",
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetroCard(
    String nombre,
    String comentario,
    DateTime? fecha,
    Responsive responsive,
  ) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final color = Colors.primaries[nombre.hashCode % Colors.primaries.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Text(
                inicial,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: responsive.bodyFontSize,
                        ),
                      ),
                      Text(
                        fecha != null
                            ? DateFormat('dd/MM/yy, HH:mm').format(fecha)
                            : '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comentario,
                    style: TextStyle(fontSize: responsive.bodyFontSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
