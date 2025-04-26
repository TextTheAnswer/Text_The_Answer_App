import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'auth_token_service.dart';
import '../models/lobby.dart';

class SocketService {
  io.Socket? socket;
  final String socketUrl = dotenv.env['SOCKET_IO_URL'] ?? 'http://localhost:3000';
  final AuthTokenService _tokenService = AuthTokenService();
  
  // Stream controllers for lobby events
  final lobbyStreamController = StreamController<Lobby>();
  final playerJoinedStreamController = StreamController<Map<String, dynamic>>();
  final playerLeftStreamController = StreamController<Map<String, dynamic>>();
  final playerReadyChangedStreamController = StreamController<Map<String, dynamic>>();
  final allPlayersReadyStreamController = StreamController<bool>();
  final errorStreamController = StreamController<String>();
  
  // Getter for streams
  Stream<Lobby> get onLobbyData => lobbyStreamController.stream;
  Stream<Map<String, dynamic>> get onPlayerJoined => playerJoinedStreamController.stream;
  Stream<Map<String, dynamic>> get onPlayerLeft => playerLeftStreamController.stream;
  Stream<Map<String, dynamic>> get onPlayerReadyChanged => playerReadyChangedStreamController.stream;
  Stream<bool> get onAllPlayersReady => allPlayersReadyStreamController.stream;
  Stream<String> get onError => errorStreamController.stream;
  
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();
  
  factory SocketService() {
    return _instance;
  }
  
  SocketService._internal();
  
  // Initialize and connect to socket with authentication
  Future<void> init() async {
    if (socket != null) {
      if (socket!.connected) return;
    }

    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      socket = io.io(
        '$socketUrl/game', 
        io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .setQuery({'token': token})
          .build()
      );

      _setupEventListeners();
      socket!.connect();
      
      if (kDebugMode) {
        print('Initializing Socket.IO connection to $socketUrl/game');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing socket connection: $e');
      }
      errorStreamController.add('Failed to connect: $e');
    }
  }

  void _setupEventListeners() {
    socket!.onConnect((_) {
      if (kDebugMode) {
        print('Connected to Socket.IO server');
      }
    });

    socket!.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected from Socket.IO server');
      }
    });
    
    socket!.on('lobby-data', (data) {
      if (kDebugMode) {
        print('Received lobby data: $data');
      }
      try {
        // Ensure data is properly formatted as a Map<String, dynamic>
        Map<String, dynamic> lobbyData;
        if (data is Map) {
          lobbyData = Map<String, dynamic>.from(data);
          
          // Ensure ID is always a string
          if (lobbyData['id'] != null) {
            lobbyData['id'] = lobbyData['id'].toString();
          }
          
          final lobby = Lobby.fromJson(lobbyData);
          lobbyStreamController.add(lobby);
        } else {
          print('Invalid lobby data format: $data');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing lobby data: $e');
          print('Raw data: $data');
        }
      }
    });
    
    socket!.on('player-joined', (data) {
      if (kDebugMode) {
        print('Player joined: $data');
      }
      playerJoinedStreamController.add(data);
    });
    
    socket!.on('player-left', (data) {
      if (kDebugMode) {
        print('Player left: $data');
      }
      playerLeftStreamController.add(data);
    });
    
    socket!.on('player-ready-changed', (data) {
      if (kDebugMode) {
        print('Player ready changed: $data');
      }
      playerReadyChangedStreamController.add(data);
    });
    
    socket!.on('all-players-ready', (_) {
      if (kDebugMode) {
        print('All players ready');
      }
      allPlayersReadyStreamController.add(true);
    });
    
    socket!.on('error', (data) {
      final errorMsg = data is String ? data : 'Socket error occurred';
      if (kDebugMode) {
        print('Socket error: $errorMsg');
      }
      errorStreamController.add(errorMsg);
    });
  }

  // Emit events

  // Join a lobby room by ID
  void joinGameLobby(dynamic lobbyId) {
    // Convert to string if it's not already a string
    final String stringLobbyId = lobbyId is String ? lobbyId : lobbyId.toString();
    
    if (socket == null || !socket!.connected) {
      init().then((_) {
        socket!.emit('join-lobby', stringLobbyId);
      });
    } else {
      socket!.emit('join-lobby', stringLobbyId);
    }
    
    if (kDebugMode) {
      print('Joining lobby: $stringLobbyId');
    }
  }

  // Leave a lobby room
  void leaveGameLobby(dynamic lobbyId) {
    final String stringLobbyId = lobbyId is String ? lobbyId : lobbyId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('leave-lobby', stringLobbyId);
      if (kDebugMode) {
        print('Leaving lobby: $stringLobbyId');
      }
    }
  }

  // Set player ready status
  void setReady(dynamic lobbyId, bool ready) {
    final String stringLobbyId = lobbyId is String ? lobbyId : lobbyId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('set-ready', {'lobbyId': stringLobbyId, 'ready': ready});
      if (kDebugMode) {
        print('Setting ready status to $ready for lobby: $stringLobbyId');
      }
    }
  }

  // Game-related socket methods
  void joinGame(dynamic gameId) {
    final String stringGameId = gameId is String ? gameId : gameId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('join-game', stringGameId);
    }
  }

  void startQuestion(dynamic gameId, int questionIndex) {
    final String stringGameId = gameId is String ? gameId : gameId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('start-question', {'gameId': stringGameId, 'questionIndex': questionIndex});
    }
  }
  
  // Leaderboard methods
  void subscribeToDailyLeaderboard() {
    if (socket != null && socket!.connected) {
      socket!.emit('subscribe-daily');
    }
  }

  void subscribeToGameLeaderboard(dynamic gameId) {
    final String stringGameId = gameId is String ? gameId : gameId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('subscribe-game', stringGameId);
    }
  }

  void unsubscribeFromDailyLeaderboard() {
    if (socket != null && socket!.connected) {
      socket!.emit('unsubscribe-daily');
    }
  }

  void unsubscribeFromGameLeaderboard(dynamic gameId) {
    final String stringGameId = gameId is String ? gameId : gameId.toString();
    
    if (socket != null && socket!.connected) {
      socket!.emit('unsubscribe-game', stringGameId);
    }
  }

  // Clean up resources
  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
    }
  }
  
  void dispose() {
    lobbyStreamController.close();
    playerJoinedStreamController.close();
    playerLeftStreamController.close();
    playerReadyChangedStreamController.close();
    allPlayersReadyStreamController.close();
    errorStreamController.close();
    disconnect();
  }
}