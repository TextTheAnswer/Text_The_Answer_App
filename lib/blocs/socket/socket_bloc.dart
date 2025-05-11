import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/socket_service.dart';
import 'socket_event.dart';
import 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketService _socketService = SocketService();
  StreamSubscription? _errorSubscription;
  
  SocketBloc() : super(SocketDisconnected()) {
    on<InitializeSocket>((event, emit) async {
      emit(SocketConnecting());
      try {
        await _socketService.init();
        _setupErrorListener();
        emit(SocketConnected());
      } catch (e) {
        emit(SocketError(message: 'Failed to initialize socket: $e'));
      }
    });
    
    on<DisconnectSocket>((event, emit) {
      _socketService.disconnect();
      _errorSubscription?.cancel();
      emit(SocketDisconnected());
    });
    
    on<SocketErrorEvent>((event, emit) {
      emit(SocketError(message: event.message));
    });
  }
  
  void _setupErrorListener() {
    _errorSubscription = _socketService.errorStreamController.stream.listen((errorMsg) {
      add(SocketErrorEvent(message: errorMsg));
    });
  }
  
  @override
  Future<void> close() {
    _errorSubscription?.cancel();
    return super.close();
  }
} 