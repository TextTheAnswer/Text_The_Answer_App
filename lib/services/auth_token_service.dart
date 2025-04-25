import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';

class AuthTokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    printDebug(
      'AuthTokenService: Saving token (first 10 chars): ${token.substring(0, min(10, token.length))}...',
    );
    try {
      await _storage.write(key: _tokenKey, value: token);
      printDebug('AuthTokenService: Token saved successfully');
    } catch (e) {
      printDebug('AuthTokenService: Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        printDebug('AuthTokenService: No token found in storage');
        return null;
      }

      printDebug(
        'AuthTokenService: Token retrieved (first 10 chars): ${token.substring(0, min(10, token.length))}...',
      );
      return token;
    } catch (e) {
      printDebug('AuthTokenService: Error retrieving token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      printDebug('AuthTokenService: Deleting token');
      await _storage.delete(key: _tokenKey);
      printDebug('AuthTokenService: Token deleted successfully');
    } catch (e) {
      printDebug('AuthTokenService: Error deleting token: $e');
      rethrow;
    }
  }

  // Utility function to get substring safely
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
