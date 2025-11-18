import 'package:flutter/material.dart';

class ClaseCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final bool isInactive; // 👈 NUEVO
  final VoidCallback? onTap;
  final Widget? footerWidget;

  const ClaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
    this.footerWidget,
    this.isInactive = false, // 👈 DEFAULT
  });

  // Oscurecer ligeramente color
  Color _darken(Color c, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return hslDark.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = isInactive ? Colors.grey[400]! : color;
    final topColor = isInactive ? Colors.grey[600]! : _darken(color, 0.08);

    return GestureDetector(
      onTap: isInactive ? null : onTap, // ❌ Deshabilitar tap si está inactiva
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
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
            // Franja superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: topColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.book,
                      color: Colors.white.withOpacity(isInactive ? 0.6 : 1),
                      size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(isInactive ? 0.6 : 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Descripción
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(221, 77, 78, 76).withOpacity(isInactive ? 0.4 : 0.8),
                    ),
                  ),
                ),
              ),
            ),

            if (footerWidget != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInactive ? Colors.grey[500] : topColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: footerWidget,
              ),
          ],
        ),
      ),
    );
  }
}
