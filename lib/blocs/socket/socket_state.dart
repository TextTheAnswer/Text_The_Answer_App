abstract class SocketState {}

class SocketDisconnected extends SocketState {}

class SocketConnecting extends SocketState {}

class SocketConnected extends SocketState {}

class SocketError extends SocketState {
  final String message;
  
  SocketError({required this.message});
} 