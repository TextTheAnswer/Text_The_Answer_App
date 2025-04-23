import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/auth/login_screen.dart';
import 'package:text_the_answer/screens/auth/register_screen.dart';
import 'package:text_the_answer/screens/auth/forgot_password_screen.dart';
import 'package:text_the_answer/screens/auth/otp_verification_screen.dart';
import 'package:text_the_answer/screens/auth/reset_password_screen.dart';
import 'package:text_the_answer/screens/home/home_screen.dart';
import 'package:text_the_answer/screens/auth/onboarding_screen.dart';
import 'package:text_the_answer/screens/auth/splash_screen.dart';
import 'package:text_the_answer/screens/profile/profile_creation_screen.dart';
import 'package:text_the_answer/screens/settings/manage_subscription_screen.dart';
import 'package:text_the_answer/screens/settings_screen.dart';

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
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(email: email),
        );
      
      case Routes.resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final email = args?['email'] as String? ?? '';
        final resetToken = args?['resetToken'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: email, 
            resetToken: resetToken,
          ),
        );
        
      case Routes.profileCreate:
        return MaterialPageRoute(
          builder: (_) => const ProfileCreationScreen(),
        );
      
      case Routes.manageSubscription:
        return MaterialPageRoute(
          builder: (_) => const ManageSubscriptionScreen(),
        );
      
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(toggleTheme: toggleTheme as VoidCallback),
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

