import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'Utils/responsive.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.wp(8)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¡Bienvenido!",
                style: TextStyle(
                  fontSize: responsive.dp(6),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.hp(4)),
              Image.asset(
                AppTheme.logoPath,
                width: responsive.wp(40),
                height: responsive.wp(40),
              ),
              SizedBox(height: responsive.hp(4)),
              Text(
                "Classtech",
                style: TextStyle(
                  fontSize: responsive.dp(4.5),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
