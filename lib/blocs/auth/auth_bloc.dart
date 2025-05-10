import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/models/user.dart';
import '../../services/api_service.dart';
import '../../services/auth_token_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();
  final AuthTokenService _tokenService = AuthTokenService();
  
  // Track the last token validation time
  DateTime? _lastTokenValidationTime;
  // Token validation interval - 5 minutes
  static const tokenValidationInterval = Duration(minutes: 5);

  AuthBloc() : super(AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<AppleSignInEvent>(_onAppleSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<AuthErrorEvent>(_onAuthError);
  }
  
  // Method to handle sign up
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.register(
        event.name,
        event.email,
        event.password,
      );
      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      // Update the last validation time
      _lastTokenValidationTime = DateTime.now();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (SignUpEvent): $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  // Method to handle sign in
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.login(
        event.email,
        event.password,
      );
      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      // Update the last validation time
      _lastTokenValidationTime = DateTime.now();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (SignInEvent): $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  // Method to handle Apple sign in
  Future<void> _onAppleSignIn(AppleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _apiService.appleLogin(
        event.appleId,
        event.email,
        event.name,
      );
      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      // Update the last validation time
      _lastTokenValidationTime = DateTime.now();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (AppleSignInEvent): $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  // Method to handle sign out
  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _apiService.logout();
      // Clear token validation time
      _lastTokenValidationTime = null;
      emit(AuthInitial());
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (SignOutEvent): $e');
      // Even if server logout fails, still clear local tokens and redirect to login
      await _tokenService.deleteToken();
      _lastTokenValidationTime = null;
      emit(AuthInitial());
    }
  }
  
  // Method to check authentication status
  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    // Skip loading state if called from a protected screen requiring immediate validation
    if (!event.silentCheck) {
      emit(AuthLoading());
    }
    
    try {
      // Don't emit the same state again to prevent unnecessary rebuilds and navigation
      final currentState = state;
      
      // Always validate token if priority is true or it's been a while since last validation
      final bool shouldValidateToken = event.priority || 
        _lastTokenValidationTime == null || 
        DateTime.now().difference(_lastTokenValidationTime!) > tokenValidationInterval;
        
      if (shouldValidateToken) {
        if (kDebugMode) print('AuthBloc: Validating token from server...');
        
        final token = await _tokenService.getToken();
        if (token != null && token.isNotEmpty) {
          try {
            // Validate token with the server
            final user = await _apiService.getUserProfile();
            // Update the last validation time
            _lastTokenValidationTime = DateTime.now();
            
            // Only emit if the state is different or if priority is true
            if (currentState is! AuthAuthenticated || event.priority) {
              emit(AuthAuthenticated(user: user));
            }
            return;
          } catch (e) {
            if (kDebugMode) print('AuthBloc: Token validation failed: $e');
            // Token is invalid, clear it
            await _tokenService.deleteToken();
            _lastTokenValidationTime = null;
            
            // Only emit if the state is different or if priority is true
            if (currentState is! AuthInitial || event.priority) {
              emit(AuthInitial());
            }
            return;
          }
        } else {
          // No token found
          _lastTokenValidationTime = null;
          
          // Only emit if the state is different or if priority is true
          if (currentState is! AuthInitial || event.priority) {
            emit(AuthInitial());
          }
          return;
        }
      } else {
        // Token was recently validated, just check current state
        if (currentState is AuthAuthenticated) {
          // Keep the same authenticated state
          if (kDebugMode) print('AuthBloc: Using cached authentication state');
          return;
        } else {
          // Force a revalidation
          final token = await _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            try {
              final user = await _apiService.getUserProfile();
              // Update the last validation time
              _lastTokenValidationTime = DateTime.now();
              
              // Only emit if the state is different
              if (currentState is! AuthAuthenticated) {
                emit(AuthAuthenticated(user: user));
              }
              return;
            } catch (e) {
              // Token is invalid
              await _tokenService.deleteToken();
              _lastTokenValidationTime = null;
              
              // Only emit if the state is different
              if (currentState is! AuthInitial) {
                emit(AuthInitial());
              }
              return;
            }
          } else {
            // Only emit if the state is different
            if (currentState is! AuthInitial) {
              emit(AuthInitial());
            }
            return;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (CheckAuthStatusEvent): $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  // Method to refresh token
  Future<void> _onRefreshToken(RefreshTokenEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Implement token refresh logic
      // For now, we'll just check the current token
      final token = await _tokenService.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          final user = await _apiService.getUserProfile();
          // Update the last validation time
          _lastTokenValidationTime = DateTime.now();
          emit(AuthAuthenticated(user: user));
        } catch (e) {
          // Token is invalid
          await _tokenService.deleteToken();
          _lastTokenValidationTime = null;
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      if (kDebugMode) print('AuthBloc Error (RefreshTokenEvent): $e');
      emit(AuthError(message: e.toString()));
    }
  }
  
  // Handle auth errors
  Future<void> _onAuthError(AuthErrorEvent event, Emitter<AuthState> emit) async {
    emit(AuthError(message: event.message));
    // Optionally, you could add logic here to retry authentication
    // or clear tokens based on the error type
  }
  
  // Public method to check if the user is authenticated
  // Can be called from any widget/screen
  bool isAuthenticated() {
    return state is AuthAuthenticated;
  }
  
  // Public method to get the current user
  User? getCurrentUser() {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }
  
  // Public method to verify authentication with optional silent check
  void verifyAuthentication({bool silentCheck = false}) {
    add(CheckAuthStatusEvent(silentCheck: silentCheck));
  }
  
  // Public method to force token refresh
  void refreshToken() {
    add(RefreshTokenEvent());
  }
}
