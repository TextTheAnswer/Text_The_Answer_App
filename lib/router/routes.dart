abstract class AppRouteName {
  // -- Main App Screen
  static const String home = 'home';
  static const String library = 'library';
  static const String gameMode = 'game-mode';
  static const String quiz = 'quiz';
  static const String profile = 'profile';
  static const String achievements = 'achievements';
  static const String dailyQuiz = 'dailyQuiz';
  static const String dailyQuizRealtime = 'dailyQuizRealtime';

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

  // -- Lobby
  static const String publicLobby = 'publicLobby';
  static const String privateLobby = 'privateLobby';

  // -- Add other route
  static const String register = 'register';
  static const String editProfile = 'edit-profile';
  static const String category = 'category';
  static const String categoryDetails = 'category-details';
  static const String studyMaterial = 'study-material';
  static const String studyMaterialDetails = 'study-material-details';
  static const String game = 'game';
  static const String gameDetails = 'game-details';
  static const String leaderboard = 'leaderboard';
  static const String subscription = 'subscription';
  static const String subscriptionPlans = 'subscription-plans';
  static const String subscriptionDetails = 'subscription-details';
  static const String subscriptionSuccess = 'subscription-success';
  static const String subscriptionFailure = 'subscription-failure';
  static const String subscriptionCancel = 'subscription-cancel';
  static const String dailyQuizHome = 'daily-quiz-home';
  static const String dailyQuizResults = 'daily-quiz-results';
  static const String dailyQuizReview = 'daily-quiz-review';
}

abstract class AppRoutePath {
  static const String root = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String leaderboard = '/leaderboard';
  static const String dailyQuiz = '/daily-quiz';
  static const String dailyQuizHome = '/daily-quiz-home';
  static const String dailyQuizRealtime = '/daily-quiz-realtime';
  static const String achievements = '/achievements';
  static const String gameMode = '/game-mode';
  static const String lobby = '/lobby';
  static const String subscription = '/subscription';
  static const String themes = '/themes';
  static const String studyMaterial = '/study-material';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String about = '/about';
  static const String selectCategory = '/select-category';
  static const String library = '/library';
  static const String quiz = '/quiz';

  // -- Login and Onboarding
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String profileCreate = '/profile-create';

  static const otpVerificationPattern = '/otp-verification/:email';
  static String otpVerification({required String email}) =>
      '/otp-verification/$email';

  // -- Settings
  static const String notification = 'notifications';
  static const String musicEffect = 'music-effect';
  static const String security = 'security';
  static const String helpCenter = 'help-center';

  // -- Lobby
  static const String publicLobby = '/publicLobby';
  static const String privateLobby = '/privateLobby';

  // -- Add other route
  static const String register = '/register';
  static const String editProfile = '/edit-profile';
  static const String category = '/category';
  static const String categoryDetails = '/category/:id';
  static const String studyMaterialDetails = '/study-material/:id';
  static const String game = '/game';
  static const String gameDetails = '/game/:id';
  static const String subscriptionPlans = '/subscription-plans';
  static const String subscriptionDetails = '/subscription/:id';
  static const String subscriptionSuccess = '/subscription-success';
  static const String subscriptionFailure = '/subscription-failure';
  static const String subscriptionCancel = '/subscription-cancel';
  static const String dailyQuizResults = '/daily-quiz-results';
  static const String dailyQuizReview = '/daily-quiz-review';
}

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
  static const String educationVerification =
      '/subscription/education-verification';
  static const String subscriptionSuccess = '/subscription/success';
  static const String cancellationConfirmation =
      '/subscription/cancellation-confirmation';
  static const String profile = '/profile';
  static const String achievements = '/achievements';

  //Add routes here
}
