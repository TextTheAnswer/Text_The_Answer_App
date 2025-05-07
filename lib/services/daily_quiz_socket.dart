import 'package:socket_io_client/socket_io_client.dart' as IO;

class DailyQuizSocket {
  late IO.Socket socket;
  final String userId;
  final String serverUrl;

  DailyQuizSocket({required this.userId, required this.serverUrl}) {
    // Initialize socket
    socket = IO.io('$serverUrl/daily-quiz', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'userId': userId}
    });
    
    // Socket event listeners
    setupSocketListeners();
  }

  void connect() {
    socket.connect();
  }

  void disconnect() {
    socket.disconnect();
  }

  void setupSocketListeners() {
    // Connection events
    socket.on('connect', (_) {
      print('Connected to daily quiz socket');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from daily quiz socket');
    });

    socket.on('error', (data) {
      print('Socket error: ${data['message']}');
    });

    // Daily quiz events
    socket.on('event-started', (data) {
      print('Event started: $data');
      // Update your UI to show an active quiz event
    });

    socket.on('new-question', (data) {
      print('New question: $data');
      // Show the new question to the user
    });

    socket.on('question-ended', (data) {
      print('Question ended: $data');
      // Show results for this question
    });

    socket.on('answer-result', (data) {
      print('Answer result: $data');
      // Show the user their answer result
    });

    socket.on('event-ended', (data) {
      print('Event ended: $data');
      // Show event summary and results
    });

    socket.on('leaderboard-update', (data) {
      print('Leaderboard update: $data');
      // Update leaderboard UI
    });
  }

  // Join upcoming events notifications
  void joinUpcomingEvents() {
    socket.emit('join-upcoming-events');
  }

  // Join a specific quiz event
  void joinEvent(String quizId, String eventId) {
    socket.emit('join-event', {
      'quizId': quizId,
      'eventId': eventId
    });
  }

  // Submit an answer for a question
  void submitAnswer(String quizId, String eventId, int questionIndex, String answer) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    socket.emit('submit-answer', {
      'quizId': quizId,
      'eventId': eventId,
      'questionIndex': questionIndex,
      'answer': answer,
      'answerTime': timestamp
    });
  }

  // Get the current leaderboard
  void getLeaderboard(String quizId, String eventId) {
    socket.emit('get-leaderboard', {
      'quizId': quizId,
      'eventId': eventId
    });
  }
} 