// --- NUEVOS IMPORTES ---
import 'dart:io';
import 'dart:math'; // Para formatear bytes
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_entregas.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- NUEVO IMPORTE PARA DESCARGAS ---
import 'package:file_saver/file_saver.dart';
// --- FIN NUEVO IMPORTE ---

// --- FIN NUEVOS IMPORTES ---

import 'package:appzacek/providers/provider_actividades.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

// --- MODIFICADO A STATEFULWIDGET ---
class ActividadPage extends StatefulWidget {
  final String actividadId;

  const ActividadPage({super.key, required this.actividadId});

  @override
  State<ActividadPage> createState() => _ActividadPageState();
}

class _ActividadPageState extends State<ActividadPage> {
  // Controladores y estado para comentarios y archivos
  final TextEditingController _comentarioCtrl = TextEditingController();
  final TextEditingController _retroAlumnoCtrl = TextEditingController();

  List<PlatformFile> _archivosSeleccionados = [];
  List<String> _nombresArchivos = [];

  // --- Lógica para seleccionar archivos ---
  Future<void> _pickFiles(BuildContext context) async {
    final entregasProvider = Provider.of<ProviderEntregas>(
      context,
      listen: false,
    );
    if (entregasProvider.isUploading) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Permitir múltiples archivos
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'png',
          'pdf',
          'doc',
          'docx',
          'txt',
          'xls',
          'xlsx',
        ],
        withData: true, // Pide los bytes (necesario para Web y Firestore)
      );

      if (result != null) {
        setState(() {
          _archivosSeleccionados = result.files;
          _nombresArchivos = result.files.map((file) => file.name).toList();
        });
        // Mostrar un SnackBar con los archivos seleccionados
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_archivosSeleccionados.length} archivos seleccionados.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar archivos: $e')),
      );
    }
  }

  // --- Lógica para subir la entrega ---
  Future<void> _subirEntrega(
    BuildContext context,
    Map<String, dynamic> actividadData,
  ) async {
    final auth = Provider.of<Authentication>(context, listen: false);
    final entregasProvider = Provider.of<ProviderEntregas>(
      context,
      listen: false,
    );

    if (_archivosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un archivo.')),
      );
      return;
    }
    if (entregasProvider.isUploading) return;

    try {
      await entregasProvider.subirEvidencia(
        archivos: _archivosSeleccionados,
        actividadId: widget.actividadId,
        uidAlumno: auth.isLoggedIn
            ? FirebaseAuth.instance.currentUser!.uid
            : '',
        nombreAlumno: '${auth.nombre} ${auth.apellidos}',
        claseNombre: actividadData['clase'] ?? 'Sin Clase',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrega guardada con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _archivosSeleccionados = [];
        _nombresArchivos = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Lógica para enviar comentario ---
  Future<void> _enviarComentario(BuildContext context) async {
    final auth = Provider.of<Authentication>(context, listen: false);
    final provider = Provider.of<ProviderActividades>(context, listen: false);
    final comentario = _comentarioCtrl.text.trim();

    if (comentario.isEmpty) return;

    try {
      await provider.enviarComentarioActividad(
        actividadId: widget.actividadId,
        uidUsuario: FirebaseAuth.instance.currentUser?.uid ?? '',
        nombreUsuario: '${auth.nombre} ${auth.apellidos}',
        comentario: comentario,
      );
      _comentarioCtrl.clear();
      FocusScope.of(context).unfocus(); // Ocultar teclado
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar comentario: $e')));
    }
  }

  // --- NUEVO HELPER para formatear bytes ---
  String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
  // --- FIN HELPER ---

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final actividadesProvider = Provider.of<ProviderActividades>(
      context,
      listen: false,
    );
    // --- NUEVOS PROVIDERS ---
    final auth = Provider.of<Authentication>(context, listen: false);
    final entregasProvider = Provider.of<ProviderEntregas>(context);
    final String uidUsuario = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      // 1. OBTENEMOS EL STREAM DE LA ACTIVIDAD ESPECÍFICA
      stream: actividadesProvider.obtenerActividadStreamPorId(
        widget.actividadId,
      ),
      builder: (context, snapshotActividad) {
        // --- Manejo de estados de carga/error ---
        if (snapshotActividad.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshotActividad.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Text(
                "Error al cargar la actividad: ${snapshotActividad.error}",
              ),
            ),
          );
        }
        if (!snapshotActividad.hasData || !snapshotActividad.data!.exists) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(child: Text("Esta actividad no existe.")),
          );
        }

        // --- DATOS DE LA ACTIVIDAD ---
        final actividadData =
            snapshotActividad.data!.data() as Map<String, dynamic>;

        // Formateo de fecha
        String fechaFormateada = "Sin fecha de entrega";
        if (actividadData['fechaEntrega'] != null &&
            actividadData['fechaEntrega'] is Timestamp) {
          final fecha = (actividadData['fechaEntrega'] as Timestamp).toDate();
          fechaFormateada =
              "Entrega: ${fecha.day}/${fecha.month}/${fecha.year}";
        }

        // Controlador para el campo URL
        final urlController = TextEditingController(
          text: actividadData['url'] ?? '',
        );

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            title: Text(
              actividadData['titulo'] ?? 'Sin Título', // 👈 DATO REAL
              style: TextStyle(
                // ✅ CAMBIO: Añadido clamp
                fontSize: (responsive.titleFontSize * 0.6).clamp(18, 22),
              ),
            ),
            actions: [
              if (auth.tipoUsuario == 'profesor')
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    // TODO: Lógica para eliminar actividad
                  },
                ),
            ],
          ),
          // ✅ CAMBIO: Añadido Center y ConstrainedBox
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700), // Ancho de formulario
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                child: Column(
                  children: [
                    // Caja amarilla
                    Container(
                      padding: EdgeInsets.all(
                        responsive.wp(4).clamp(16, 24),
                      ), // ✅ CAMBIO
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5B4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fechaFormateada, // 👈 DATO REAL
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: responsive
                                  .scale(0.045, 0.03)
                                  .clamp(16, 20),
                            ),
                          ),
                          SizedBox(height: responsive.hp(1).clamp(8, 12)),
                          Text(
                            actividadData['descripcion'] ??
                                'Sin descripción.', // 👈 DATO REAL
                            style: AppTheme.bodyText.copyWith(
                              fontSize: responsive
                                  .scale(0.04, 0.03)
                                  .clamp(14, 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Campo URL
                    if (urlController.text.isNotEmpty) ...[
                      TextField(
                        controller: urlController,
                        readOnly: true, // El alumno no debería editar esto
                        decoration: AppTheme.inputDecoration("URL de contenido")
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.link),
                                onPressed: () async {
                                  final url = Uri.tryParse(urlController.text);
                                  if (url != null && await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                            ),
                      ),
                      SizedBox(height: responsive.hp(2).clamp(16, 24)),
                    ],

                    // --- INICIO DE LÓGICA DE ENTREGA (ALUMNO) ---
                    if (auth.tipoUsuario == 'alumno')
                      StreamBuilder<DocumentSnapshot?>(
                        stream: entregasProvider.getMiEntregaStream(
                          widget.actividadId,
                          uidUsuario,
                        ),
                        builder: (context, snapshotEntrega) {
                          if (snapshotEntrega.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final entregaData =
                              snapshotEntrega.data?.data()
                                  as Map<String, dynamic>?;

                          // Caso 1: El alumno ya entregó
                          if (entregaData != null) {
                            return _buildEntregaInfo(
                              responsive,
                              entregaData,
                              context,
                              actividadData,
                            );
                          }

                          // Caso 2: El alumno no ha entregtado
                          return _buildDropzone(
                            responsive,
                            context,
                            actividadData,
                          );
                        },
                      ),

                    // --- FIN LÓGICA DE ENTREGA ---
                    SizedBox(height: responsive.hp(3).clamp(20, 30)),

                    // --- INICIO SECCIÓN DE COMENTARIOS ---
                    Text(
                      "Comentarios de la actividad",
                      style: TextStyle(
                        fontSize: responsive.dp(4.5).clamp(16, 20),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: responsive.hp(1.5).clamp(10, 15)),

                    // Campo para nuevo comentario
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _comentarioCtrl,
                            decoration: AppTheme.inputDecoration(
                              "Añadir comentario...",
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: AppTheme.primaryColor,
                          onPressed: () => _enviarComentario(context),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.hp(2).clamp(16, 24)),

                    // Lista de comentarios
                    StreamBuilder<QuerySnapshot>(
                      stream: actividadesProvider.getComentariosActividadStream(
                        widget.actividadId,
                      ),
                      builder: (context, snapshotComentarios) {
                        if (snapshotComentarios.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshotComentarios.hasData ||
                            snapshotComentarios.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No hay comentarios."),
                          );
                        }

                        final comentarios = snapshotComentarios.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comentarios.length,
                          itemBuilder: (context, index) {
                            final data =
                                comentarios[index].data()
                                    as Map<String, dynamic>;
                            final fecha = (data['timestamp'] as Timestamp?)
                                ?.toDate();

                            return _buildComentarioCard(
                              data['nombreUsuario'] ?? 'Usuario',
                              data['comentario'] ?? '',
                              fecha,
                              responsive,
                            );
                          },
                        );
                      },
                    ),
                    // --- FIN SECCIÓN DE COMENTARIOS ---
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  /// Zona para subir archivos (cuando no se ha entregado)
  Widget _buildDropzone(
    Responsive responsive,
    BuildContext context,
    Map<String, dynamic> actividadData,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickFiles(context),
          child: Container(
            padding: EdgeInsets.all(responsive.wp(8).clamp(24, 40)),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300), // Borde sutil
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                AppTheme.themedIcon(
                  Icons.upload_file,
                  size: responsive.scale(0.15, 0.08).clamp(50, 70),
                ),
                SizedBox(height: responsive.hp(1).clamp(8, 12)),
                Text(
                  "Adjunta tus archivos (Límite 1 MB)",
                  style: TextStyle(
                    fontSize: responsive.scale(0.04, 0.03).clamp(14, 17),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Muestra los archivos seleccionados
        if (_archivosSeleccionados.isNotEmpty) ...[
          SizedBox(height: responsive.hp(2).clamp(16, 24)),
          Text(
            "Archivos listos para guardar:",
            style: TextStyle(fontSize: responsive.dp(3.5).clamp(13, 16)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nombresArchivos.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(_nombresArchivos[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _archivosSeleccionados.removeAt(index);
                      _nombresArchivos.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ],

        SizedBox(height: responsive.hp(3).clamp(20, 30)),

        // --- INICIO DE BOTÓN/PROGRESO MODIFICADO ---
        Consumer<ProviderEntregas>(
          builder: (context, entregas, child) {
            // Si está subiendo, muestra el spinner
            if (entregas.isUploading) {
              return const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Guardando entrega..."),
                ],
              );
            }

            // Si no, muestra el botón de entregar
            return SizedBox(
              width: (responsive.fieldWidth * 0.7).clamp(250, 500),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(6).clamp(24, 36),
                    vertical: responsive.hp(1.5).clamp(12, 18),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _archivosSeleccionados.isEmpty
                    ? null
                    : () => _subirEntrega(context, actividadData),
                child: Text(
                  "Guardar Tarea", // Texto cambiado
                  style: TextStyle(
                    color: AppTheme.backgroundColor,
                    fontSize: responsive.scale(0.045, 0.03).clamp(15, 19),
                  ),
                ),
              ),
            );
          },
        ),
        // --- FIN DE BOTÓN/PROGRESO MODIFICADO ---
      ],
    );
  }

  /// Info de la entrega (cuando ya se entregó)
  Widget _buildEntregaInfo(
    Responsive responsive,
    Map<String, dynamic> entregaData,
    BuildContext context,
    Map<String, dynamic> actividadData,
  ) {
    final List<dynamic> archivos = entregaData['archivos'] ?? [];
    final calificacion = entregaData['calificacion'];
    final comentarioProfesor = entregaData['comentarioProfesor'];
    final estado = entregaData['estado'] ?? 'entregado';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(4).clamp(16, 24)),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tu entrega (Estado: ${estado.toUpperCase()})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsive.scale(0.045, 0.03).clamp(16, 20),
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: responsive.hp(1).clamp(8, 12)),
          const Text("Archivos guardados:"),

          // --- INICIO DE LISTA MODIFICADA ---
          ...archivos.map((archivo) {
            return ListTile(
              leading: Icon(
                _getIconForTipo(archivo['tipo'] ?? ''),
                color: AppTheme.primaryColor,
              ),
              title: Text(archivo['nombre'] ?? 'archivo'),
              // Muestra el tamaño del archivo
              subtitle: Text(
                "Tipo: ${archivo['tipo']} - Tamaño: ${_formatBytes(archivo['size'] ?? 0)}",
              ),
              // --- CAMBIO AQUÍ: Añadido onTap para descargar ---
              trailing: Icon(
                Icons.download_for_offline,
                color: Colors.blueGrey,
              ),
              onTap: () async {
                try {
                  final bytes = (archivo['bytes'] as Blob).bytes;
                  await FileSaver.instance.saveFile(
                    name: archivo['nombre'] ?? 'archivo_descargado',
                    bytes: bytes,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Archivo guardado en Descargas.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al descargar: $e")),
                  );
                }
              },
            );
          }).toList(),
          // --- FIN DE LISTA MODIFICADA ---

          // Sección de Calificación (si existe)
          if (calificacion != null) ...[
            SizedBox(height: responsive.hp(2).clamp(16, 24)),
            const Divider(),
            SizedBox(height: responsive.hp(2).clamp(16, 24)),
            Text(
              "Calificación: $calificacion / 100",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsive.scale(0.045, 0.03).clamp(16, 20),
                color: AppTheme.primaryColor,
              ),
            ),
          ],
          if (comentarioProfesor != null &&
              comentarioProfesor.toString().isNotEmpty) ...[
            SizedBox(height: responsive.hp(1).clamp(8, 12)),
            Text(
              "Comentario del profesor:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(comentarioProfesor),
          ],

          // --- NUEVO BOTÓN PARA AÑADIR MÁS ARCHIVOS ---
          SizedBox(height: responsive.hp(2).clamp(16, 24)),
          TextButton.icon(
            icon: Icon(Icons.add_circle_outline, size: 18),
            label: Text("Añadir más archivos (Límite 1 MB)"),
            onPressed: () => _pickFiles(context),
          ),
          // Muestra los nuevos archivos seleccionados
          if (_archivosSeleccionados.isNotEmpty) ...[
            Text(
              "Nuevos archivos:",
              style: TextStyle(fontSize: responsive.dp(3.5).clamp(13, 16)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nombresArchivos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(_nombresArchivos[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _archivosSeleccionados.removeAt(index);
                        _nombresArchivos.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),

            // --- INICIO DE BOTÓN/PROGRESO MODIFICADO ---
            Consumer<ProviderEntregas>(
              builder: (context, entregas, child) {
                // Si está subiendo, muestra el spinner
                if (entregas.isUploading) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text("Guardando archivos..."),
                    ],
                  );
                }

                // Si no, muestra el botón
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                  onPressed: () => _subirEntrega(context, actividadData),
                  child: Text("Guardar nuevos archivos"),
                );
              },
            ),
            // --- FIN DE BOTÓN/PROGRESO MODIFICADO ---
          ],
          // --- FIN NUEVO BOTÓN ---
        ],
      ),
    );
  }

  /// Tarjeta para mostrar un comentario
  Widget _buildComentarioCard(
    String nombre,
    String comentario,
    DateTime? fecha,
    Responsive responsive,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: responsive.hp(1).clamp(8, 12)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(responsive.dp(3).clamp(12, 16)),
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
                    color: AppTheme.primaryColor,
                    fontSize: responsive.dp(3.5).clamp(14, 16),
                  ),
                ),
                Text(
                  fecha != null
                      ? DateFormat('dd/MM/yy, HH:mm').format(fecha)
                      : '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: responsive.dp(3).clamp(12, 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.hp(0.5).clamp(4, 8)),
            Text(
              comentario,
              style: TextStyle(fontSize: responsive.dp(3.5).clamp(14, 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// Icono helper
  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png': // Añadido
      case 'jpg': // Añadido
        return Icons.image;
      case 'doc': // Añadido
      case 'docx': // Añadido
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
