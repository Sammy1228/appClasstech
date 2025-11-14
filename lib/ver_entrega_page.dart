import 'dart:math'; // Para formatear bytes
import 'package:appzacek/providers/provider_entregas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// --- NUEVO IMPORTE PARA DESCARGAS ---
import 'package:file_saver/file_saver.dart';
// --- FIN NUEVO IMPORTE ---
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class VerEntregaPage extends StatefulWidget {
  final String entregaId;
  const VerEntregaPage({super.key, required this.entregaId});

  @override
  State<VerEntregaPage> createState() => _VerEntregaPageState();
}

class _VerEntregaPageState extends State<VerEntregaPage> {
  final TextEditingController _calificacionCtrl = TextEditingController();
  final TextEditingController _comentarioCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _datosCargados = false;

  @override
  void dispose() {
    _calificacionCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCalificacion(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<ProviderEntregas>(context, listen: false);
    final calificacion = int.tryParse(_calificacionCtrl.text) ?? 0;
    final comentario = _comentarioCtrl.text.trim();

    if (provider.isUploading) return;

    try {
      await provider.calificarEntrega(
        entregaId: widget.entregaId,
        calificacion: calificacion,
        comentario: comentario,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Calificación guardada con éxito."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Regresar a la lista
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
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
    final provider = Provider.of<ProviderEntregas>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revisar Entrega"),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: provider.getEntregaPorIdStream(widget.entregaId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> archivos = data['archivos'] ?? [];

          if (!_datosCargados) {
            _calificacionCtrl.text = (data['calificacion'] ?? '').toString();
            _comentarioCtrl.text = (data['comentarioProfesor'] ?? '')
                .toString();
            _datosCargados = true;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(responsive.dp(4).clamp(16, 24)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alumno: ${data['nombreAlumno'] ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: responsive.dp(5).clamp(18, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.hp(2).clamp(16, 24)),

                  // --- Sección 1: Archivos Subidos ---
                  Text(
                    "Archivos Guardados:",
                    style: TextStyle(
                      fontSize: responsive.dp(4).clamp(16, 18),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (archivos.isEmpty)
                    const Text("No se adjuntaron archivos.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: archivos.length,
                      itemBuilder: (context, index) {
                        final archivo = archivos[index];
                        return Card(
                          elevation: 1,
                          child: ListTile(
                            leading: Icon(
                              _getIconForTipo(archivo['tipo'] ?? ''),
                              color: AppTheme.primaryColor,
                            ),
                            title: Text(archivo['nombre'] ?? 'archivo'),
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
                                  name:
                                      archivo['nombre'] ?? 'archivo_descargado',
                                  bytes: bytes,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Archivo guardado en Descargas.",
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error al descargar: $e"),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  SizedBox(height: responsive.hp(3).clamp(20, 30)),

                  // --- Sección 2: Calificación ---
                  Text(
                    "Asignar Calificación:",
                    style: TextStyle(
                      fontSize: responsive.dp(4).clamp(16, 18),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: responsive.hp(1).clamp(8, 12)),
                  TextFormField(
                    controller: _calificacionCtrl,
                    decoration: AppTheme.inputDecoration(
                      "Calificación (0-100)",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido.";
                      }
                      final val = int.tryParse(value);
                      if (val == null || val < 0 || val > 100) {
                        return "Debe ser un número entre 0 y 100.";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.hp(2).clamp(16, 24)),
                  TextFormField(
                    controller: _comentarioCtrl,
                    decoration: AppTheme.inputDecoration(
                      "Comentario de retroalimentación (opcional)",
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: responsive.hp(3).clamp(20, 30)),

                  // --- Botón de Guardar ---
                  Center(
                    child: Consumer<ProviderEntregas>(
                      builder: (context, entregas, child) {
                        return ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            entregas.isUploading
                                ? "Guardando..."
                                : "Guardar Calificación",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: entregas.isUploading
                              ? null
                              : () => _guardarCalificacion(context),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
