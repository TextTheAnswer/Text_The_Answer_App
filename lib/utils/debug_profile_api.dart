import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/auth_token_service.dart';
import '../config/api_config.dart';
import 'logger/debug_print.dart';

class DebugProfileApi extends StatelessWidget {
  const DebugProfileApi({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _testProfileApi() async {
    // Get auth token
    final authService = AuthTokenService();
    final token = await authService.getToken();
    
    if (token == null) {
      return {'error': 'No authentication token available'};
    }
    
    // Make the API call
    try {
      final baseUrl = ApiConfig.baseUrl;
      final url = '$baseUrl/profile/full';
      printDebug('Debug Profile API: Testing URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
      
      printDebug('Debug Profile API: Response status: ${response.statusCode}');
      printDebug('Debug Profile API: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Try to parse the JSON
        try {
          final jsonData = jsonDecode(response.body);
          return {
            'success': true,
            'data': jsonData,
            'structure': jsonData.keys.toList(),
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'JSON parse error: $e',
            'rawBody': response.body,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP error: ${response.statusCode}',
          'rawBody': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Profile API')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _testProfileApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data'));
          }
          
          final data = snapshot.data!;
          
          if (data['success'] == true) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API Call Successful', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Data Structure: ${data['structure']}'),
                  const SizedBox(height: 16),
                  const Text('Raw Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[200],
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert(data['data']),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('API Call Failed', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 16),
                  Text('Error: ${data['error']}'),
                  const SizedBox(height: 16),
                  if (data.containsKey('rawBody')) ...[
                    const Text('Raw Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: Text(data['rawBody'], style: const TextStyle(fontFamily: 'monospace')),
                    ),
                  ],
                ],
              ),
            );
          }
        },
      ),
    );
  }
} 