import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/services/auth_token_service.dart';

// Create a QuizEvent model class since it doesn't exist in models directory
class QuizEvent {
  final String id;
  final String title;
  final String startTime;
  
  QuizEvent({required this.id, required this.title, required this.startTime});
  
  factory QuizEvent.fromJson(Map<String, dynamic> json) {
    return QuizEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unnamed Event',
      startTime: json['startTime'] ?? json['startAt'] ?? 'TBD',
    );
  }
}

class UpcomingEventsScreen extends StatefulWidget {
  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<QuizEvent> upcomingEvents = [];
  bool isLoading = true;
  final AuthTokenService _tokenService = AuthTokenService();

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvents();
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      // Get token for API call
      final String? token = await _tokenService.getToken();
      
      // API call to get upcoming events
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/quiz/events/upcoming'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            upcomingEvents = (data['events'] as List)
                .map((event) => QuizEvent.fromJson(event))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching upcoming events: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Quiz Events'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : upcomingEvents.isEmpty
              ? Center(child: Text('No upcoming events found.'))
              : ListView.builder(
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text('Starts at: ${event.startTime}'),
                      onTap: () {
                        // Navigate to live quiz event screen or show details
                      },
                    );
                  },
                ),
    );
  }
} 