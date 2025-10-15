import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import '../Utils/responsive.dart';

class RetroalimentacionPage extends StatelessWidget {
  const RetroalimentacionPage({super.key});

  // Avatar adaptable
  Widget feedbackAvatar(String inicial, Color color, Responsive responsive) {
    return CircleAvatar(
      radius: responsive.dp(4.5),
      backgroundColor: color,
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: responsive.dp(4),
          fontWeight: FontWeight.bold,
          color: AppTheme.backgroundColor,
        ),
      ),
    );
  }

  // Tarjeta de retroalimentación adaptable
  Widget feedbackCard(
      String inicial, Color color, String texto, Responsive responsive) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.hp(1.5)),
      padding: EdgeInsets.all(responsive.dp(3.5)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          feedbackAvatar(inicial, color, responsive),
          SizedBox(width: responsive.wp(3)),
          Expanded(
            child: Text(
              texto,
              style: AppTheme.bodyText.copyWith(
                fontSize: responsive.dp(3.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Retroalimentación",
          style: TextStyle(
            color: AppTheme.backgroundColor,
            fontSize: responsive.dp(5),
          ),
        ),
        iconTheme: IconThemeData(
          color: AppTheme.backgroundColor,
          size: responsive.dp(5.5),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding,
          vertical: responsive.verticalPadding,
        ),
        child: Column(
          children: [
            feedbackCard(
              "O",
              Colors.blue,
              "La clase me pareció muy interesante, pero creo que sería útil incluir más ejemplos prácticos o estudios de caso.",
              responsive,
            ),
            feedbackCard(
              "S",
              Colors.lightBlue,
              "La exposición del tema fue excelente, pero sería bueno tener un espacio para trabajar en grupos.",
              responsive,
            ),
            feedbackCard(
              "P",
              Colors.teal,
              "La exposición del tema fue excelente, pero sería bueno tener un espacio para trabajar en grupos.",
              responsive,
            ),
            feedbackCard(
              "D",
              Colors.redAccent,
              "Aquí se incluye la retroalimentación del alumno.",
              responsive,
            ),
            feedbackCard(
              "I",
              Colors.orangeAccent,
              "Aquí se incluye la retroalimentación del alumno.",
              responsive,
            ),
            feedbackCard(
              "V",
              Colors.purpleAccent,
              "Aquí se incluye la retroalimentación del alumno.",
              responsive,
            ),
            feedbackCard(
              "C",
              Colors.cyan,
              "Aquí se incluye la retroalimentación del alumno.",
              responsive,
            ),
          ],
        ),
      ),
    );
  }
}
