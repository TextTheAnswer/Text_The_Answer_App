import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/achievement.dart';
import 'api_service.dart';
import 'auth_token_service.dart';

class AchievementService {
  final ApiService _apiService;
  final AuthTokenService _tokenService;
  final String baseUrl;

  AchievementService({
    required ApiService apiService,
    required AuthTokenService tokenService,
    required this.baseUrl,
  })  : _apiService = apiService,
        _tokenService = tokenService;

  // Get all public achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/achievements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['achievements'] != null) {
          try {
            final achievementsList = (data['achievements'] as List);
            final achievements = <Achievement>[];
            
            // Process each achievement separately with error handling
            for (final json in achievementsList) {
              try {
                achievements.add(Achievement.fromJson(json));
              } catch (e) {
                debugPrint('Error parsing individual achievement: $e');
                debugPrint('Problematic achievement data: $json');
                // Continue with other achievements even if one fails
              }
            }
            
            return achievements;
          } catch (parsingError) {
            debugPrint('Error parsing achievements list: $parsingError');
            debugPrint('Response data: ${response.body}');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching all achievements: $e');
      return [];
    }
  }

  // Get user's achieved achievements
  Future<List<Achievement>> getUserAchievements() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/achievements/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['achievements'] != null) {
          try {
            final achievementsList = (data['achievements'] as List);
            final achievements = <Achievement>[];
            
            // Process each achievement separately with error handling
            for (final json in achievementsList) {
              try {
                achievements.add(Achievement.fromJson(json));
              } catch (e) {
                debugPrint('Error parsing individual achievement: $e');
                debugPrint('Problematic achievement data: $json');
                // Continue with other achievements even if one fails
              }
            }
            
            return achievements;
          } catch (parsingError) {
            debugPrint('Error parsing achievements list: $parsingError');
            debugPrint('Response data: ${response.body}');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching user achievements: $e');
      return [];
    }
  }

  // Get achievement progress
  Future<Map<String, dynamic>> getAchievementProgress() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return {};

      final response = await http.get(
        Uri.parse('$baseUrl/achievements/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['progress'] != null) {
          return data['progress'] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching achievement progress: $e');
      return {};
    }
  }

  // Get hidden achievements
  Future<List<Achievement>> getHiddenAchievements() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/achievements/hidden'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['hiddenAchievements'] != null) {
          try {
            final achievementsList = (data['hiddenAchievements'] as List);
            final achievements = <Achievement>[];
            
            // Process each achievement separately with error handling
            for (final json in achievementsList) {
              try {
                achievements.add(Achievement.fromJson(json));
              } catch (e) {
                debugPrint('Error parsing individual hidden achievement: $e');
                debugPrint('Problematic achievement data: $json');
                // Continue with other achievements even if one fails
              }
            }
            
            return achievements;
          } catch (parsingError) {
            debugPrint('Error parsing hidden achievements list: $parsingError');
            debugPrint('Response data: ${response.body}');
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching hidden achievements: $e');
      return [];
    }
  }

  // Mark achievement as viewed
  Future<bool> markAchievementAsViewed(String achievementId) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/achievements/$achievementId/viewed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking achievement as viewed: $e');
      return false;
    }
  }
} 