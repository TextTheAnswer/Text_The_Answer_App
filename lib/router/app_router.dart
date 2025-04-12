import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/auth/login_screen.dart';
import 'package:text_the_answer/screens/auth/register_screen.dart';
import 'package:text_the_answer/screens/auth/forgot_password_screen.dart';
import 'package:text_the_answer/screens/home_screen.dart';
import 'package:text_the_answer/screens/auth/onboarding_screen.dart';
import 'package:text_the_answer/screens/auth/splash_screen.dart';
import 'package:text_the_answer/screens/profile/profile_create.dart';

class AppRouter {
  // This function manages theme state between screens
  static Function toggleTheme = () {}; // This will be set from the main app

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log('Navigating to route: ${settings.name} with arguments: ${settings.arguments}');
    
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(toggleTheme: toggleTheme as VoidCallback),
        );
      
      case Routes.onboard:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(toggleTheme: toggleTheme as VoidCallback),
        );
      
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(toggleTheme: toggleTheme as VoidCallback),
        );
      
      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(toggleTheme: toggleTheme as VoidCallback),
        );
      
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(toggleTheme: toggleTheme as VoidCallback),
        );
      
      case Routes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      
      case Routes.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        log('OTP Verification route with email: $email');
        // Create your OTP verification page and uncomment this
        // return MaterialPageRoute(
        //   builder: (_) => OTPVerificationScreen(email: email),
        // );
        // Temporary fallback
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('OTP Verification')),
            body: Center(child: Text('OTP Verification for $email')),
          ),
        );
      
      case Routes.resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        final otp = args?['otp'] as String? ?? '';
        // Create your reset password page and uncomment this
        // return MaterialPageRoute(
        //   builder: (_) => ResetPasswordScreen(email: email, otp: otp),
        // );
        // Temporary fallback
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Reset Password')),
            body: Center(child: Text('Reset Password for $email with OTP: $otp')),
          ),
        );
        
      case Routes.profileCreate:
        return MaterialPageRoute(
          builder: (_) => const CreateProfileScreen(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

