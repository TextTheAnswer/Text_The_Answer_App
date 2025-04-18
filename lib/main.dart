import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/router/app_router.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart'; // This is your custom AuthState
import 'blocs/quiz/quiz_bloc.dart'; // Add missing import
import 'blocs/game/game_bloc.dart'; // Add missing import
import 'blocs/leaderboard/leaderboard_bloc.dart'; // Add missing import
import 'blocs/subscription/subscription_bloc.dart'; // Add missing import
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

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set the toggleTheme function in AppRouter
    AppRouter.toggleTheme = toggleTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design size based on iPhone 12 Pro dimensions
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
            ),
            BlocProvider(create: (_) => QuizBloc()),
            BlocProvider(create: (_) => GameBloc()),
            BlocProvider(create: (_) => LeaderboardBloc()),
            BlocProvider(create: (_) => SubscriptionBloc()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Text the Answer',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  } else if (state is AuthInitial) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.onboard, (route) => false);
                  }
                },
                child: child ?? Container(),
              );
            },
          ),
        );
      },
    );
  }
}
