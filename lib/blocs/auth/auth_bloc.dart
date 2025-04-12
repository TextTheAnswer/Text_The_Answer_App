import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/auth_token_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();
  final AuthTokenService _tokenService = AuthTokenService();

  AuthBloc() : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response =
            await _apiService.registerUser(event.email, event.password, event.name);
        emit(AuthAuthenticated(user: response['user']));
      } catch (e) {
        print('AuthBloc Error (SignUpEvent): $e'); // Debug statement
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response =
            await _apiService.loginUser(event.email, event.password);
        emit(AuthAuthenticated(user: response['user']));
      } catch (e) {
        print('AuthBloc Error (SignInEvent): $e'); // Debug statement
        emit(AuthError(message: e.toString()));
      }
    });

    on<AppleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _apiService.appleAuth(
            event.appleId, event.email, event.name);
        emit(AuthAuthenticated(user: response['user']));
      } catch (e) {
        print('AuthBloc Error (AppleSignInEvent): $e'); // Debug statement
        emit(AuthError(message: e.toString()));
      }
    });

    on<SignOutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await _apiService.logout();
        emit(AuthInitial());
      } catch (e) {
        print('AuthBloc Error (SignOutEvent): $e'); // Debug statement
        emit(AuthError(message: e.toString()));
      }
    });

    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await _tokenService.getToken();
        if (token != null) {
          final user = await _apiService.getUserProfile();
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        print('AuthBloc Error (CheckAuthStatusEvent): $e'); // Debug statement
        emit(AuthError(message: e.toString()));
      }
    });
  }
}