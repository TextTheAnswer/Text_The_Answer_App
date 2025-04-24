import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:text_the_answer/router/app_router.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/quiz/quiz_bloc.dart';
import 'blocs/game/game_bloc.dart';
import 'blocs/leaderboard/leaderboard_bloc.dart';
import 'blocs/subscription/subscription_bloc.dart';
import 'utils/theme.dart';

// Create a global key for the navigator to access it from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Create a singleton instance of the AuthBloc to ensure it's the same throughout the app
final AuthBloc authBloc = AuthBloc();

// Flag to prevent multiple redirects during navigation
bool _isNavigating = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configure Google Fonts to use local fonts as fallbacks
  FontUtility.configureGoogleFonts();
  
  // Initialize authentication - with silentCheck to avoid immediate loading state
  authBloc.add(CheckAuthStatusEvent(silentCheck: true));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Theme options: 'default', 'dark', 'light'
  String currentTheme = 'default';
  final ApiService _apiService = ApiService();

  void setTheme(String theme) {
    setState(() {
      currentTheme = theme;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Set up the theme functions
    AppRouter.toggleTheme = () {
      setState(() {
        currentTheme = currentTheme == 'dark' ? 'default' : 'dark';
      });
    };
    
    AppRouter.setTheme = (String theme) {
      if (theme != currentTheme) {
        print('Changing theme from $currentTheme to $theme');
        setState(() {
          currentTheme = theme;
          // Also update the static variable in AppRouter
          AppRouter.currentTheme = theme;
        });
      }
    };
    
    // _apiService.useMockDataOnFailure = true;
    print('Mock data fallback enabled for development');
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
              // Use the global authBloc instance instead of creating a new one
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider(create: (context) => QuizBloc(apiService: _apiService)),
              BlocProvider(create: (_) => GameBloc()),
              BlocProvider(create: (_) => LeaderboardBloc()),
              BlocProvider(create: (context) => SubscriptionBloc(apiService: _apiService)),
            ],
            child: MaterialApp(
              navigatorKey: navigatorKey, // Add the navigator key
              debugShowCheckedModeBanner: false,
              title: 'Text the Answer',
              theme: currentTheme == 'default' 
                ? AppTheme.defaultTheme() 
                : AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: currentTheme == 'dark' 
                ? ThemeMode.dark 
                : ThemeMode.light,
              initialRoute: Routes.splash,
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // Prevent navigation while another navigation is in progress
                    if (_isNavigating) return;
                    
                    print('Auth state changed: ${state.runtimeType}');
                    
                    if (state is AuthAuthenticated) {
                      _isNavigating = true;
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        Routes.home,
                        (route) => false,
                      ).then((_) => _isNavigating = false);
                    } else if (state is AuthInitial) {
                      _isNavigating = true;
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        Routes.onboard,
                        (route) => false,
                      ).then((_) => _isNavigating = false);
                    } else if (state is AuthError) {
                      // Show a snackbar with the error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Auth error: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: child ?? Container(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
