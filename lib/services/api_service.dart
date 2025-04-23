import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/models/category.dart';
import 'package:text_the_answer/models/question.dart';
import 'package:text_the_answer/models/study_material.dart';
import 'package:text_the_answer/models/theme.dart';
import 'package:text_the_answer/models/user.dart';
import 'package:text_the_answer/models/lobby.dart';
import 'package:text_the_answer/models/leaderboard.dart';
import 'package:text_the_answer/services/auth_token_service.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  
  // Auth Endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> appleLogin(String appleToken, [String? email, String? name]) async {
    final Map<String, dynamic> requestBody = {
      'token': appleToken,
    };
    
    if (email != null) requestBody['email'] = email;
    if (name != null) requestBody['name'] = name;
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/apple'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to login with Apple: ${response.body}');
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await _clearToken();
    } else {
      throw Exception('Failed to logout: ${response.body}');
    }
  }

  // Demo User Endpoints
  Future<Map<String, dynamic>> createDemoUser(String tier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/demo-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tier': tier,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to create demo user: ${response.body}');
    }
  }

  // User Profile Endpoints
  Future<User> getProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  Future<User> getUserProfile() async {
    return await getProfile();
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl /api/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // Category Endpoints
  Future<List<Category>> getCategories() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> categoriesJson = data['categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get categories: ${response.body}');
    }
  }

  Future<Category> getCategoryById(String categoryId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categories/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Category.fromJson(data['category']);
    } else {
      throw Exception('Failed to get category: ${response.body}');
    }
  }

  // Theme Endpoints
  Future<ThemeModel> getCurrentTheme() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/themes/current'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ThemeModel.fromJson(data['theme']);
    } else {
      throw Exception('Failed to get current theme: ${response.body}');
    }
  }

  Future<List<ThemeModel>> getUpcomingThemes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/themes/upcoming'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> themesJson = data['themes'];
      return themesJson.map((json) => ThemeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get upcoming themes: ${response.body}');
    }
  }

  // Quiz Endpoints
  Future<Map<String, dynamic>> getDailyQuiz() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/daily'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> questionsJson = data['questions'];
      final List<Question> questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      
      return {
        'questions': questions,
        'questionsAnswered': data['questionsAnswered'] ?? 0,
        'correctAnswers': data['correctAnswers'] ?? 0,
        'theme': data['theme']['name'] ?? 'Daily Quiz',
        'themeDescription': data['theme']['description'] ?? '',
      };
    } else {
      throw Exception('Failed to get daily questions: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> submitDailyQuizAnswer(String questionId, String answer) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'questionId': questionId,
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit answer: ${response.body}');
    }
  }

  // Leaderboard Endpoints
  Future<Map<String, dynamic>> getDailyLeaderboard() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/daily'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> leaderboardData = data['leaderboard'];
      final List<LeaderboardEntry> leaderboardEntries = leaderboardData
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList();
      
      return {
        'leaderboard': leaderboardEntries,
        'userRank': data['userRank'] ?? 0,
      };
    } else {
      throw Exception('Failed to get daily leaderboard: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getGameLeaderboard(String gameId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/game/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> leaderboardData = data['leaderboard'];
      final List<LeaderboardEntry> leaderboardEntries = leaderboardData
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList();
      
      return {
        'leaderboard': leaderboardEntries,
        'userRank': data['userRank'] ?? 0,
      };
    } else {
      throw Exception('Failed to get game leaderboard: ${response.body}');
    }
  }

  // Multiplayer Endpoints
  Future<List<Map<String, dynamic>>> getPublicLobbies() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies/public'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['lobbies']);
    } else {
      throw Exception('Failed to get public lobbies: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createLobby(String name, bool isPrivate) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'isPrivate': isPrivate,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create lobby: ${response.body}');
    }
  }

  Future<Lobby> createGameLobby(String name, bool isPublic, int maxPlayers) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'isPublic': isPublic,
        'maxPlayers': maxPlayers
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Lobby.fromJson(data['lobby']);
    } else {
      throw Exception('Failed to create lobby: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> joinLobby(String lobbyId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join lobby: ${response.body}');
    }
  }

  Future<Lobby> joinGameLobby(String lobbyId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Lobby.fromJson(data['lobby']);
    } else {
      throw Exception('Failed to join lobby: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> leaveLobby(String lobbyId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies/$lobbyId/leave'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to leave lobby: ${response.body}');
    }
  }

  // Study Materials Endpoints (Education Tier)
  Future<List<StudyMaterial>> getStudyMaterials() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/study-materials'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> materialsJson = data['materials'];
      return materialsJson.map((json) => StudyMaterial.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get study materials: ${response.body}');
    }
  }

  Future<StudyMaterial> createStudyMaterial(String title, String content, List<String> tags) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/study-materials'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'tags': tags,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return StudyMaterial.fromJson(data['material']);
    } else {
      throw Exception('Failed to create study material: ${response.body}');
    }
  }

  Future<StudyMaterial> updateStudyMaterial(String id, Map<String, dynamic> updates) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/study-materials/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudyMaterial.fromJson(data['material']);
    } else {
      throw Exception('Failed to update study material: ${response.body}');
    }
  }

  Future<void> deleteStudyMaterial(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/study-materials/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete study material: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generateQuestionsFromMaterial(String materialId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/study-materials/$materialId/generate-questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate questions: ${response.body}');
    }
  }

  // Subscription Endpoints
  Future<Map<String, dynamic>> getSubscriptionDetails() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get subscription status: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createCheckoutSession({required String priceId}) async {
    final token = await _getToken();
    final Map<String, dynamic> requestBody = {'priceId': priceId};
    
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions/create-checkout-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> cancelSubscription() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel subscription: ${response.body}');
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> registerUser(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    return await login(email, password);
  }
  
  Future<Map<String, dynamic>> appleAuth(String appleId, String email, String name) async {
    return await appleLogin(appleId, email, name);
  }
  
  // Quiz methods
  Future<Map<String, dynamic>> getDailyQuestions() async {
    return await getDailyQuiz();
  }
  
  Future<Map<String, dynamic>> submitAnswer(String questionId, String answer) async {
    return await submitDailyQuizAnswer(questionId, answer);
  }
  
  // Leaderboard methods
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/daily'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['leaderboard']);
    } else {
      throw Exception('Failed to get daily leaderboard: ${response.body}');
    }
  }
  
  // Game methods
  Future<Map<String, dynamic>> startGame(String lobbyId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/games/start'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lobbyId': lobbyId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start game: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> submitGameAnswer(String gameId, String questionId, String answer) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/games/$gameId/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'questionId': questionId,
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit game answer: ${response.body}');
    }
  }
  
  Future<Map<String, dynamic>> getGameResults(String gameId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId/results'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get game results: ${response.body}');
    }
  }
  
  // Subscription methods
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get subscription status: ${response.body}');
    }
  }
  
  // Mock data setting
  bool _useMockDataOnFailure = false;
  
  set useMockDataOnFailure(bool value) {
    _useMockDataOnFailure = value;
  }
  
  bool get useMockDataOnFailure => _useMockDataOnFailure;

  // Token Management
  Future<void> _saveToken(String token) async {
    final authTokenService = AuthTokenService();
    await authTokenService.saveToken(token);
    print('ApiService: Token saved successfully');
  }

  Future<String?> _getToken() async {
    final authTokenService = AuthTokenService();
    final token = await authTokenService.getToken();
    if (token == null) {
      print('ApiService: No token found');
    } else {
      print('ApiService: Token retrieved successfully');
    }
    return token;
  }

  Future<void> _clearToken() async {
    final authTokenService = AuthTokenService();
    await authTokenService.deleteToken();
    print('ApiService: Token cleared successfully');
  }
}
