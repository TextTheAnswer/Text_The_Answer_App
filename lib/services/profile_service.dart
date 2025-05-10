import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';

class ProfileService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthTokenService _tokenService = AuthTokenService();

  Future<ProfileData?> getFullProfile() async {
    try {
      final token = await _tokenService.getToken();
      
      if (token == null || token.isEmpty) {
        printDebug('ProfileService: No authentication token found');
        throw Exception('Authentication token not found');
      }

      printDebug('ProfileService: Making API request to get full profile');
      
      final response = await http.get(
        Uri.parse('$baseUrl/profile/full'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      printDebug('Profile API Response Status: ${response.statusCode}');
      if (kDebugMode) {
        // Only print response body in debug mode to avoid leaking sensitive data
        printDebug('Profile API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data.containsKey('profile')) {
          printDebug('ProfileService: Successfully parsed profile data');
          return ProfileData.fromJson(data['profile']);
        } else {
          printDebug('ProfileService: Invalid response format: ${data['message']}');
          throw Exception('Invalid response format: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        // Handle unauthorized specifically - token may be expired
        printDebug('ProfileService: Authentication token expired or invalid');
        
        // Clear the token since it's invalid
        await _tokenService.deleteToken();
        
        throw Exception('Authentication token expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        printDebug('ProfileService: API error: ${errorData['message']}');
        throw Exception('Failed to fetch profile: ${errorData['message']}');
      }
    } catch (e) {
      printDebug('Error fetching profile: $e');
      rethrow; // Re-throw to let the bloc handle the error
    }
  }

  Future<bool> updateProfileInfo({
    String? name,
    String? bio,
    String? location,
    String? imageUrl,
    List<String>? favoriteCategories,
    Map<String, dynamic>? notificationSettings,
    String? displayTheme,
  }) async {
    try {
      final token = await _tokenService.getToken();
      
      if (token == null || token.isEmpty) {
        printDebug('ProfileService: No authentication token found for update');
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> updateData = {};
      
      // Main user fields
      if (name != null) updateData['name'] = name;
      
      // Profile fields
      if (bio != null) updateData['bio'] = bio;
      if (location != null) updateData['location'] = location;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;

      // Preferences fields
      if (favoriteCategories != null || notificationSettings != null || displayTheme != null) {
        Map<String, dynamic> preferences = {};
        
        if (favoriteCategories != null) {
          preferences['favoriteCategories'] = favoriteCategories;
        }
        
        if (notificationSettings != null) {
          preferences['notificationSettings'] = notificationSettings;
        }
        
        if (displayTheme != null) {
          preferences['displayTheme'] = displayTheme;
        }
        
        // Only add preferences to the update data if it's not empty
        if (preferences.isNotEmpty) {
          updateData['preferences'] = preferences;
        }
      }

      printDebug('ProfileService: Updating profile with data: $updateData');
      
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        printDebug('ProfileService: Profile update successful');
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        // Handle unauthorized specifically - token may be expired
        printDebug('ProfileService: Authentication token expired or invalid during update');
        
        // Clear the token since it's invalid
        await _tokenService.deleteToken();
        
        throw Exception('Authentication token expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        printDebug('ProfileService: API error during update: ${errorData['message']}');
        throw Exception('Failed to update profile: ${errorData['message']}');
      }
    } catch (e) {
      printDebug('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> createProfile({
    required String bio,
    required String location,
    required String profilePicture,
    required List<String> favoriteCategories,
    required Map<String, dynamic> notificationSettings,
    required String displayTheme,
  }) async {
    try {
      final token = await _tokenService.getToken();
      
      if (token == null || token.isEmpty) {
        printDebug('ProfileService: No authentication token found for profile creation');
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> requestData = {
        "bio": bio,
        "location": location,
        "profilePicture": profilePicture,
        "preferences": {
          "favoriteCategories": favoriteCategories,
          "notificationSettings": notificationSettings,
          "displayTheme": displayTheme
        }
      };

      printDebug('ProfileService: Creating profile with data: $requestData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/profile/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      printDebug('Profile Creation API Response Status: ${response.statusCode}');
      if (kDebugMode) {
        printDebug('Profile Creation API Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        printDebug('ProfileService: Profile creation successful: ${data['message']}');
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        // Handle unauthorized specifically - token may be expired
        printDebug('ProfileService: Authentication token expired or invalid during profile creation');
        
        // Clear the token since it's invalid
        await _tokenService.deleteToken();
        
        throw Exception('Authentication token expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        printDebug('ProfileService: API error during profile creation: ${errorData['message']}');
        throw Exception('Failed to create profile: ${errorData['message']}');
      }
    } catch (e) {
      printDebug('Error creating profile: $e');
      return false;
    }
  }
} 