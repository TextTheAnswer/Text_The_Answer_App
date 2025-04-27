@Deprecated('To be removed in favoir of use with AppRoutePath with go router')
class AppRoutes {
  // Auth routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main navigation routes
  static const String home = '/home';
  static const String quiz = '/quiz';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Feature routes
  static const String dailyQuiz = '/daily-quiz';
  static const String gameResults = '/game-results';
  static const String leaderboard = '/leaderboard';
  static const String lobby = '/lobby';

  // Settings routes
  static const String manageSubscription = '/settings/manage-subscription';
  static const String editProfile = '/settings/edit-profile';
  static const String notifications = '/settings/notifications';
  static const String about = '/settings/about';
}
