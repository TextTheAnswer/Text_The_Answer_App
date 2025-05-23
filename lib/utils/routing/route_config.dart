import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_state.dart';
import 'package:text_the_answer/main.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/screens/auth/forgot_password_screen.dart';
import 'package:text_the_answer/screens/auth/login_screen.dart';
import 'package:text_the_answer/screens/auth/onboarding_screen.dart';
import 'package:text_the_answer/screens/auth/otp_verification_screen.dart';
import 'package:text_the_answer/screens/auth/register_screen.dart';
import 'package:text_the_answer/screens/auth/reset_password_screen.dart';
import 'package:text_the_answer/screens/auth/splash_screen.dart';
import 'package:text_the_answer/screens/daily_quiz_screen.dart';
import 'package:text_the_answer/screens/game/game_mode_screen.dart';
import 'package:text_the_answer/screens/game/private_lobby_screen.dart';
import 'package:text_the_answer/screens/game/public_lobby_screen.dart';
import 'package:text_the_answer/screens/home/new_home_screen.dart';
import 'package:text_the_answer/screens/main_app_screen.dart';
import 'package:text_the_answer/screens/placeholder_profile_screen.dart';
import 'package:text_the_answer/screens/profile/profile_creation_screen.dart';
import 'package:text_the_answer/screens/settings/about_screen.dart';
import 'package:text_the_answer/screens/settings/help_center_screen.dart';
import 'package:text_the_answer/screens/settings/music_effect_screen.dart';
import 'package:text_the_answer/screens/settings/notification_screen.dart';
import 'package:text_the_answer/screens/settings/security_screen.dart';
import 'package:text_the_answer/screens/settings/settings_screen.dart';
import 'package:text_the_answer/screens/profile/profile_screen.dart';
import 'package:text_the_answer/screens/achievements/achievements_page.dart';
import 'package:text_the_answer/screens/achievements/library_achievements_page.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import 'package:text_the_answer/utils/theme/theme_utils.dart';
import 'package:text_the_answer/screens/daily_quiz/daily_quiz_realtime_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _sectionNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionNav');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: AppRoutePath.splash,
  redirect: (BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    printDebug(
      'Route redirect check - Auth state: ${authBloc.state.runtimeType}',
    );

    final noRedirectRoutes = [
      AppRoutePath.splash,
      AppRoutePath.onboarding,
      AppRoutePath.login,
      AppRoutePath.signup,
      AppRoutePath.forgotPassword,
      AppRoutePath.resetPassword,
    ];

    final isNoRedirectRoute = noRedirectRoutes.any(
      (route) => state.matchedLocation.startsWith(route),
    );

    if (isNoRedirectRoute &&
        isAuthenticated &&
        state.matchedLocation != AppRoutePath.splash) {
      return AppRoutePath.home;
    }

    if (!isNoRedirectRoute && !isAuthenticated) {
      return AppRoutePath.login;
    }

    return null;
  },
  routes: <RouteBase>[
    // -- Splash
    GoRoute(
      name: AppRouteName.splash,
      path: AppRoutePath.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // -- Onboarding
    GoRoute(
      name: AppRouteName.onboarding,
      path: AppRoutePath.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    // -- Login
    GoRoute(
      name: AppRouteName.login,
      path: AppRoutePath.login,
      builder: (context, state) => const LoginScreen(),
    ),
    // -- Signup
    GoRoute(
      name: AppRouteName.signup,
      path: AppRoutePath.signup,
      builder: (context, state) => const RegisterScreen(),
    ),
    // -- Forget Password
    GoRoute(
      name: AppRouteName.forgotPassword,
      path: AppRoutePath.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // -- OTP Verification
    GoRoute(
      name: AppRouteName.otpVerification,
      path: AppRoutePath.otpVerificationPattern,
      builder: (context, state) {
        final email = state.pathParameters['email'] ?? '';
        return OTPVerificationScreen(email: email);
      },
    ),
    // -- Reset Password
    GoRoute(
      name: AppRouteName.resetPassword,
      path: AppRoutePath.resetPassword,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final resetToken = state.uri.queryParameters['resetToken'] ?? '';
        return ResetPasswordScreen(email: email, resetToken: resetToken);
      },
    ),
    // -- Profile Creation
    GoRoute(
      name: AppRouteName.profileCreate,
      path: AppRoutePath.profileCreate,
      builder: (context, state) => const ProfileCreationScreen(),
    ),
    // -- Private Lobby
    GoRoute(
      path: AppRoutePath.privateLobby,
      name: AppRouteName.privateLobby,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PrivateLobbyScreen(),
    ),
    // -- Public Lobby
    GoRoute(
      path: AppRoutePath.publicLobby,
      name: AppRouteName.publicLobby,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PublicLobbyScreen(),
    ),
    // -- Settings
    GoRoute(
      name: AppRouteName.settings,
      path: AppRoutePath.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
      routes: <RouteBase>[
        // -- Notification
        GoRoute(
          name: AppRouteName.notification,
          path: AppRoutePath.notification,
          builder: (context, state) => NotificationScreen(),
        ),
        // -- Music and Effects
        GoRoute(
          name: AppRouteName.musicEffect,
          path: AppRoutePath.musicEffect,
          builder: (context, state) => MusicEffectScreen(),
        ),
        // -- Security
        GoRoute(
          name: AppRouteName.security,
          path: AppRoutePath.security,
          builder: (context, state) => SecurityScreen(),
        ),
        // -- Help Center
        GoRoute(
          name: AppRouteName.helpCenter,
          path: AppRoutePath.helpCenter,
          builder: (context, state) => HelpCenterScreen(),
        ),
        // -- About
        GoRoute(
          name: AppRouteName.about,
          path: AppRoutePath.about,
          builder: (context, state) => AboutScreen(),
        ),
      ],
    ),
    // -- Main App Screen
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainAppScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // -- Home
        StatefulShellBranch(
          navigatorKey: _sectionNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteName.home,
              path: AppRoutePath.home,
              builder: (context, state) {
                return HomeScreen();
              },
            ),
          ],
        ),
        // -- Library
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteName.library,
              path: AppRoutePath.library,
              builder: (context, state) {
                return const LibraryAchievementsPage();
              },
              routes: [
                // -- Achievements page as a subroute of Library
                GoRoute(
                  name: AppRouteName.achievements,
                  path: 'achievements',
                  builder: (context, state) {
                    return const AchievementsPage();
                  },
                ),
              ],
            ),
          ],
        ),
        // -- Game-Mode
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteName.gameMode,
              path: AppRoutePath.gameMode,
              builder: (context, state) {
                return GameModeScreen(
                  toggleTheme: ThemeUtils.getThemeToggler(context),
                );
              },
            ),
          ],
        ),
        // -- Quiz
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteName.quiz,
              path: AppRoutePath.quiz,
              builder: (context, state) {
                return DailyQuizScreen();
              },
            ),
          ],
        ),
        // -- Profile
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: AppRouteName.profile,
              path: AppRoutePath.profile,
              builder: (context, state) {
                return ProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
    // -- Real-Time Daily Quiz
    GoRoute(
      path: AppRoutePath.dailyQuizRealtime,
      name: AppRouteName.dailyQuizRealtime,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DailyQuizRealtimeScreen(),
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(body: Center(child: Text('No route defined')));
  },
);
