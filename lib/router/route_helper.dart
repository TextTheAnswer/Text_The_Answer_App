import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/routes.dart';
import '../screens/daily_quiz/daily_quiz_home_screen.dart';
import '../screens/daily_quiz/daily_quiz_realtime_screen.dart';
import '../screens/daily_quiz/quiz_review_screen.dart';
import '../screens/achievements/achievements_page.dart';

class RouteHelper {
  static void navigateToDailyQuizHome(BuildContext context) {
    context.push(AppRoutePath.dailyQuizHome);
  }
  
  static void navigateToDailyQuizRealtime(BuildContext context) {
    context.push(AppRoutePath.dailyQuizRealtime);
  }
  
  static void navigateToQuizReview(BuildContext context, List<Map<String, dynamic>> quizResults) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizReviewScreen(quizResults: quizResults),
      ),
    );
  }
  
  static void navigateToAchievements(BuildContext context) {
    context.push(AppRoutePath.achievements);
  }
  
  static void navigateToHome(BuildContext context) {
    context.go(AppRoutePath.home);
  }
  
  static void navigateBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      navigateToHome(context);
    }
  }
} 