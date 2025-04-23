import 'package:equatable/equatable.dart';
import 'package:text_the_answer/models/user.dart';

abstract class DemoUserState extends Equatable {
  const DemoUserState();
  
  @override
  List<Object> get props => [];
}

class DemoUserInitial extends DemoUserState {}

class DemoUserLoading extends DemoUserState {}

class DemoUserCreated extends DemoUserState {
  final User user;
  final String message;
  
  const DemoUserCreated({
    required this.user,
    required this.message,
  });
  
  @override
  List<Object> get props => [user, message];
}

class DemoUserError extends DemoUserState {
  final String message;
  
  const DemoUserError(this.message);
  
  @override
  List<Object> get props => [message];
}
