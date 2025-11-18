import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClaseCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const ClaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  // Oscurecer ligeramente el color para la franja superior
  Color _darken(Color c, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // * Franja superior donde aparecerá el título dinámico
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _darken(color, 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.book, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title, // ← AQUÍ VA EL TÍTULO DINÁMICO
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // * Descripción
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
