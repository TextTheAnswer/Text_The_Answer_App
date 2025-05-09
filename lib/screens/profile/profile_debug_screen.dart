import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:text_the_answer/utils/api_debug_util.dart';
import 'package:text_the_answer/widgets/custom_button.dart';

class ProfileDebugScreen extends StatefulWidget {
  const ProfileDebugScreen({Key? key}) : super(key: key);

  @override
  _ProfileDebugScreenState createState() => _ProfileDebugScreenState();
}

class _ProfileDebugScreenState extends State<ProfileDebugScreen> {
  bool _isLoading = false;
  String _debugResult = '';
  String _apiResponse = '';
  int _statusCode = 0;
  
  final baseUrl = ApiConfig.baseUrl;
  final AuthTokenService _tokenService = AuthTokenService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile API Debug'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile API Debug Tools',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Debug buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Test Profile API',
                    onPressed: _testProfileApi,
                    bgColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Debug Token',
                    onPressed: _debugToken,
                    bgColor: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Test with Cache Bypass',
                    onPressed: _testWithTimestamp,
                    bgColor: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Clear Results',
                    onPressed: () {
                      setState(() {
                        _debugResult = '';
                        _apiResponse = '';
                        _statusCode = 0;
                      });
                    },
                    bgColor: Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status code indicator
            if (_statusCode > 0)
              Container(
                padding: const EdgeInsets.all(8),
                color: _getStatusCodeColor(_statusCode),
                child: Text(
                  'Status Code: $_statusCode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Debug results
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_debugResult.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug Info:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[200],
                    child: Text(_debugResult),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_apiResponse.isNotEmpty) ...[
                    const Text(
                      'API Response:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Text(
                        _apiResponse,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _testProfileApi() async {
    setState(() {
      _isLoading = true;
      _debugResult = '';
      _apiResponse = '';
      _statusCode = 0;
    });
    
    try {
      final token = await _tokenService.getToken();
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _debugResult = 'No authentication token available';
        });
        return;
      }
      
      final url = '$baseUrl/profile/full';
      
      final response = await ApiDebugUtil.debugApiCall(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
      
      setState(() {
        _isLoading = false;
        _statusCode = response.statusCode;
        _debugResult = 'API Call Completed\n'
            'URL: $url\n'
            'Status: ${response.statusCode}\n'
            'Headers: ${response.headers.toString()}\n';
        
        try {
          _apiResponse = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        } catch (e) {
          _apiResponse = 'Raw response (not valid JSON): ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugResult = 'Error testing profile API: $e';
      });
    }
  }
  
  Future<void> _debugToken() async {
    setState(() {
      _isLoading = true;
      _debugResult = '';
      _apiResponse = '';
      _statusCode = 0;
    });
    
    try {
      final token = await _tokenService.getToken();
      
      setState(() {
        _isLoading = false;
        if (token == null) {
          _debugResult = 'No authentication token available';
        } else {
          // Show first 10 characters for security
          final shortToken = token.length > 10 ? '${token.substring(0, 10)}...' : token;
          _debugResult = 'Authentication Token: $shortToken\n'
              'Token Length: ${token.length} characters\n'
              'Token Valid: ${token.isNotEmpty && token.length > 10 ? 'Yes' : 'No'}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugResult = 'Error retrieving token: $e';
      });
    }
  }
  
  Future<void> _testWithTimestamp() async {
    setState(() {
      _isLoading = true;
      _debugResult = '';
      _apiResponse = '';
      _statusCode = 0;
    });
    
    try {
      final token = await _tokenService.getToken();
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _debugResult = 'No authentication token available';
        });
        return;
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = '$baseUrl/profile/full?_t=$timestamp&nocache=true';
      
      final response = await ApiDebugUtil.debugApiCall(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'If-None-Match': '',
          'If-Modified-Since': '',
        },
      );
      
      setState(() {
        _isLoading = false;
        _statusCode = response.statusCode;
        _debugResult = 'API Call with Cache Bypass Completed\n'
            'URL: $url\n'
            'Status: ${response.statusCode}\n'
            'Headers: ${response.headers.toString()}\n';
        
        try {
          _apiResponse = const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        } catch (e) {
          _apiResponse = 'Raw response (not valid JSON): ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _debugResult = 'Error testing with timestamp: $e';
      });
    }
  }
  
  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 