import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_the_answer/models/quiz_event.dart'; // Adjust the import based on your model location
import 'package:text_the_answer/services/api_service.dart'; // Adjust the import based on your API service location

class UpcomingEventsScreen extends StatefulWidget {
  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  List<QuizEvent> upcomingEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvents();
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      // API call to get upcoming events
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/quiz/events/upcoming'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            upcomingEvents = (data['events'] as List)
                .map((event) => QuizEvent.fromJson(event))
                .toList();
            isLoading = false;
          });
        }
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