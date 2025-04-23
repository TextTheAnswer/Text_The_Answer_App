import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../main.dart';
import '../models/user.dart';
import '../router/routes.dart';

/// A utility class for easily accessing auth state from anywhere in the app
class AuthHelper {
  // Flag to track if a redirect is in progress
  static bool _isRedirecting = false;
  // Timeout duration for redirects
  static const _redirectTimeout = Duration(seconds: 8);
  
  /// Check if the user is authenticated
  static bool isAuthenticated() {
    return authBloc.state is AuthAuthenticated;
  }
  
  /// Get the current authenticated user
  static User? getCurrentUser() {
    if (authBloc.state is AuthAuthenticated) {
      return (authBloc.state as AuthAuthenticated).user;
    }
    return null;
  }
  
  /// Force a token refresh
  static Future<bool> refreshToken() async {
    print('AuthHelper: Refreshing token');
    // Add the refresh token event
    authBloc.add(RefreshTokenEvent());
    
    // Wait a short time for the token to refresh
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return current authentication status
    final isAuth = isAuthenticated();
    print('AuthHelper: After token refresh, authentication status: $isAuth');
    return isAuth;
  }
  
  /// Verify authentication status, optionally in silent mode (no loading state)
  static Future<bool> verifyAuthentication({bool silentCheck = false}) async {
    print('AuthHelper: Verifying authentication (silent: $silentCheck)');
    // Add the check auth status event
    authBloc.add(CheckAuthStatusEvent(silentCheck: silentCheck));
    
    // Wait a short time for authentication check to complete
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return current authentication status
    final isAuth = isAuthenticated();
    print('AuthHelper: After verification, authentication status: $isAuth');
    return isAuth;
  }
  
  /// Sign out the user
  static void signOut() {
    authBloc.add(SignOutEvent());
  }
  
  /// Redirect to login screen when authentication is required
  static void redirectToLogin(BuildContext context) {
    // Prevent multiple redirects
    if (_isRedirecting) return;
    
    _isRedirecting = true;
    
    // Clear the redirect flag after timeout to prevent deadlocks
    Timer(_redirectTimeout, () => _isRedirecting = false);
    
    // Use navigator key for reliable navigation
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    ).then((_) => _isRedirecting = false);
  }
  
  /// Handle authentication errors
  static void handleAuthError(String message) {
    authBloc.add(AuthErrorEvent(message));
  }
  
  /// Check authentication and redirect if not authenticated
  static Future<bool> checkAuthAndRedirectIfNeeded(BuildContext context) async {
    // Only check and redirect if we're not already redirecting
    if (_isRedirecting) return false;
    
    // First check if already authenticated
    if (isAuthenticated()) {
      return true;
    }
    
    print('AuthHelper: Not authenticated, trying token refresh first');
    
    // Try refreshing the token before giving up
    _isRedirecting = true;
    final refreshSucceeded = await refreshToken();
    
    // If refresh succeeded, we're good to go
    if (refreshSucceeded) {
      _isRedirecting = false;
      print('AuthHelper: Token refresh succeeded, not redirecting');
      return true;
    }
    
    // Token refresh failed, proceed with redirect
    print('AuthHelper: Token refresh failed, redirecting to login');
    
    // Show a snackbar with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentication required. Please login again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Redirect to login after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      redirectToLogin(context);
    });
    
    // Clear the redirect flag after timeout to prevent deadlocks
    Timer(_redirectTimeout, () => _isRedirecting = false);
    
    return false;
  }
} 