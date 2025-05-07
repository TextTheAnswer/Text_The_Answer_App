import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../models/question.dart';
import '../../../services/auth_token_service.dart';
import '../validators/validation.dart';

/// A debugging utility to directly fetch quiz data
class QuizHelper {
  /// Directly fetch daily quiz data from the API
  static Future<Map<String, dynamic>> fetchDailyQuiz() async {
    try {
      // Get the auth token
      final authTokenService = AuthTokenService();
      final token = await authTokenService.getToken();
      if (token == null) {
        debugPrint('QuizHelper: No auth token available');
        return {'error': 'No auth token available'};
      }
      
      // Make the API request
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quiz/daily'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      // Log the response for debugging
      debugPrint('QuizHelper: API Response status code - ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Parse the raw response
        final rawData = jsonDecode(response.body);
        debugPrint('QuizHelper: Raw data contains questions: ${rawData.containsKey("questions")}');
        
        // Debug the raw response 
        debugPrint('QuizHelper: Raw response data: ${response.body}');
        
        if (rawData.containsKey("questions")) {
          final questionsRaw = rawData["questions"];
          debugPrint('QuizHelper: Questions type: ${questionsRaw.runtimeType}');
          debugPrint('QuizHelper: Questions count: ${questionsRaw.length}');
          
          // Try to parse questions
          final List<Question> questions = [];
          for (var i = 0; i < questionsRaw.length; i++) {
            try {
              final questionData = questionsRaw[i];
              
              // Debug the question data
              debugPrint('QuizHelper: Question $i raw data: ${jsonEncode(questionData)}');
              
              // Extract the ID correctly - look for _id first, then id
              String questionId = "unknown";
              if (questionData.containsKey("_id")) {
                questionId = questionData["_id"].toString();
                debugPrint('QuizHelper: Found _id: $questionId');
              } else if (questionData.containsKey("id")) {
                questionId = questionData["id"].toString();
                debugPrint('QuizHelper: Found id: $questionId');
              }
              
              // Extract options or provide defaults
              List<String> options = [];
              if (questionData["options"] != null) {
                options = List<String>.from(questionData["options"]);
              }
              
              // Extract acceptedAnswers or use options as fallback
              List<String> acceptedAnswers = [];
              if (questionData["acceptedAnswers"] != null) {
                acceptedAnswers = List<String>.from(questionData["acceptedAnswers"]);
              } else if (options.isNotEmpty) {
                // If no accepted answers are provided, use options as fallback
                acceptedAnswers = List<String>.from(options);
              }
              
              final question = Question(
                id: questionId,
                text: questionData["text"]?.toString() ?? "No text",
                options: options,
                acceptedAnswers: acceptedAnswers,
                category: questionData["category"]?.toString() ?? "general",
                difficulty: questionData["difficulty"]?.toString() ?? "medium",
              );
              
              questions.add(question);
              debugPrint('QuizHelper: Added question: ${question.text} with ID: ${question.id}');
            } catch (e) {
              debugPrint('QuizHelper: Error parsing question $i: $e');
            }
          }
          
          debugPrint('QuizHelper: Successfully parsed ${questions.length} questions');
          
          return {
            'questions': questions,
            'questionsAnswered': rawData['questionsAnswered'] ?? 0,
            'correctAnswers': rawData['correctAnswers'] ?? 0,
          };
        }
      }
      
      return {'error': 'Failed to parse quiz data'};
    } catch (e, stackTrace) {
      debugPrint('QuizHelper: Error - $e');
      debugPrint('QuizHelper: Stack Trace - $stackTrace');
      return {'error': e.toString()};
    }
  }
  
  /// Submit multiple answers in bulk for the daily quiz
  static Future<Map<String, dynamic>> submitBulkAnswers(List<Map<String, dynamic>> answers) async {
    try {
      // Get the auth token
      final authTokenService = AuthTokenService();
      final token = await authTokenService.getToken();
      if (token == null) {
        debugPrint('QuizHelper: No auth token available for bulk submission');
        return {'error': 'No auth token available'};
      }
      
      // Filter out answers with invalid MongoDB ObjectIds
      final filteredAnswers = answers.where((answer) {
        final questionId = answer['questionId']?.toString();
        final isValid = CustomValidator.isValidObjectId(questionId);
        if (!isValid) {
          debugPrint('QuizHelper: Filtering out answer with invalid questionId: $questionId');
        }
        return isValid;
      }).toList();
      
      debugPrint('QuizHelper: Submitting ${filteredAnswers.length} valid answers in bulk (filtered from ${answers.length})');
      
      // Check if we have any valid answers to submit
      if (filteredAnswers.isEmpty) {
        debugPrint('QuizHelper: No valid answers to submit');
        return {
          'success': false,
          'message': 'No valid answers to submit. All question IDs were invalid or missing.'
        };
      }
      
      // Debug the request payload
      final requestBody = {
        'answers': filteredAnswers,
      };
      debugPrint('QuizHelper: Request body: ${jsonEncode(requestBody)}');
      
      // Make the API request
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quiz/daily/answers/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      // Log the response for debugging
      debugPrint('QuizHelper: Bulk submission API Response status code - ${response.statusCode}');
      debugPrint('QuizHelper: Bulk submission API Response body - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('QuizHelper: Bulk submission successful');
        return responseData;
      } else {
        debugPrint('QuizHelper: Bulk submission failed - ${response.body}');
        return {
          'success': false,
          'message': 'Failed to submit answers in bulk: ${response.body}',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('QuizHelper: Bulk submission error - $e');
      debugPrint('QuizHelper: Stack Trace - $stackTrace');
      return {
        'success': false,
        'message': 'Error submitting answers in bulk: $e',
      };
    }
  }
  
  /// Helper method to convert a list of timeRemaining values (seconds left) to timeSpent values
  static List<Map<String, dynamic>> convertToTimeSpent(
    List<Map<String, dynamic>> answersList, 
    {int totalTimePerQuestion = 15}
  ) {
    return answersList.map((answerData) {
      // If timeRemaining is provided, convert it to timeSpent
      if (answerData.containsKey('timeRemaining')) {
        final timeRemaining = answerData['timeRemaining'] as int;
        final timeSpent = (totalTimePerQuestion - timeRemaining).toDouble();
        
        // Create a new map without the timeRemaining key
        final Map<String, dynamic> newAnswerData = Map.from(answerData);
        newAnswerData.remove('timeRemaining');
        newAnswerData['timeSpent'] = timeSpent;
        
        return newAnswerData;
      }
      
      return answerData;
    }).toList();
  }
  
  /// Helper method to filter answers with valid question IDs
  static List<Map<String, dynamic>> filterValidQuestionIds(List<Map<String, dynamic>> answers) {
    return answers.where((answer) {
      final questionId = answer['questionId']?.toString();
      return CustomValidator.isValidObjectId(questionId);
    }).toList();
  }
}
