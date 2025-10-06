import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF6443D9);
  static const Color secondaryColor = Color(0xFFFBBB45);
  static const Color backgroundColor = Colors.white;

  // Ruta del logo
  static const String logoPath = "assets/images/logo.png";

  // ✍️ Estilos de texto
  static TextStyle headline1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static TextStyle bodyText = const TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  // Colores de las clases
  static const List<Color> claseColors = [
    Color.fromARGB(255, 255, 220, 168),
    Color.fromARGB(255, 253, 184, 208),
    Color.fromARGB(255, 170, 215, 252),
    Color.fromARGB(255, 186, 249, 179),
  ];

  // Cajas de texto reutilizables
  static InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
    );
  }

  // Íconos temáticos reutilizables
  static Icon themedIcon(IconData icon, {double size = 24, Color? color}) {
    return Icon(icon, size: size, color: color ?? primaryColor);
  }

  // Tarjeta de clase reutilizable
  static Widget claseCard({
    required String title,
    required String description,
    required Color color,
  }) {
    Color darken(Color c, [double amount = 0.1]) {
      final hsl = HSLColor.fromColor(c);
      final hslDark = hsl.withLightness(
        (hsl.lightness - amount).clamp(0.0, 1.0),
      );
      return hslDark.toColor();
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: darken(color, 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                themedIcon(Icons.book, color: Colors.white, size: 32),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
