import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';

class RetroalimentacionPage extends StatelessWidget {
  const RetroalimentacionPage({super.key});

  // Función para generar un círculo con inicial y color
  Widget feedbackAvatar(String inicial, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.backgroundColor,
        ),
      ),
    );
  }

  // Widget de retroalimentación individual
  Widget feedbackCard(String inicial, Color color, String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          feedbackAvatar(inicial, color),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: AppTheme.bodyText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text("Retroalimentación"),
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
        titleTextStyle: const TextStyle(
          color: AppTheme.backgroundColor,
          fontSize: 20,
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            feedbackCard(
              "O",
              Colors.blue,
              "La clase me pareció muy interesante, pero creo que sería útil incluir más ejemplos prácticos o estudios de caso para aplicar la teoría de manera más concreta.",
            ),
            feedbackCard(
              "S",
              Colors.lightBlue,
              "La exposición del tema fue excelente, pero sería bueno tener un espacio para trabajar en grupos y discutir las ideas, para así poder digerir el material de forma colaborativa.",
            ),
            feedbackCard(
              "P",
              Colors.teal,
              "La exposición del tema fue excelente, pero sería bueno tener un espacio para trabajar en grupos y discutir las ideas, para así poder digerir el material de forma colaborativa.",
            ),
            feedbackCard(
              "D",
              Colors.redAccent,
              "Aquí se incluye la retroalimentación del alumno",
            ),
            feedbackCard(
              "I",
              Colors.orangeAccent,
              "Aquí se incluye la retroalimentación del alumno",
            ),
            feedbackCard(
              "V",
              Colors.purpleAccent,
              "Aquí se incluye la retroalimentación del alumno",
            ),
            feedbackCard(
              "C",
              Colors.cyan,
              "Aquí se incluye la retroalimentación del alumno",
            ),
          ],
        ),
      ),
    );
  }
}
