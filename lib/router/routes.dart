class Routes {
  static const String forgotPassword = '/forgot-password';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String onboard = '/onboard';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String profileCreate = '/profile-create';
  static const String settings = '/settings';
  static const String manageSubscription = '/settings/manage-subscription';
  static const String notification = '/settings/notifications';
  static const String subscriptionPlans = '/subscription-plans';
  static const String checkout = '/subscription/checkout';
  static const String educationVerification = '/subscription/education-verification';
  static const String subscriptionSuccess = '/subscription/success';
  static const String cancellationConfirmation = '/subscription/cancellation-confirmation';
  static const String profile = '/profile';

  //Add routes here
}

abstract class AppRouteName {
  // -- Main App Screen
  static const String home = 'home';
  static const String library = 'library';
  static const String gameMode = 'game-mode';
  static const String quiz = 'quiz';
  static const String profile = 'profile';

  // -- Login and Onboarding
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot-password';
  static const String otpVerification = 'otp-verification';
  static const String resetPassword = 'oreset-password';
  static const String profileCreate = 'profile-create';

  // -- Settings
  static const String settings = 'settings';
  static const String notification = 'notification';
  static const String musicEffect = 'music-effect';
  static const String security = 'security';
  static const String helpCenter = 'help-center';
  static const String about = 'about';

  // -- Add other route
}

abstract class AppRoutePath {
  // -- Main App Screen
  static const String home = '/';
  static const String library = '/library';
  static const String gameMode = '/game-mode';
  static const String quiz = '/quiz';
  static const String profile = '/profile';

  // -- Login and Onboarding
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String profileCreate = '/profile-create';

  static const otpVerificationPattern = '/otp-verification/:email';
  static String otpVerification({required String email}) =>
      '/otp-verification/$email';

  static const String resetPassword = '/reset-password';

  // -- Settings
  static const String settings = '/settings';
  static const String notification = 'notifications';
  static const String musicEffect = 'music-effect';
  static const String security = 'security';
  static const String helpCenter = 'help-center';
  static const String about = 'about';

  // -- Add other route
}
