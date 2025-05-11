import 'package:flutter/foundation.dart';
import '../services/auth_token_service.dart';
import '../services/daily_quiz_socket.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// This is a utility function to test the daily quiz socket connection.
/// You can call this from anywhere in your app to verify the socket connection.
Future<void> testDailyQuizSocketConnection() async {
  final String socketUrl = dotenv.env['SOCKET_IO_URL'] ?? 'http://localhost:3000';
  final dailyQuizSocket = DailyQuizSocket(serverUrl: socketUrl);
  
  try {
    if (kDebugMode) {
      print('Testing connection to $socketUrl/daily-quiz');
    }
    
    await dailyQuizSocket.init();
    
    dailyQuizSocket.socket?.on('connect', (_) {
      if (kDebugMode) {
        print('Successfully connected to daily quiz socket');
      }
    });
    
    dailyQuizSocket.socket?.on('error', (data) {
      if (kDebugMode) {
        print('Socket connection error: $data');
      }
    });
    
    // Wait for 5 seconds to see if connection establishes
    await Future.delayed(const Duration(seconds: 5));
    
    // Check connection status
    if (dailyQuizSocket.socket?.connected ?? false) {
      if (kDebugMode) {
        print('Socket is connected!');
      }
    } else {
      if (kDebugMode) {
        print('Socket failed to connect after timeout');
      }
    }
    
    // Cleanup
    dailyQuizSocket.disconnect();
  } catch (e) {
    if (kDebugMode) {
      print('Error testing socket connection: $e');
    }
  }
} 