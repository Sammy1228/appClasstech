import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;
  final bool isPortrait;
  final Size size;

  Responsive(this.context)
    : size = MediaQuery.of(context).size,
      screenWidth = MediaQuery.of(context).size.width,
      screenHeight = MediaQuery.of(context).size.height,
      isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  // --- Breakpoints ---
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // --- Dimensiones relativas ---
  double wp(double percent) => screenWidth * percent / 100;
  double hp(double percent) => screenHeight * percent / 100;

  double dp(double percent) {
    final double diagonal = isDesktop ? 1000.0 : screenWidth;
    return diagonal * percent / 100;
  }

  // ============================================================
  // --- MÉTODOS DE COMPATIBILIDAD (Para actividad.dart) ---
  // Estos son los que faltaban y causaban el error.
  // ============================================================

  // 1. Método scale: Escala valores según orientación
  double scale(double factorPortrait, double factorLandscape) => isPortrait
      ? screenWidth * factorPortrait
      : screenHeight * factorLandscape;

  // 2. Getter fieldWidth: Ancho para formularios antiguos
  double get fieldWidth => isPortrait ? screenWidth * 0.9 : 400.0;

  // 3. Otros métodos legacy (por seguridad)
  double get fontScale => isPortrait ? screenWidth * 0.13 : screenHeight * 0.13;

  double sp(double percent) {
    double base = screenWidth < 600 ? 100 : 120;
    return screenWidth * percent / base;
  }
  // ============================================================

  // --- NUEVA LÓGICA RESPONSIVA (Para Dashboard, Menú, etc.) ---

  // Método auxiliar para valores condicionales
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // --- Estilos Globales ---
  double get horizontalPadding =>
      value(mobile: 20.0, tablet: 40.0, desktop: 60.0);
  double get verticalPadding =>
      value(mobile: 20.0, tablet: 30.0, desktop: 40.0);

  // Límites de ancho
  double get maxFormWidth => 500.0;
  double get maxContentWidth => 1200.0;

  // --- Fuentes ---
  double get headerFontSize => value(mobile: 20.0, tablet: 22.0, desktop: 24.0);
  double get titleFontSize => value(mobile: 18.0, tablet: 20.0, desktop: 22.0);
  double get bodyFontSize => value(mobile: 14.0, tablet: 15.0, desktop: 16.0);

  double get fieldSpacing => hp(value(mobile: 2.0, desktop: 2.5));
}
