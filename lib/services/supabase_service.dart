import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

// This class is maintained for backward compatibility
// but now delegates to ApiService instead of using Supabase directly
class SupabaseService {
  final ApiService _apiService = ApiService();

  // Delegates to ApiService.registerUser
  

}