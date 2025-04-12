import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;
  final String socketUrl = dotenv.env['SOCKET_IO_URL']!;

  void connect() {
    socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });
  }

  void joinGameLobby(String lobbyId) {
    socket.emit('join-lobby', lobbyId);
  }

  void leaveGameLobby(String lobbyId) {
    socket.emit('leave-lobby', lobbyId);
  }

  void setReady(String lobbyId, bool ready) {
    socket.emit('set-ready', {'lobbyId': lobbyId, 'ready': ready});
  }

  void joinGame(String gameId) {
    socket.emit('join-game', gameId);
  }

  void startQuestion(String gameId, int questionIndex) {
    socket.emit('start-question', {'gameId': gameId, 'questionIndex': questionIndex});
  }

  void subscribeToDailyLeaderboard() {
    socket.emit('subscribe-daily');
  }

  void subscribeToGameLeaderboard(String gameId) {
    socket.emit('subscribe-game', gameId);
  }

  void unsubscribeFromDailyLeaderboard() {
    socket.emit('unsubscribe-daily');
  }

  void unsubscribeFromGameLeaderboard(String gameId) {
    socket.emit('unsubscribe-game', gameId);
  }

  void disconnect() {
    socket.disconnect();
  }
}