abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  SignUpEvent({required this.email, required this.password, required this.name});
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class AppleSignInEvent extends AuthEvent {
  final String appleId;
  final String email;
  final String name;

  AppleSignInEvent({required this.appleId, required this.email, required this.name});
}

class SignOutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {
  final bool silentCheck;
  
  CheckAuthStatusEvent({this.silentCheck = false});
}

class RefreshTokenEvent extends AuthEvent {}

class AuthErrorEvent extends AuthEvent {
  final String message;
  
  AuthErrorEvent(this.message);
}