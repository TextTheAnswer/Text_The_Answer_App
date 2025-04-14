import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:text_the_answer/models/profile_model.dart';
import 'package:text_the_answer/models/user_profile_model.dart';
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:http_parser/http_parser.dart';

class ProfileService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api/';
  final AuthTokenService _tokenService = AuthTokenService();

  // Ensure the token is valid and refreshed
  Future<String?> _getAuthToken() async {
    try {
      // Get the token using AuthTokenService
      final token = await _tokenService.getToken();
      
      if (token == null) {
        print('ProfileService: No token available');
        return null;
      }
      
      // Simple token validation check
      if (token.isEmpty || token.length < 10) {
        print('ProfileService: Token appears to be invalid: ${token.substring(0, min(5, token.length))}...');
        return null;
      }
      
      print('ProfileService: Token validated');
      return token;
    } catch (e) {
      print('ProfileService: Error getting token: $e');
      return null;
    }
  }

  // Create or update user profile
  Future<ProfileResponse> createProfile({
    String? bio,
    String? location,
    File? profileImageFile,
    ProfilePreferences? preferences,
  }) async {
    try {
      print('ProfileService: Starting createProfile API call');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      print('ProfileService: Token retrieved: ${token != null ? "Valid token" : "No token"}');
      
      if (token == null) {
        return ProfileResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // If there's a profile image file, upload it first using the new endpoint
      String? imageUrl;
      if (profileImageFile != null) {
        print('ProfileService: Uploading profile image first');
        imageUrl = await _uploadProfileImage(profileImageFile, token);
        
        if (imageUrl == null) {
          print('ProfileService: Image upload failed, but continuing with profile creation');
          // We'll continue with profile creation even if image upload fails
        } else {
          print('ProfileService: Image upload successful: $imageUrl');
        }
      }

      // Create profile data
      final profile = Profile(
        bio: bio,
        location: location,
        imageUrl: imageUrl,
        preferences: preferences,
      );

      print('ProfileService: Calling profile/create endpoint with token');
      
      // Make API request to create the profile
      final response = await http.post(
        Uri.parse('$baseUrl/profile/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profile.toJson()),
      );

      print('ProfileService: API response status: ${response.statusCode}');
      print('ProfileService: API response body: ${response.body}');

      // Process response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResponse.fromJson(data);
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {
          // Ignore parsing errors
        }

        return ProfileResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to create profile. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('ProfileService: Exception in createProfile: $e');
      return ProfileResponse(
        success: false,
        message: 'Error creating profile: ${e.toString()}',
      );
    }
  }

  // Upload profile image and return the URL
  Future<String?> _uploadProfileImage(File imageFile, String token) async {
    try {
      print('ProfileService: Creating multipart request for image upload');
      
      // Create a multipart request for the new endpoint
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/profile/image'),
      );

      // Add authorization header
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add the image file with the field name 'image' as specified in the API docs
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      print('ProfileService: Adding image file to request (size: ${fileLength} bytes)');
      
      final multipartFile = http.MultipartFile(
        'image', // Use 'image' as the field name according to API docs
        fileStream,
        fileLength,
        filename: 'profile_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);

      // Send the request
      print('ProfileService: Sending image upload request to /api/profile/image');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('ProfileService: Image upload response status: ${response.statusCode}');
      print('ProfileService: Image upload response body: ${response.body}');

      // Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract imageUrl from the profile object according to the API docs
        return data['profile']['imageUrl']; 
      } else {
        print('Error uploading image: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception uploading image: $e');
      return null;
    }
  }

  // Get user profile
  Future<ProfileResponse> getProfile() async {
    try {
      print('ProfileService: Getting user profile');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      if (token == null) {
        return ProfileResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('ProfileService: Get profile response status: ${response.statusCode}');

      // Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileResponse.fromJson(data);
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {
          // Ignore parsing errors
        }

        print('ProfileService: Get profile error: ${errorData['message']}');
        return ProfileResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get profile. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('ProfileService: Exception in getProfile: $e');
      return ProfileResponse(
        success: false,
        message: 'Error getting profile: ${e.toString()}',
      );
    }
  }

  // Get full user profile
  Future<ProfileFullResponse> getFullProfile() async {
    try {
      print('ProfileService: Getting full user profile');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      if (token == null) {
        return ProfileFullResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$baseUrl/profile/full'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('ProfileService: Get full profile response status: ${response.statusCode}');

      // Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProfileFullResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        // User found but no profile data exists yet
        print('ProfileService: No profile data exists yet');
        return ProfileFullResponse(
          success: false,
          message: 'No profile data exists yet. Please create your profile.',
        );
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {
          // Ignore parsing errors
        }
        
        print('ProfileService: Get full profile error: ${errorData['message']}');
        return ProfileFullResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get profile. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('ProfileService: Exception in getFullProfile: $e');
      return ProfileFullResponse(
        success: false,
        message: 'Error getting profile: ${e.toString()}',
      );
    }
  }

  // Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await _tokenService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Upload profile image as a separate operation
  Future<ProfileResponse> uploadProfileImage(File imageFile) async {
    try {
      print('ProfileService: Starting dedicated profile image upload');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      
      if (token == null) {
        return ProfileResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }
      
      // Upload the image
      final imageUrl = await _uploadProfileImage(imageFile, token);
      
      if (imageUrl == null) {
        return ProfileResponse(
          success: false,
          message: 'Failed to upload profile image.',
        );
      }
      
      // Return success response with the image URL
      return ProfileResponse(
        success: true,
        message: 'Profile image uploaded successfully',
        profile: Profile(imageUrl: imageUrl),
      );
    } catch (e) {
      print('ProfileService: Exception in uploadProfileImage: $e');
      return ProfileResponse(
        success: false,
        message: 'Error uploading profile image: ${e.toString()}',
      );
    }
  }
} 