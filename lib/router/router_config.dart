import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/daily_quiz/daily_quiz_home_screen.dart';
import '../screens/daily_quiz/daily_quiz_realtime_screen.dart';
import '../screens/achievements/achievements_page.dart';
import '../screens/auth/splash_screen.dart';
// import '../screens/home/new_home_screen.dart'; // Comment out if class doesn't exist
import 'routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  
  static GoRouter getRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutePath.splash,
      routes: [
        // Splash screen route
        GoRoute(
          path: AppRoutePath.splash,
          name: AppRouteName.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Home route
        GoRoute(
          path: AppRoutePath.home,
          name: AppRouteName.home,
          builder: (context, state) => const Scaffold(body: Center(child: Text('Home Screen'))), // Temporary placeholder
        ),
        
        // Daily Quiz routes
        GoRoute(
          path: AppRoutePath.dailyQuizHome,
          name: AppRouteName.dailyQuiz,
          builder: (context, state) => const DailyQuizHomeScreen(),
        ),
        GoRoute(
          path: AppRoutePath.dailyQuizRealtime,
          name: AppRouteName.dailyQuizRealtime,
          builder: (context, state) => const DailyQuizRealtimeScreen(),
        ),
        GoRoute(
          path: AppRoutePath.dailyQuiz,
          builder: (context, state) => const DailyQuizHomeScreen(), // Default to home screen
        ),
        
        // Library route (placeholder)
        GoRoute(
          path: AppRoutePath.library,
          name: AppRouteName.library,
          builder: (context, state) => const Scaffold(body: Center(child: Text('Library Screen'))),
        ),
        
        // Quiz route (placeholder)
        GoRoute(
          path: AppRoutePath.quiz,
          name: AppRouteName.quiz,
          builder: (context, state) => const Scaffold(body: Center(child: Text('Quiz Screen'))),
        ),
        
        // Achievements route
        GoRoute(
          path: AppRoutePath.achievements,
          name: AppRouteName.achievements,
          builder: (context, state) => const AchievementsPage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri.path}'),
        ),
      ),
    );
  }
} 