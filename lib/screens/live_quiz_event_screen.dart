import 'package:flutter/material.dart';
import 'package:text_the_answer/models/question.dart'; // Adjust the import based on your model location
import 'package:text_the_answer/services/daily_quiz_socket.dart';
import 'package:text_the_answer/services/api_service.dart'; // Adjust for user data

class LiveQuizEventScreen extends StatefulWidget {
  final String quizId;
  final String eventId;

  LiveQuizEventScreen({required this.quizId, required this.eventId});

  @override
  _LiveQuizEventScreenState createState() => _LiveQuizEventScreenState();
}

class _LiveQuizEventScreenState extends State<LiveQuizEventScreen> {
  late DailyQuizSocket quizSocket;
  Question? currentQuestion;
  int questionIndex = 0;
  bool waitingForNextQuestion = true;
  String? userAnswer;
  bool answerSubmitted = false;
  bool showResults = false;
  bool eventEnded = false;
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    setupSocket();
  }

  void setupSocket() {
    // Initialize socket
    quizSocket = DailyQuizSocket(
      userId: currentUser.id, // Replace with actual user ID retrieval
      serverUrl: apiBaseUrl, // Replace with your API base URL
    );

    // Add specific listeners for this screen
    quizSocket.socket.on('event-joined', (data) {
      // Handle event join success
      setState(() {
        questionIndex = data['currentQuestionIndex'] ?? 0;
        waitingForNextQuestion = true;
      });
    });

    quizSocket.socket.on('new-question', (data) {
      // New question received
      setState(() {
        currentQuestion = Question.fromJson(data['question']);
        questionIndex = data['questionIndex'];
        waitingForNextQuestion = false;
        answerSubmitted = false;
        userAnswer = null;
        showResults = false;
      });
      
      // Start timer for this question
      startQuestionTimer(data['timeLimit'] ?? 15);
    });

    quizSocket.socket.on('question-ended', (data) {
      // Show results for this question
      setState(() {
        showResults = true;
        waitingForNextQuestion = true;
      });
    });

    quizSocket.socket.on('event-ended', (data) {
      // Event has ended
      setState(() {
        eventEnded = true;
      });
      
      // Get final leaderboard
      quizSocket.getLeaderboard(widget.quizId, widget.eventId);
    });

    quizSocket.socket.on('leaderboard-update', (data) {
      // Update leaderboard
      setState(() {
        leaderboard = List<Map<String, dynamic>>.from(data['leaderboard']);
      });
    });

    // Connect and join event
    quizSocket.connect();
    quizSocket.joinEvent(widget.quizId, widget.eventId);
  }

  void submitAnswer(String answer) {
    if (answerSubmitted || currentQuestion == null) return;
    
    setState(() {
      userAnswer = answer;
      answerSubmitted = true;
    });
    
    quizSocket.submitAnswer(
      widget.quizId,
      widget.eventId,
      questionIndex,
      answer,
    );
  }

  void startQuestionTimer(int seconds) {
    // Implement timer functionality
    // This could be a countdown timer that updates the UI
  }

  @override
  void dispose() {
    quizSocket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Quiz Event'),
      ),
      body: eventEnded
          ? buildEventEndedUI()
          : waitingForNextQuestion
              ? buildWaitingUI()
              : buildQuestionUI(),
    );
  }

  Widget buildWaitingUI() {
    return Center(
      child: showResults
          ? Text('Question $questionIndex results. Waiting for next question...')
          : Text('Waiting for question ${questionIndex + 1}...'),
    );
  }

  Widget buildQuestionUI() {
    if (currentQuestion == null) {
      return Center(child: Text('Loading question...'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${questionIndex + 1}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(currentQuestion!.text, style: TextStyle(fontSize: 18)),
          SizedBox(height: 24),
          if (!answerSubmitted)
            TextField(
              onSubmitted: (value) {
                submitAnswer(value);
              },
              decoration: InputDecoration(
                labelText: 'Type your answer',
                border: OutlineInputBorder(),
              ),
            )
          else
            Text('Your answer: $userAnswer (Submitted)'),
        ],
      ),
    );
  }

  Widget buildEventEndedUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Ended!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Final Leaderboard:', style: TextStyle(fontSize: 20)),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return ListTile(
                  leading: Text('${index + 1}.'),
                  title: Text(entry['username'] ?? 'Unknown'),
                  trailing: Text('${entry['score']} points'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 