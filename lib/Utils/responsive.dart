import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  final Size size;
  final Orientation orientation;
  final bool isPortrait;
  final double screenWidth;
  final double screenHeight;
  

  Responsive(this.context)
      : size = MediaQuery.of(context).size,
        orientation = MediaQuery.of(context).orientation,
        isPortrait = MediaQuery.of(context).orientation == Orientation.portrait,
        screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height;

  /// Proporciones horizontales y verticales
  double wp(double percent) => screenWidth * percent / 100;
  double hp(double percent) => screenHeight * percent / 100;
  /// 'dp' devuelve un tamaño relativo fácil de usar para fuentes/íconos.

  double dp(double percent) => screenWidth * percent / 100;

  /// Padding horizontal estándar
  double get horizontalPadding =>
      isPortrait ? screenWidth * 0.08 : screenWidth * 0.2;

  /// Padding vertical estándar
  double get verticalPadding =>
      isPortrait ? screenHeight * 0.05 : screenHeight * 0.08;

  /// Ancho recomendado para campos o contenedores
  double get fieldWidth =>
      isPortrait ? screenWidth * 0.9 : screenWidth * 0.6;

  /// Tamaño de fuente adaptable
  double get titleFontSize =>
      isPortrait ? screenWidth * 0.13 : screenWidth * 0.08;
   double get fontScale =>
      isPortrait ? screenWidth * 0.13 : screenHeight * 0.13;

  /// Espaciado entre campos
  double get fieldSpacing =>
      isPortrait ? screenHeight * 0.02 : screenHeight * 0.015;

  /// Escalado general para texto o elementos
  double scale(double factorPortrait, double factorLandscape) =>
      isPortrait ? screenWidth * factorPortrait : screenHeight * factorLandscape;

      double sp(double percent) {
    double base = MediaQuery.of(context).size.width < 600 ? 100 : 120;
    return MediaQuery.of(context).size.width * percent / base;
  }

  bool get isMobile => MediaQuery.of(context).size.width < 600;
  bool get isTablet => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  bool get isDesktop => MediaQuery.of(context).size.width >= 1024;
      
}
