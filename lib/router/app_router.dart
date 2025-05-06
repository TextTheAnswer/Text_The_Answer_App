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
import 'package:text_the_answer/screens/profile/profile_screen.dart';
import 'package:text_the_answer/screens/settings/manage_subscription_screen.dart';
import 'package:text_the_answer/screens/settings/settings_screen.dart';
import 'package:text_the_answer/screens/subscription/subscription_plans_screen.dart';
import 'package:text_the_answer/screens/subscription/checkout_screen.dart';
import 'package:text_the_answer/screens/subscription/education_verification_screen.dart';
import 'package:text_the_answer/screens/subscription/subscription_success_screen.dart';
import 'package:text_the_answer/screens/subscription/cancellation_confirmation_screen.dart';
import 'package:text_the_answer/models/subscription_plan.dart';
import 'package:text_the_answer/models/subscription.dart';

@Deprecated(
  'Routing is now been handled by Go Router. Reference /Users/danielolayinka/Documents/Prod Work/Text_The_Answer_App/lib/utils/routing/route_config.dart',
)
class AppRouter {
  // This function manages theme state between screens
  static Function toggleTheme = () {}; // This will be set from the main app
  static Function setTheme =
      (String theme) {}; // Added for more specific theme selection
  static String currentTheme =
      'default'; // Track current theme - make it public

  // Get the current theme
  static String getCurrentTheme() {
    return currentTheme;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    log(
      'Navigating to route: ${settings.name} with arguments: ${settings.arguments}',
    );

    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());

      case Routes.onboard:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());

      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case Routes.signup:
        return MaterialPageRoute(builder: (_) => RegisterScreen());

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(toggleTheme: toggleTheme as VoidCallback),
        );

      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

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
          builder:
              (_) => ResetPasswordScreen(email: email, resetToken: resetToken),
        );

      case Routes.profileCreate:
        return MaterialPageRoute(builder: (_) => const ProfileCreationScreen());

      case Routes.manageSubscription:
        return MaterialPageRoute(
          builder: (_) => const ManageSubscriptionScreen(),
        );

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen());

      case Routes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

      case Routes.subscriptionPlans:
        return MaterialPageRoute(
          builder:
              (_) => SubscriptionPlansScreen(
                toggleTheme: toggleTheme as VoidCallback,
              ),
        );

      case Routes.checkout:
        final args = settings.arguments as Map<String, dynamic>?;
        final plan = args?['plan'] as SubscriptionPlan?;
        if (plan == null) {
          return MaterialPageRoute(
            builder:
                (_) => SubscriptionPlansScreen(
                  toggleTheme: toggleTheme as VoidCallback,
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => CheckoutScreen(
                plan: plan,
                toggleTheme: toggleTheme as VoidCallback,
              ),
        );

      case Routes.educationVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        final plan = args?['plan'] as SubscriptionPlan?;
        if (plan == null) {
          return MaterialPageRoute(
            builder:
                (_) => SubscriptionPlansScreen(
                  toggleTheme: toggleTheme as VoidCallback,
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => EducationVerificationScreen(
                plan: plan,
                toggleTheme: toggleTheme as VoidCallback,
              ),
        );

      case Routes.subscriptionSuccess:
        return MaterialPageRoute(
          builder:
              (_) => SubscriptionSuccessScreen(
                toggleTheme: toggleTheme as VoidCallback,
              ),
        );

      case Routes.cancellationConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        final subscription = args?['subscription'] as Subscription?;
        if (subscription == null) {
          return MaterialPageRoute(
            builder: (_) => const ManageSubscriptionScreen(),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => CancellationConfirmationScreen(subscription: subscription),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
