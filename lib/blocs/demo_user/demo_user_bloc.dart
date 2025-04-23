import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/demo_user/demo_user_event.dart';
import 'package:text_the_answer/blocs/demo_user/demo_user_state.dart';
import 'package:text_the_answer/models/user.dart';
import 'package:text_the_answer/services/api_service.dart';

class DemoUserBloc extends Bloc<DemoUserEvent, DemoUserState> {
  final ApiService apiService;
  
  DemoUserBloc({required this.apiService}) : super(DemoUserInitial()) {
    on<CreateDemoUserEvent>(_onCreateDemoUser);
  }

  FutureOr<void> _onCreateDemoUser(
    CreateDemoUserEvent event,
    Emitter<DemoUserState> emit,
  ) async {
    emit(DemoUserLoading());
    try {
      final result = await apiService.createDemoUser(event.tier);
      final user = User.fromJson(result['user']);
      final message = 'Demo ${event.tier} user created successfully';
      emit(DemoUserCreated(user: user, message: message));
    } catch (e) {
      emit(DemoUserError(e.toString()));
    }
  }
}
