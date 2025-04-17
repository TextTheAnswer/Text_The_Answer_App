import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/colors.dart';
import '../../router/routes.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? toggleTheme;

  const SplashScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    if (toggleTheme != null) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, Routes.onboard);
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [AppColors.primary, AppColors.primary],
          ),
          // image: DecorationImage(
          //   image: AssetImage('assets/images/auth_bg_pattern.png'),
          //   fit: BoxFit.cover,
          //   opacity: 0.05,
          // ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/splash_page.png',
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 90),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: SpinKitFadingCube(color: Colors.white, size: 50.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
