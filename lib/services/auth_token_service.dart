import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    print('AuthTokenService: Saving token (first 10 chars): ${token.substring(0, min(10, token.length))}...');
    try {
      await _storage.write(key: _tokenKey, value: token);
      print('AuthTokenService: Token saved successfully');
    } catch (e) {
      print('AuthTokenService: Error saving token: $e');
      throw e;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null) {
        print('AuthTokenService: No token found in storage');
        return null;
      }
      
      print('AuthTokenService: Token retrieved (first 10 chars): ${token.substring(0, min(10, token.length))}...');
      return token;
    } catch (e) {
      print('AuthTokenService: Error retrieving token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      print('AuthTokenService: Deleting token');
      await _storage.delete(key: _tokenKey);
      print('AuthTokenService: Token deleted successfully');
    } catch (e) {
      print('AuthTokenService: Error deleting token: $e');
      throw e;
    }
  }
  
  // Utility function to get substring safely
  int min(int a, int b) {
    return a < b ? a : b;
  }
}