import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:text_the_answer/models/profile_model.dart' as profile_model;
import 'package:text_the_answer/models/user_profile_model.dart';
import 'package:text_the_answer/models/user_profile_full_model.dart' as full_model;
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:text_the_answer/utils/api_debug_util.dart';
import 'package:http_parser/http_parser.dart';
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/services/api_service.dart';

// Alias for clearer use of the profile response classes
typedef ProfileResponse = profile_model.ProfileResponse;
typedef UserProfileFullResponse = full_model.ProfileResponse;
typedef ProfilePreferences = profile_model.ProfilePreferences;

class ProfileService {
  final ApiService _apiService;

  ProfileService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Get the API URL from ApiConfig to ensure consistency
  final String baseUrl = ApiConfig.baseUrl;
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
      
      print('ProfileService: Token validated: ${token.substring(0, 10)}...');
      return token;
    } catch (e) {
      print('ProfileService: Error getting token: $e');
      return null;
    }
  }

  // Create or update user profile
  Future<ProfileResponse> createProfile({
    required String displayName,
    String? bio,
    String? location,
    File? profileImageFile,
    profile_model.ProfilePreferences? preferences,
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

      // If there's a profile image file, upload it first using the image upload endpoint
      String? imageUrl;
      if (profileImageFile != null) {
        print('ProfileService: Uploading profile image first');
        imageUrl = await _uploadProfileImage(profileImageFile, token);
        
        if (imageUrl == null) {
          print('ProfileService: Image upload failed, but continuing with profile creation');
        } else {
          print('ProfileService: Image upload successful: $imageUrl');
        }
      }

      // Create profile data
      final Map<String, dynamic> profileData = {
        'displayName': displayName,
        'bio': bio,
        'location': location,
      };

      if (preferences != null) {
        profileData['preferences'] = preferences.toJson();
      }

      if (imageUrl != null) {
        profileData['imageUrl'] = imageUrl;
      }

      // Construct the proper URL with the correct API path
      // The baseUrl from ApiConfig is already http://localhost:3000/api
      // So we just need to append /profile/create directly
      final url = '${baseUrl}/profile/create';
      
      print('ProfileService: Calling profile API endpoint: $url');
      print('ProfileService: Profile data: $profileData');
      print('ProfileService: Using token: ${token.substring(0, min(10, token.length))}...');
      
      // Make API request to create the profile using the proper endpoint
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      print('ProfileService: API response status: ${response.statusCode}');
      print('ProfileService: API response body: ${response.body}');

      // Process response
      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ProfileService: Error parsing response body: $e');
        return ProfileResponse(
          success: false,
          message: 'Invalid response from server',
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProfileResponse(
          success: true,
          message: responseData['message'] ?? 'Profile created successfully',
          profile: responseData['profile'] != null 
              ? profile_model.Profile.fromJson(responseData['profile']) 
              : null,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('ProfileService: Authentication error');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Authentication required. Please login again.',
        );
      } else if (response.statusCode == 400) {
        print('ProfileService: Bad request error');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid profile data',
        );
      } else {
        print('ProfileService: Other error: ${response.statusCode}');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to create profile. Status: ${response.statusCode}',
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
      
      // Construct the proper URL with the correct API path
      final url = '${baseUrl}/profile/image';
          
      print('ProfileService: Upload image URL: $url');
      
      // Create a multipart request for the endpoint
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
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
      print('ProfileService: Sending image upload request');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('ProfileService: Image upload response status: ${response.statusCode}');
      print('ProfileService: Image upload response body: ${response.body}');

      // Process response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract imageUrl from the response
        return data['imageUrl']; 
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
      print('ProfileService: Getting user profile from auth/profile endpoint');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      if (token == null) {
        print('ProfileService: No valid token available for profile fetch');
        return ProfileResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Print token info for debugging (first few chars only for security)
      final shortToken = token.length > 10 ? '${token.substring(0, 10)}...' : token;
      print('ProfileService: Using token starting with: $shortToken');

      // Construct the correct URL - use the /profile/full endpoint for basic profile info
      final url = '${baseUrl}/profile/full';
      print('ProfileService: Calling API endpoint: $url');

      // Make API request with cache control headers to prevent 304 responses
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
      
      print('ProfileService: Get profile response status: ${response.statusCode}');
      print('ProfileService: Get profile response body: ${response.body}');

      // Process response
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('ProfileService: Successfully parsed profile response to JSON');
          print('ProfileService: Data structure: ${data.keys.toList()}');
          
          // Debug data structure in detail
          if (data.containsKey('user')) {
            print('ProfileService: Found user key at root level');
            print('ProfileService: User data structure: ${data['user'].keys.toList()}');
            
            // Check if profile is inside user
            if (data['user'] != null && data['user'].containsKey('profile')) {
              print('ProfileService: Found profile inside user object');
              return ProfileResponse(
                success: true,
                message: 'Profile retrieved successfully',
                profile: profile_model.Profile.fromJson(data['user']['profile']),
              );
            }
          }
          
          // Standard check for profile at root level
          if (data.containsKey('profile') && data['profile'] != null) {
            print('ProfileService: Profile data found in response');
            return ProfileResponse.fromJson(data);
          } else {
            // Try other common patterns seen in APIs
            if (data.containsKey('data') && data['data'] != null) {
              print('ProfileService: Found data key at root level');
              
              // Check if profile is inside data
              if (data['data'].containsKey('profile')) {
                print('ProfileService: Found profile inside data object');
                return ProfileResponse(
                  success: true,
                  message: 'Profile retrieved successfully',
                  profile: profile_model.Profile.fromJson(data['data']['profile']),
                );
              }
              
              // Check if data itself is the profile
              if (data['data'] is Map<String, dynamic>) {
                print('ProfileService: Data object might be the profile');
                return ProfileResponse(
                  success: true,
                  message: 'Profile retrieved successfully',
                  profile: profile_model.Profile.fromJson(data['data']),
                );
              }
            }
            
            print('ProfileService: No profile data in the response structure');
            print('ProfileService: Available keys in response: ${data.keys.toList()}');
            return ProfileResponse(
              success: false,
              message: 'No profile data in the response',
            );
          }
        } catch (e) {
          print('ProfileService: Error parsing profile response: $e');
          print('ProfileService: Raw response: ${response.body}');
          return ProfileResponse(
            success: false,
            message: 'Invalid response format',
          );
        }
      } else if (response.statusCode == 304) {
        // Handle 304 Not Modified - we need to fetch again with cache busting
        print('ProfileService: Received 304 Not Modified, refetching with cache busting');
        
        // Add a timestamp to force a fresh request
        final timestampedUrl = '$url?_t=${DateTime.now().millisecondsSinceEpoch}';
        
        final freshResponse = await http.get(
          Uri.parse(timestampedUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        );
        
        print('ProfileService: Fresh response status: ${freshResponse.statusCode}');
        
        if (freshResponse.statusCode == 200) {
          try {
            final data = jsonDecode(freshResponse.body);
            print('ProfileService: Fresh response data keys: ${data.keys.toList()}');
            
            if (data.containsKey('profile') && data['profile'] != null) {
              return ProfileResponse.fromJson(data);
            } else if (data.containsKey('user') && data['user']?.containsKey('profile')) {
              return ProfileResponse(
                success: true,
                message: 'Profile retrieved successfully',
                profile: profile_model.Profile.fromJson(data['user']['profile']),
              );
            } else if (data.containsKey('data') && data['data'] != null) {
              // Data might be the profile or contain the profile
              return ProfileResponse(
                success: true,
                message: 'Profile retrieved successfully',
                profile: data['data'].containsKey('profile') 
                    ? profile_model.Profile.fromJson(data['data']['profile'])
                    : profile_model.Profile.fromJson(data['data']),
              );
            }
          } catch (e) {
            print('ProfileService: Error parsing fresh response: $e');
          }
        }
        
        // If we still can't get the data, return an error
        return ProfileResponse(
          success: false,
          message: 'Unable to retrieve profile data. Please try again.',
        );
      } else if (response.statusCode == 404) {
        print('ProfileService: Profile not found (404)');
        return ProfileResponse(
          success: false,
          message: 'Profile not found. Please create your profile.',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('ProfileService: Authentication error (${response.statusCode})');
        return ProfileResponse(
          success: false,
          message: 'Authentication failed. Please login again.',
        );
      } else {
        print('ProfileService: Other error (${response.statusCode})');
        
        String errorMessage = 'Failed to get profile. Status: ${response.statusCode}';
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData.containsKey('message') && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
          print('ProfileService: Error message from server: $errorMessage');
        } catch (e) {
          // Ignore parsing errors
          print('ProfileService: Could not parse error response: $e');
        }

        return ProfileResponse(
          success: false,
          message: errorMessage,
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

  // Get full user profile from the updated endpoint
  Future<UserProfileFullResponse> getFullProfile() async {
    try {
      print('ProfileService: Getting full user profile from API endpoint');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      if (token == null) {
        print('ProfileService: No valid token available for full profile fetch');
        return UserProfileFullResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Print token info for debugging (first few chars only for security)
      final shortToken = token.length > 10 ? '${token.substring(0, 10)}...' : token;
      print('ProfileService: Using token starting with: $shortToken');

      // Use the /profile/full endpoint with a timestamp parameter to prevent caching
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = '${baseUrl}/profile/full?_t=$timestamp';
      print('ProfileService: Calling API endpoint: $url');

      // Make API request with cache control headers
      try {
        // Use the debug utility for better logging
        final response = await ApiDebugUtil.debugApiCall(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        );
        
        print('ProfileService: Get full profile response status: ${response.statusCode}');
        print('ProfileService: Get full profile response body: ${response.body}');
        
        // Process response
        if (response.statusCode == 200) {
          // First, try to parse the JSON regardless of structure
          try {
            final data = jsonDecode(response.body);
            print('ProfileService: Successfully parsed response as JSON');
            print('ProfileService: Response data keys: ${data.keys.toList()}');
            
            // Try multiple approaches to handle different API structures
            try {
              // Approach 1: Standard structure with profile field
              if (data.containsKey('profile') && data['profile'] != null) {
                print('ProfileService: Found profile data in standard format');
                return UserProfileFullResponse(
                  success: true,
                  profile: full_model.ProfileData.fromJson(data['profile']),
                );
              }
              
              // Approach 2: Root object is the profile itself
              else if (data.containsKey('id') || data.containsKey('email') || data.containsKey('name')) {
                print('ProfileService: Root object appears to be the profile data');
                
                // Check if we have enough data for a proper profile
                if (data.containsKey('id') && data.containsKey('email') && data.containsKey('name')) {
                  try {
                    final profile = full_model.ProfileData.fromJson(data);
                    return UserProfileFullResponse(
                      success: true,
                      profile: profile,
                    );
                  } catch (e) {
                    print('ProfileService: Error building full profile from root data: $e');
                    
                    // Try a minimal profile approach
                    return UserProfileFullResponse(
                      success: true,
                      profile: full_model.ProfileData.createMinimal(
                        id: data['id'] ?? '',
                        name: data['name'] ?? 'User',
                        email: data['email'] ?? '',
                        imageUrl: data['imageUrl'] ?? data['profile']?['imageUrl'],
                      ),
                    );
                  }
                }
              }
              
              // Approach 3: Data might be nested in a user object
              else if (data.containsKey('user') && data['user'] != null) {
                print('ProfileService: Found user object with profile data');
                try {
                  return UserProfileFullResponse(
                    success: true,
                    profile: full_model.ProfileData.fromJson(data['user']),
                  );
                } catch (e) {
                  print('ProfileService: Error parsing user data: $e');
                  
                  // Try with a minimal profile approach
                  final userData = data['user'];
                  if (userData is Map<String, dynamic>) {
                    return UserProfileFullResponse(
                      success: true,
                      profile: full_model.ProfileData.createMinimal(
                        id: userData['id'] ?? '',
                        name: userData['name'] ?? 'User',
                        email: userData['email'] ?? '',
                      ),
                    );
                  }
                }
              }
              
              // Approach 4: Data is in a nested 'data' field
              else if (data.containsKey('data') && data['data'] != null) {
                print('ProfileService: Found data field that might contain profile');
                final dataContent = data['data'];
                
                if (dataContent is Map<String, dynamic>) {
                  try {
                    return UserProfileFullResponse(
                      success: true,
                      profile: full_model.ProfileData.fromJson(dataContent),
                    );
                  } catch (e) {
                    print('ProfileService: Error parsing data content: $e');
                    
                    // Try minimal profile
                    if (dataContent.containsKey('name') || dataContent.containsKey('email')) {
                      return UserProfileFullResponse(
                        success: true,
                        profile: full_model.ProfileData.createMinimal(
                          id: dataContent['id'] ?? '',
                          name: dataContent['name'] ?? 'User',
                          email: dataContent['email'] ?? '',
                        ),
                      );
                    }
                  }
                }
              }
              
              // Approach 5: Check for the success structure but no profile
              else if (data.containsKey('success')) {
                print('ProfileService: Found success flag but no recognizable profile structure');
                final isSuccess = data['success'] == true;
                final message = data['message'] as String? ?? 'Unknown response format';
                
                return UserProfileFullResponse(
                  success: isSuccess,
                  message: message,
                );
              }
              
              // If we've tried everything and still can't parse it, return an error
              print('ProfileService: Could not determine proper profile structure');
              return UserProfileFullResponse(
                success: false,
                message: 'Invalid response format: Could not locate profile data',
              );
            } catch (structureError) {
              print('ProfileService: Error in structure processing: $structureError');
              
              // Last resort: Try to extract just the basic information for a minimal profile
              try {
                // Recursively search for an id, name, and email in the JSON structure
                Map<String, dynamic> extractedData = _recursivelyExtractProfileData(data);
                
                if (extractedData.containsKey('id') && extractedData.containsKey('name')) {
                  return UserProfileFullResponse(
                    success: true,
                    profile: full_model.ProfileData.createMinimal(
                      id: extractedData['id'],
                      name: extractedData['name'],
                      email: extractedData['email'] ?? '',
                    ),
                  );
                }
                
                // Truly couldn't find anything useful
                return UserProfileFullResponse(
                  success: false,
                  message: 'Could not extract valid profile data from response',
                );
              } catch (e) {
                print('ProfileService: Final extraction attempt failed: $e');
                return UserProfileFullResponse(
                  success: false,
                  message: 'Error parsing profile structure: ${structureError.toString()}',
                );
              }
            }
          } catch (jsonError) {
            print('ProfileService: JSON parsing error: $jsonError');
            print('ProfileService: Raw response that failed to parse: ${response.body}');
            return UserProfileFullResponse(
              success: false,
              message: 'Invalid JSON response: ${jsonError.toString()}',
            );
          }
        } 
        // Handle 304 Not Modified status code
        else if (response.statusCode == 304) {
          print('ProfileService: Received 304 Not Modified, refetching with new timestamp');
          
          // Create a fresh timestamp for this retry
          final freshTimestamp = DateTime.now().millisecondsSinceEpoch;
          final freshUrl = '${baseUrl}/profile/full?_t=$freshTimestamp&nocache=true';
          
          print('ProfileService: Retrying with URL: $freshUrl');
          
          final freshResponse = await ApiDebugUtil.debugApiCall(
            freshUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Cache-Control': 'no-cache, no-store, must-revalidate',
              'Pragma': 'no-cache',
              'If-None-Match': '', // Clear ETag
              'If-Modified-Since': '', // Clear modification time
            },
          );
          
          print('ProfileService: Fresh response status: ${freshResponse.statusCode}');
          print('ProfileService: Fresh response body: ${freshResponse.body}');
          
          if (freshResponse.statusCode == 200) {
            try {
              final data = jsonDecode(freshResponse.body);
              // Process the fresh data using the same logic as the main 200 path
              // But we'll simplify here - just return the profile if found
              if (data.containsKey('profile') && data['profile'] != null) {
                return UserProfileFullResponse(
                  success: true,
                  profile: full_model.ProfileData.fromJson(data['profile']),
                );
              }
              else if (data.containsKey('user') && data['user'] != null) {
                try {
                  return UserProfileFullResponse(
                    success: true,
                    profile: full_model.ProfileData.fromJson(data['user']),
                  );
                } catch (_) {}
              }
              else if (data.containsKey('id') && data.containsKey('email')) {
                try {
                  return UserProfileFullResponse(
                    success: true,
                    profile: full_model.ProfileData.fromJson(data),
                  );
                } catch (_) {
                  // Fallback to minimal profile
                  return UserProfileFullResponse(
                    success: true,
                    profile: full_model.ProfileData.createMinimal(
                      id: data['id'] ?? '',
                      name: data['name'] ?? 'User',
                      email: data['email'] ?? '',
                    ),
                  );
                }
              }
            } catch (e) {
              print('ProfileService: Error parsing fresh response: $e');
            }
          }
          
          // If still having issues, return error
          return UserProfileFullResponse(
            success: false,
            message: 'Unable to retrieve profile data after cache refresh. Please try again.',
          );
        }
        else if (response.statusCode == 401 || response.statusCode == 403) {
          print('ProfileService: Authentication error (${response.statusCode})');
          return UserProfileFullResponse(
            success: false,
            message: 'Authentication failed. Please login again.',
          );
        } else {
          print('ProfileService: Other error (${response.statusCode})');
          
          String errorMessage = 'Failed to get profile. Status: ${response.statusCode}';
          
          try {
            final errorData = jsonDecode(response.body);
            if (errorData.containsKey('message') && errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
            print('ProfileService: Parsed error message: $errorMessage');
          } catch (e) {
            // Ignore parsing errors
            print('ProfileService: Could not parse error response: $e');
          }
          
          return UserProfileFullResponse(
            success: false,
            message: errorMessage,
          );
        }
      } catch (httpError) {
        print('ProfileService: HTTP request error: $httpError');
        return UserProfileFullResponse(
          success: false,
          message: 'Failed to connect to server: ${httpError.toString()}',
        );
      }
    } catch (e) {
      print('ProfileService: Exception in getFullProfile: $e');
      return UserProfileFullResponse(
        success: false,
        message: 'Error getting profile: ${e.toString()}',
      );
    }
  }
  
  // Helper method to recursively search a complex JSON structure for profile data
  Map<String, dynamic> _recursivelyExtractProfileData(dynamic json, [Map<String, dynamic>? collected]) {
    collected ??= {};
    
    if (json is Map<String, dynamic>) {
      // Check for direct values
      if (json.containsKey('id') && !collected.containsKey('id')) {
        collected['id'] = json['id'];
      }
      if (json.containsKey('name') && !collected.containsKey('name')) {
        collected['name'] = json['name'];
      }
      if (json.containsKey('email') && !collected.containsKey('email')) {
        collected['email'] = json['email'];
      }
      
      // Recursively check nested objects
      for (var key in json.keys) {
        if (json[key] is Map || json[key] is List) {
          _recursivelyExtractProfileData(json[key], collected);
        }
      }
    } else if (json is List) {
      // Recursively check list items
      for (var item in json) {
        _recursivelyExtractProfileData(item, collected);
      }
    }
    
    return collected;
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
        profile: profile_model.Profile(imageUrl: imageUrl),
      );
    } catch (e) {
      print('ProfileService: Exception in uploadProfileImage: $e');
      return ProfileResponse(
        success: false,
        message: 'Error uploading profile image: ${e.toString()}',
      );
    }
  }

  // Test profile creation API
  Future<ProfileResponse> testProfileCreation() async {
    try {
      print('ProfileService: Testing profile creation API');
      
      // Get and ensure a valid authentication token
      final token = await _getAuthToken();
      if (token == null) {
        return ProfileResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Create test profile data with all required fields
      final Map<String, dynamic> testProfileData = {
        'displayName': 'Test User', // Required field
        'bio': 'Test bio from mobile app',
        'location': 'Test location',
        'preferences': {
          'favoriteCategories': ['Science', 'History'],
          'notificationSettings': { 'dailyQuizReminder': true, 'multiplayerInvites': false },
          'displayTheme': 'light'
        }
      };

      // Construct proper URL with correct API path
      final url = '${baseUrl}/profile/create';
          
      print('ProfileService: Test profile API URL: $url');
      print('ProfileService: Sending test profile data with token: ${token.substring(0, min(10, token.length))}...');
      
      // Make API request to create the profile
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(testProfileData),
      );

      print('ProfileService: Test API response status: ${response.statusCode}');
      print('ProfileService: Test API response body: ${response.body}');

      // Process response
      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ProfileService: Error parsing test response body: $e');
        return ProfileResponse(
          success: false,
          message: 'Invalid response from server',
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProfileResponse(
          success: true,
          message: 'Profile creation test successful',
          profile: responseData['profile'] != null 
              ? profile_model.Profile.fromJson(responseData['profile']) 
              : null,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('ProfileService: Authentication error in test');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Authentication required. Please login again.',
        );
      } else if (response.statusCode == 400) {
        print('ProfileService: Bad request error in test');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid profile data',
        );
      } else {
        print('ProfileService: Other error in test: ${response.statusCode}');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Test failed. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('ProfileService: Exception in testProfileCreation: $e');
      return ProfileResponse(
        success: false,
        message: 'Error testing profile creation: ${e.toString()}',
      );
    }
  }

  // Add API helper methods that were missing
  Future<String> get(String endpoint) async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('${baseUrl}${endpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.body;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await _getAuthToken();
    return await http.post(
      Uri.parse('${baseUrl}${endpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<ProfileResponse> fetchUserProfile() async {
    try {
      final response = await get('/profile');
      
      return ProfileResponse.fromJson(jsonDecode(response));
    } catch (e) {
      return ProfileResponse(success: false, message: e.toString());
    }
  }

  Future<bool> updateProfileDetails({
    String? name,
    String? bio,
    String? location,
    String? imageUrl,
  }) async {
    try {
      final response = await post(
        '/profile/update',
        body: {
          if (name != null) 'name': name,
          if (bio != null) 'bio': bio,
          if (location != null) 'location': location,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );
      
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePreferences({
    List<String>? favoriteCategories,
    Map<String, dynamic>? notificationSettings,
    String? displayTheme,
  }) async {
    try {
      final response = await post(
        '/profile/preferences',
        body: {
          if (favoriteCategories != null) 'favoriteCategories': favoriteCategories,
          if (notificationSettings != null) 'notificationSettings': notificationSettings,
          if (displayTheme != null) 'displayTheme': displayTheme,
        },
      );
      
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEducationEmail(String email) async {
    try {
      final response = await post(
        '/profile/education/verify',
        body: {'email': email},
      );
      
      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
}   