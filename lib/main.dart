import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import 'package:text_the_answer/utils/routing/route_config.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/quiz/quiz_bloc.dart';
import 'blocs/game/game_bloc.dart';
import 'blocs/leaderboard/leaderboard_bloc.dart';
import 'blocs/subscription/subscription_bloc.dart';
import 'blocs/profile/profile_bloc.dart';

// Create a global key for the navigator to access it from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Create a singleton instance of the AuthBloc to ensure it's the same throughout the app
final AuthBloc authBloc = AuthBloc();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Enable HTTP logging for debugging
  enableHttpLogging();

  // Configure Google Fonts to use local fonts as fallbacks
  FontUtility.configureGoogleFonts();

  // Initialize authentication with priority flag to ensure it's checked before any navigation
  authBloc.add(CheckAuthStatusEvent(silentCheck: true, priority: true));

  runApp(const MyApp());
}

// Enable detailed HTTP logging for debugging network requests
void enableHttpLogging() {
  // Override the default HTTP client with a logging client
  final client = http.Client();
  http.Client baseClient = client;
  
  // This is a simplified example since we can't fully override HTTP client in Flutter
  // But the logs we've added in ApiDebugUtil will help with detailed HTTP logging
  printDebug('HTTP logging enabled for debugging network requests');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            Provider<ApiService>.value(value: _apiService),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider(
                create: (context) => QuizBloc(apiService: _apiService),
              ),
              BlocProvider(create: (_) => GameBloc()),
              BlocProvider(create: (_) => LeaderboardBloc()),
              BlocProvider(
                create: (context) => SubscriptionBloc(apiService: _apiService),
              ),
              BlocProvider(create: (_) => ThemeCubit()),
              BlocProvider(create: (_) => ProfileBloc()),
            ],
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Text the Answer',
                  theme: state.themeData,
                  routerConfig: router,
                  builder: (context, child) {
                    return BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        printDebug('Auth state changed: ${state.runtimeType}');

                        if (state is AuthAuthenticated) {
                          context.goNamed(AppRouteName.home);
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Auth error: ${state.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (state is AuthInitial) {
                          // When auth state changes to initial (logged out), redirect to login
                          context.goNamed(AppRouteName.login);
                        }
                      },
                      child: child ?? Container(),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
