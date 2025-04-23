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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configure Google Fonts to use local fonts as fallbacks
  FontUtility.configureGoogleFonts();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  final ApiService _apiService = ApiService();

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    AppRouter.toggleTheme = toggleTheme;
    _apiService.useMockDataOnFailure = true;
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
              BlocProvider(
                create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
              ),
              BlocProvider(create: (context) => QuizBloc(apiService: _apiService)),
              BlocProvider(create: (_) => GameBloc()),
              BlocProvider(create: (_) => LeaderboardBloc()),
              BlocProvider(create: (context) => SubscriptionBloc(apiService: _apiService)),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Text the Answer',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              initialRoute: Routes.home,
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                return BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthAuthenticated) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.home,
                        (route) => false,
                      );
                    } else if (state is AuthInitial) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.onboard,
                        (route) => false,
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
