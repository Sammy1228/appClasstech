import 'dart:math';
import 'package:appzacek/providers/provider_autenticacion.dart';
import 'package:appzacek/providers/provider_clases.dart';
import 'package:appzacek/widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../Utils/responsive.dart';

class CrearClasePage extends StatefulWidget {
  const CrearClasePage({super.key});
  @override
  State<CrearClasePage> createState() => _CrearClasePageState();
}

class _CrearClasePageState extends State<CrearClasePage> {
  final _formKey = GlobalKey<FormState>();
  String? institucionSeleccionada;
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _cicloEscolarCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _carreraCtrl = TextEditingController();
  final _semestreCtrl = TextEditingController();
  bool _carreraNA = false;
  bool _semestreNA = false;

  @override
  void initState() {
    super.initState();
    _codigoCtrl.text = List.generate(
      6,
      (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[Random().nextInt(36)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final auth = Provider.of<Authentication>(context, listen: false);
    final insts = auth.instituciones
        .where((i) => i['estado'] == 'activo')
        .map((i) => i['nombre'].toString())
        .toList();

    return Scaffold(
      appBar: AppBar(
        // ✅ CORREGIDO: Fuente adaptable
        title: Text(
          "Crear Clase",
          style: TextStyle(
            fontSize: r.headerFontSize,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.maxFormWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(r.horizontalPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: AppTheme.inputDecoration("Título"),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: AppTheme.inputDecoration("Descripción"),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    value: institucionSeleccionada,
                    items: insts
                        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => institucionSeleccionada = v),
                    decoration: AppTheme.inputDecoration("Institución"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _carreraCtrl,
                    decoration: AppTheme.inputDecoration("Carrera"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _semestreCtrl,
                    decoration: AppTheme.inputDecoration("Semestre"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cicloEscolarCtrl,
                    decoration: AppTheme.inputDecoration("Ciclo Escolar"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final p = Provider.of<ProviderClases>(
                          context,
                          listen: false,
                        );
                        p.setTitulo = _tituloCtrl.text;
                        p.setDescripcion = _descripcionCtrl.text;
                        p.setInstitucion = institucionSeleccionada ?? '';
                        p.setCarrera = _carreraCtrl.text;
                        p.setSemestre = _semestreCtrl.text;
                        p.setCicloEscolar = _cicloEscolarCtrl.text;
                        p.setCodigoAcceso = _codigoCtrl.text;
                        p.setUidProfesor =
                            FirebaseAuth.instance.currentUser!.uid;
                        p.setNombreProfesor = auth.nombre;
                        await p.createClass();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Crear",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
