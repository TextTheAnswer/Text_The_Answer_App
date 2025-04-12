import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

// This class is maintained for backward compatibility
// but now delegates to ApiService instead of using Supabase directly
class SupabaseService {
  final ApiService _apiService = ApiService();

  // Delegates to ApiService.registerUser
  Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      final response = await _apiService.registerUser(email, password, name);
      // Converting ApiService response to format similar to Supabase AuthResponse
      return AuthResponse(user: null, session: null);
    } catch (e) {
      throw e;
    }
  }

  // Delegates to ApiService.loginUser
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _apiService.loginUser(email, password);
      // Converting ApiService response to format similar to Supabase AuthResponse
      return AuthResponse(user: null, session: null);
    } catch (e) {
      throw e;
    }
  }

  // Delegates to ApiService.logout
  Future<void> signOut() async {
    await _apiService.logout();
  }

  // Gets current user from token service
  User? getCurrentUser() {
    // This would need additional implementation to convert from your User model to Supabase User
    return null;
  }
}