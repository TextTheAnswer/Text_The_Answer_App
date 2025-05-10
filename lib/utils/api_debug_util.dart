import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiDebugUtil {
  /// Logs the details of an HTTP request
  static void logRequest(String url, Map<String, String> headers, {String? body}) {
    if (!kDebugMode) return;
    
    print('┌───────────────────────────────────────────────');
    print('│ 🚀 HTTP REQUEST');
    print('├───────────────────────────────────────────────');
    print('│ URL: $url');
    print('│ HEADERS:');
    headers.forEach((key, value) {
      // Truncate authorization header to hide most of the token
      if (key.toLowerCase() == 'authorization' && value.length > 15) {
        print('│   $key: ${value.substring(0, 15)}...');
      } else {
        print('│   $key: $value');
      }
    });
    
    if (body != null) {
      print('│ BODY:');
      print('│   $body');
    }
    print('└───────────────────────────────────────────────');
  }

  /// Logs the details of an HTTP response
  static void logResponse(http.Response response) {
    if (!kDebugMode) return;
    
    print('┌───────────────────────────────────────────────');
    print('│ 📥 HTTP RESPONSE');
    print('├───────────────────────────────────────────────');
    print('│ STATUS CODE: ${response.statusCode}');
    print('│ REASON: ${response.reasonPhrase}');
    print('│ HEADERS:');
    response.headers.forEach((key, value) {
      print('│   $key: $value');
    });
    
    print('│ BODY:');
    try {
      // Try to format JSON response for better readability
      final dynamic decoded = jsonDecode(response.body);
      final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      print('│   $formatted');
    } catch (e) {
      // If not valid JSON, print raw body
      print('│   ${response.body}');
    }
    print('└───────────────────────────────────────────────');
  }

  /// Perform a debug API call to the given URL and log all details
  static Future<http.Response> debugApiCall(
    String url, {
    Map<String, String>? headers,
    String? method = 'GET',
    String? body,
  }) async {
    // Set default headers if none provided
    headers ??= {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
    };
    
    // Add timestamp to URL to prevent caching
    final timestampedUrl = url.contains('?') 
        ? '$url&_debug_t=${DateTime.now().millisecondsSinceEpoch}' 
        : '$url?_debug_t=${DateTime.now().millisecondsSinceEpoch}';
    
    // Log the request
    logRequest(timestampedUrl, headers, body: body);
    
    // Perform the request
    http.Response response;
    if (method == 'GET') {
      response = await http.get(Uri.parse(timestampedUrl), headers: headers);
    } else if (method == 'POST') {
      response = await http.post(Uri.parse(timestampedUrl), headers: headers, body: body);
    } else if (method == 'PUT') {
      response = await http.put(Uri.parse(timestampedUrl), headers: headers, body: body);
    } else if (method == 'DELETE') {
      response = await http.delete(Uri.parse(timestampedUrl), headers: headers);
    } else {
      throw ArgumentError('Unsupported HTTP method: $method');
    }
    
    // Log the response
    logResponse(response);
    
    return response;
  }
} 