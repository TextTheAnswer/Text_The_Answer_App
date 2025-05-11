import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../services/auth_token_service.dart';

class DailyQuizSocket {
  IO.Socket? socket;
  final AuthTokenService _authTokenService = AuthTokenService();
  final String serverUrl;

  DailyQuizSocket({
    required this.serverUrl,
  });

  Future<void> init() async {
    if (socket != null) {
      if (socket!.connected) return;
    }

    try {
      final token = await _authTokenService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final options = IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token, 'userId': await _getUserIdFromToken(token)})
          .build();

      socket = IO.io('$serverUrl/daily-quiz', options);

      _setupSocketListeners();
      socket!.connect();
      
      if (kDebugMode) {
        print('Initializing Socket.IO connection to $serverUrl/daily-quiz');
        print('AuthTokenService: Token retrieved (first 10 chars): ${token.substring(0, 10)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing daily quiz socket connection: $e');
      }
    }
  }

  // Extract userId from JWT token
  Future<String> _getUserIdFromToken(String token) async {
    try {
      // JWT tokens have three parts separated by dots
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      // Decode the payload (middle part)
      final payload = parts[1];
      
      // Base64 decode and parse as JSON
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);
      
      // Return the user ID from the payload
      return data['id'] ?? data['sub'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting userId from token: $e');
      }
      return '';
    }
  }

  void _setupSocketListeners() {
    socket!.onConnect((_) {
      if (kDebugMode) {
        print('Connected to daily quiz socket');
      }
    });

    socket!.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected from daily quiz socket');
      }
    });
    
    socket!.onError((data) {
      final errorMsg = data is String ? data : 'Socket error occurred';
      if (kDebugMode) {
        print('Socket error: $errorMsg');
      }
    });

    // Daily quiz events
    socket!.on('event-started', (data) {
      if (kDebugMode) {
        print('Event started: $data');
      }
    });

    socket!.on('new-question', (data) {
      if (kDebugMode) {
        print('New question: $data');
      }
    });

    socket!.on('question-ended', (data) {
      if (kDebugMode) {
        print('Question ended: $data');
      }
    });

    socket!.on('answer-result', (data) {
      if (kDebugMode) {
        print('Answer result: $data');
      }
    });

    socket!.on('event-ended', (data) {
      if (kDebugMode) {
        print('Event ended: $data');
      }
    });

    socket!.on('leaderboard-update', (data) {
      if (kDebugMode) {
        print('Leaderboard update: $data');
      }
    });
  }

  // Join upcoming events notifications
  void joinUpcomingEvents() {
    if (socket == null || !socket!.connected) {
      init().then((_) {
        socket!.emit('join-upcoming-events');
      });
    } else {
      socket!.emit('join-upcoming-events');
    }
  }

  // Join a specific quiz event
  void joinEvent(String quizId, String eventId) {
    if (socket == null || !socket!.connected) {
      init().then((_) {
        socket!.emit('join-event', {
          'quizId': quizId,
          'eventId': eventId
        });
      });
    } else {
      socket!.emit('join-event', {
        'quizId': quizId,
        'eventId': eventId
      });
    }
  }

  // Submit an answer for a question
  void submitAnswer(String quizId, String eventId, int questionIndex, String answer) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    if (socket != null && socket!.connected) {
      socket!.emit('submit-answer', {
        'quizId': quizId,
        'eventId': eventId,
        'questionIndex': questionIndex,
        'answer': answer,
        'answerTime': timestamp
      });
    }
  }

  // Get the current leaderboard
  void getLeaderboard(String quizId, String eventId) {
    if (socket != null && socket!.connected) {
      socket!.emit('get-leaderboard', {
        'quizId': quizId,
        'eventId': eventId
      });
    }
  }

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
    }
  }

  void dispose() {
    disconnect();
  }
} 