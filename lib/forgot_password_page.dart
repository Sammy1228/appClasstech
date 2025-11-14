import 'package:appzacek/theme/app_theme.dart';
import 'package:appzacek/Utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  /// Llama a Firebase Auth para enviar el correo de restablecimiento
  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailCtrl.text.trim();

    try {
      // La función clave de Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enlace enviado. Revisa tu bandeja de entrada."),
          backgroundColor: Colors.green,
        ),
      );
      // Regresar al login después de enviar
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Ocurrió un error. Intenta de nuevo.";
      // Manejar error común
      if (e.code == 'user-not-found') {
        errorMsg = "No se encontró ningún usuario con ese correo.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      // AppBar para poder regresar
      appBar: AppBar(
        title: const Text("Recuperar Contraseña"),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // Usamos un contenedor blanco similar al del login/registro
            margin: EdgeInsets.all(responsive.wp(5).clamp(16, 24)),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
              vertical: responsive.verticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: responsive.dp(4).clamp(14, 18),
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: responsive.hp(3).clamp(20, 30)),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: AppTheme.inputDecoration("Correo electrónico"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obligatorio.';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor, ingresa un correo válido.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: responsive.hp(3).clamp(20, 30)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.hp(1.8).clamp(14, 18),
                        horizontal: responsive.wp(10).clamp(40, 60),
                      ),
                    ),
                    onPressed: _isLoading ? null : _sendResetLink,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Enviar Enlace",
                            style: TextStyle(
                              fontSize: responsive.dp(4).clamp(15, 20),
                              color: AppTheme.backgroundColor,
                            ),
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
