abstract class SocketEvent {}

class InitializeSocket extends SocketEvent {}

class DisconnectSocket extends SocketEvent {}

class SocketErrorEvent extends SocketEvent {
  final String message;
  
  SocketErrorEvent({required this.message});
} 