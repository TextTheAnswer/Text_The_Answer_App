import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/question.dart';
import '../models/lobby.dart';
import '../models/leaderboard.dart';
import 'auth_token_service.dart';

// Mock data for development and testing
final List<Map<String, dynamic>> mockQuizQuestions = [
  {
    'id': 'q1',
    'text': 'What is the capital of France?',
    'options': ['Berlin', 'Paris', 'London', 'Madrid'],
    'category': 'Geography',
    'difficulty': 'easy',
    'correctAnswer': 1 // Paris
  },
  {
    'id': 'q2',
    'text': 'Who painted the Mona Lisa?',
    'options': ['Vincent Van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Michelangelo'],
    'category': 'Art',
    'difficulty': 'easy',
    'correctAnswer': 2 // Leonardo da Vinci
  },
  {
    'id': 'q3',
    'text': 'What is the chemical symbol for gold?',
    'options': ['Au', 'Ag', 'Fe', 'Go'],
    'category': 'Science',
    'difficulty': 'medium',
    'correctAnswer': 0 // Au
  }
];

class ApiService {
  static   String baseUrl = ApiConfig.baseUrl;
  final AuthTokenService _tokenService = AuthTokenService();
  
  // Flag to enable mock data when API is not available
  bool useMockDataOnFailure = true;

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = await _tokenService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        throw Exception('No token found');
      }
    }
    return headers;
  }

  // Authentication Endpoints
  Future<Map<String, dynamic>> registerUser(
      String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _tokenService.saveToken(data['token']);
        return {
          'user': User.fromJson(data['user']), // Convert JSON to User object
          'token': data['token'],
        };
      } else {
        final error = 'Failed to register: ${response.body}';
        print('API Error (registerUser): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (registerUser): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if the response has the expected structure
        if (data['success'] == true && data['token'] != null && data['user'] != null) {
          // Save JWT token
          await _tokenService.saveToken(data['token']);
          
          // Return user data and token
          return {
            'user': User.fromJson(data['user']),
            'token': data['token'],
            'message': data['message'] ?? 'Login successful',
          };
        } else {
          final error = 'Invalid response format: ${response.body}';
          print('API Error (loginUser): $error');
          throw Exception(error);
        }
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to login';
        print('API Error (loginUser): $message - ${response.body}');
        throw Exception(message);
      }
    } catch (e) {
      print('API Error (loginUser): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> appleAuth(
      String appleId, String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/apple/callback'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'appleId': appleId, 'email': email, 'name': name}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _tokenService.saveToken(data['token']);
        return {
          'user': User.fromJson(data['user']), // Convert JSON to User object
          'token': data['token'],
        };
      } else {
        final error = 'Failed to authenticate with Apple: ${response.body}';
        print('API Error (appleAuth): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (appleAuth): $e'); // Debug statement
      rethrow;
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = 'Failed to fetch profile: ${response.body}';
        print('API Error (getUserProfile): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getUserProfile): $e'); // Debug statement
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        await _tokenService.deleteToken();
      } else {
        final error = 'Failed to logout: ${response.body}';
        print('API Error (logout): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (logout): $e'); // Debug statement
      rethrow;
    }
  }

  // Daily Quiz Endpoints
  Future<Map<String, dynamic>> getDailyQuiz() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/daily'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Add detailed logging to help diagnose issues
        print('API Response (getDailyQuiz): ${response.body}');
        
        // Handle null questions array
        final questionsList = data['questions'] != null 
            ? (data['questions'] as List).map((q) => Question.fromJson(q)).toList()
            : <Question>[];
            
        return {
          'questions': questionsList,
          'questionsAnswered': data['questionsAnswered'] ?? 0,
          'correctAnswers': data['correctAnswers'] ?? 0,
        };
      } else {
        final error = 'Failed to fetch daily quiz: ${response.body}';
        print('API Error (getDailyQuiz): $error'); // Debug statement
        
        // Use mock data if enabled and API call fails
        if (useMockDataOnFailure) {
          print('Using mock quiz data as fallback');
          return _getMockDailyQuiz();
        }
        
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getDailyQuiz): $e'); // Debug statement
      
      // Use mock data if enabled and API call fails
      if (useMockDataOnFailure) {
        print('Using mock quiz data as fallback due to exception: $e');
        return _getMockDailyQuiz();
      }
      
      rethrow;
    }
  }
  
  // Helper method to generate mock quiz data
  Map<String, dynamic> _getMockDailyQuiz() {
    return {
      'questions': mockQuizQuestions.map((q) => Question.fromJson(q)).toList(),
      'questionsAnswered': 0,
      'correctAnswers': 0,
    };
  }

  Future<Map<String, dynamic>> submitDailyQuizAnswer(
      String questionId, int answer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/daily/submit'),
        headers: await _getHeaders(),
        body: jsonEncode({'questionId': questionId, 'answer': answer}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Add detailed logging
        print('API Response (submitDailyQuizAnswer): ${response.body}');
        
        // Return with default values for null fields
        return {
          'isCorrect': data['isCorrect'] ?? false,
          'correctAnswer': data['correctAnswer'] ?? 0,
          'explanation': data['explanation'] ?? 'No explanation available',
          'questionsAnswered': data['questionsAnswered'] ?? 0,
          'correctAnswers': data['correctAnswers'] ?? 0,
          'streak': data['streak'] ?? 0,
          'withinTimeLimit': data['withinTimeLimit'] ?? true,
        };
      } else {
        final error = 'Failed to submit answer: ${response.body}';
        print('API Error (submitDailyQuizAnswer): $error'); // Debug statement
        
        // Use mock data if enabled and API call fails
        if (useMockDataOnFailure) {
          print('Using mock answer response as fallback');
          return _getMockAnswerResponse(questionId, answer);
        }
        
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (submitDailyQuizAnswer): $e'); // Debug statement
      
      // Use mock data if enabled and API call fails
      if (useMockDataOnFailure) {
        print('Using mock answer response as fallback due to exception: $e');
        return _getMockAnswerResponse(questionId, answer);
      }
      
      rethrow;
    }
  }
  
  // Helper method to generate mock answer response
  Map<String, dynamic> _getMockAnswerResponse(String questionId, int answer) {
    // Find the question in mock data
    final questionIndex = mockQuizQuestions.indexWhere((q) => q['id'] == questionId);
    
    if (questionIndex == -1) {
      return {
        'isCorrect': false,
        'correctAnswer': 0,
        'explanation': 'Question not found',
        'questionsAnswered': 1,
        'correctAnswers': 0,
        'streak': 0,
        'withinTimeLimit': true,
      };
    }
    
    // Get the correct answer from the mock data
    final correctAnswer = mockQuizQuestions[questionIndex]['correctAnswer'] as int;
    final isCorrect = answer == correctAnswer;
    
    return {
      'isCorrect': isCorrect,
      'correctAnswer': correctAnswer,
      'explanation': isCorrect 
          ? 'That\'s correct!' 
          : 'The correct answer was ${mockQuizQuestions[questionIndex]['options'][correctAnswer]}',
      'questionsAnswered': questionIndex + 1,
      'correctAnswers': isCorrect ? 1 : 0,
      'streak': isCorrect ? 1 : 0,
      'withinTimeLimit': true,
    };
  }

  Future<Map<String, dynamic>> getDailyQuizLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/daily/leaderboard'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'leaderboard': (data['leaderboard'] as List)
              .map((e) => LeaderboardEntry.fromJson(e))
              .toList(),
          'userRank': data['userRank'],
          'winner': data['winner'],
        };
      } else {
        final error = 'Failed to fetch daily quiz leaderboard: ${response.body}';
        print('API Error (getDailyQuizLeaderboard): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getDailyQuizLeaderboard): $e'); // Debug statement
      rethrow;
    }
  }

  // Multiplayer Game Endpoints
  Future<Lobby> createLobby(String name, bool isPublic, int maxPlayers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/lobby'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'isPublic': isPublic,
          'maxPlayers': maxPlayers,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Lobby.fromJson(data['lobby']);
      } else {
        final error = 'Failed to create lobby: ${response.body}';
        print('API Error (createLobby): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (createLobby): $e'); // Debug statement
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPublicLobbies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/lobbies'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['lobbies']);
      } else {
        final error = 'Failed to fetch public lobbies: ${response.body}';
        print('API Error (getPublicLobbies): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getPublicLobbies): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Lobby> joinLobby(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/lobby/join'),
        headers: await _getHeaders(),
        body: jsonEncode({'code': code}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Lobby.fromJson(data['lobby']);
      } else {
        final error = 'Failed to join lobby: ${response.body}';
        print('API Error (joinLobby): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (joinLobby): $e'); // Debug statement
      rethrow;
    }
  }

  Future<void> leaveLobby(String lobbyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/game/lobby/$lobbyId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode != 200) {
        final error = 'Failed to leave lobby: ${response.body}';
        print('API Error (leaveLobby): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (leaveLobby): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> startGame(String lobbyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/lobby/$lobbyId/start'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'game': {
            'id': data['game']['id'],
            'questions': (data['game']['questions'] as List)
                .map((q) => Question.fromJson(q))
                .toList(),
            'players': data['game']['players'],
            'status': data['game']['status'],
          }
        };
      } else {
        final error = 'Failed to start game: ${response.body}';
        print('API Error (startGame): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (startGame): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitGameAnswer(
      String gameId, int questionIndex, int answer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/game/answer'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'gameId': gameId,
          'questionIndex': questionIndex,
          'answer': answer,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['result'];
      } else {
        final error = 'Failed to submit game answer: ${response.body}';
        print('API Error (submitGameAnswer): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (submitGameAnswer): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGameResults(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/results/$gameId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['results'];
      } else {
        final error = 'Failed to fetch game results: ${response.body}';
        print('API Error (getGameResults): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getGameResults): $e'); // Debug statement
      rethrow;
    }
  }

  // Leaderboard Endpoints
  Future<Map<String, dynamic>> getDailyLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/daily'),
        headers: await _getHeaders(requiresAuth: false),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'leaderboard': (data['leaderboard'] as List)
              .map((e) => LeaderboardEntry.fromJson(e))
              .toList(),
          'userRank': data['userRank'],
        };
      } else {
        final error = 'Failed to fetch daily leaderboard: ${response.body}';
        print('API Error (getDailyLeaderboard): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getDailyLeaderboard): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGameLeaderboard(String gameId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/game/$gameId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'leaderboard': (data['leaderboard'] as List)
              .map((e) => LeaderboardEntry.fromJson(e))
              .toList(),
          'userRank': data['userRank'],
        };
      } else {
        final error = 'Failed to fetch game leaderboard: ${response.body}';
        print('API Error (getGameLeaderboard): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getGameLeaderboard): $e'); // Debug statement
      rethrow;
    }
  }

  // Subscription Endpoints
  Future<Map<String, dynamic>> createCheckoutSession() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/checkout'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = 'Failed to create checkout session: ${response.body}';
        print('API Error (createCheckoutSession): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (createCheckoutSession): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSubscriptionDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription/details'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['subscription'];
      } else {
        final error = 'Failed to fetch subscription details: ${response.body}';
        print('API Error (getSubscriptionDetails): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (getSubscriptionDetails): $e'); // Debug statement
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscription/cancel'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = 'Failed to cancel subscription: ${response.body}';
        print('API Error (cancelSubscription): $error'); // Debug statement
        throw Exception(error);
      }
    } catch (e) {
      print('API Error (cancelSubscription): $e'); // Debug statement
      rethrow;
    }
  }

  // Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/password-reset/request'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to request password reset';
        print('API Error (requestPasswordReset): $message - ${response.body}');
        throw Exception(message);
      }
    } catch (e) {
      print('API Error (requestPasswordReset): $e');
      rethrow;
    }
  }

  // Verify password reset OTP
  Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/password-reset/verify'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
          'resetToken': data['resetToken'], // Save this token for the next step
        };
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to verify OTP';
        print('API Error (verifyPasswordResetOTP): $message - ${response.body}');
        throw Exception(message);
      }
    } catch (e) {
      print('API Error (verifyPasswordResetOTP): $e');
      rethrow;
    }
  }

  // Reset password after OTP verification
  Future<Map<String, dynamic>> resetPassword({
    required String email, 
    required String resetToken, 
    required String newPassword, 
    required String confirmPassword
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile/password-reset/reset'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Failed to reset password';
        print('API Error (resetPassword): $message - ${response.body}');
        throw Exception(message);
      }
    } catch (e) {
      print('API Error (resetPassword): $e');
      rethrow;
    }
  }
}