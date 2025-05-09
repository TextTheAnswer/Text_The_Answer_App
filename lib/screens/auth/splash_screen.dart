import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../config/colors.dart';
import '../../main.dart';
import '../../router/routes.dart';
import '../../utils/auth_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Check auth status after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  // Properly check authentication status and navigate
  void _checkAuthAndNavigate() {
    // Ensure we've only navigated once
    if (_hasNavigated) return;

    printDebug('SplashScreen: Checking auth status before navigation');

    // Verify auth status with priority flag to make sure it completes
    AuthHelper.verifyAuthentication(silentCheck: true, priority: true);

    // Set a timeout to ensure we navigate even if auth check is delayed
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        _navigateBasedOnAuthState();
      }
    });
  }

  void _navigateBasedOnAuthState() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    printDebug(
      'SplashScreen: Navigating based on auth state: ${authBloc.state.runtimeType}',
    );

    if (authBloc.state is AuthAuthenticated) {
      printDebug('SplashScreen: User is authenticated, navigating to home');
      context.go(AppRoutePath.home);
    } else {
      printDebug('SplashScreen: User is not authenticated, navigating to login');
      // Navigate to login instead of onboarding for a more direct flow
      context.go(AppRoutePath.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Listen for auth state changes to navigate
        if (!_hasNavigated &&
            (state is AuthAuthenticated || state is AuthInitial)) {
          printDebug(
            'SplashScreen: Auth state changed to ${state.runtimeType}, navigating',
          );
          _navigateBasedOnAuthState();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              colors: [AppColors.primary, AppColors.primary],
            ),
            // image: DecorationImage(
            //   image: AssetImage('assets/images/auth_bg_pattern.png'),
            //   fit: BoxFit.cover,
            //   opacity: 0.05,
            // ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/splash_page.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                const SizedBox(height: 90),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: SpinKitFadingCube(color: Colors.white, size: 50.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
