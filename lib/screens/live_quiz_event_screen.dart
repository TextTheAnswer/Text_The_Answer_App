import 'package:flutter/material.dart';
import 'package:text_the_answer/models/question.dart';
import 'package:text_the_answer/services/daily_quiz_socket.dart';
import 'package:text_the_answer/config/api_config.dart';
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:flutter/foundation.dart';

class LiveQuizEventScreen extends StatefulWidget {
  final String quizId;
  final String eventId;

  const LiveQuizEventScreen({Key? key, required this.quizId, required this.eventId}) : super(key: key);

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
  final AuthTokenService _authService = AuthTokenService();
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    try {
      // Initialize socket with server URL
      quizSocket = DailyQuizSocket(serverUrl: ApiConfig.baseUrl);
      
      // Initialize the socket connection
      await quizSocket.init();
      
      // Setup socket event listeners
      _setupSocketListeners();
      
      // Join event after socket initialization
      if (quizSocket.socket != null && quizSocket.socket!.connected) {
        quizSocket.joinEvent(widget.quizId, widget.eventId);
        if (kDebugMode) {
          print('Joined event: ${widget.eventId} for quiz: ${widget.quizId}');
        }
      } else {
        if (kDebugMode) {
          print('Socket not connected. Could not join event.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing socket: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    }
  }

  void _setupSocketListeners() {
    if (quizSocket.socket == null) return;
    
    quizSocket.socket!.on('event-joined', (data) {
      // Handle event join success
      if (mounted) {
        setState(() {
          questionIndex = data['currentQuestionIndex'] ?? 0;
          waitingForNextQuestion = true;
        });
      }
      if (kDebugMode) {
        print('Joined event successfully. Current question index: $questionIndex');
      }
    });

    quizSocket.socket!.on('new-question', (data) {
      // New question received
      if (mounted) {
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
      }
      if (kDebugMode) {
        print('New question received: ${currentQuestion?.text}');
      }
    });

    quizSocket.socket!.on('question-ended', (data) {
      // Show results for this question
      if (mounted) {
        setState(() {
          showResults = true;
          waitingForNextQuestion = true;
        });
      }
      if (kDebugMode) {
        print('Question ended. Showing results.');
      }
    });

    quizSocket.socket!.on('event-ended', (data) {
      // Event has ended
      if (mounted) {
        setState(() {
          eventEnded = true;
        });
        
        // Get final leaderboard
        if (quizSocket.socket != null && quizSocket.socket!.connected) {
          quizSocket.getLeaderboard(widget.quizId, widget.eventId);
        }
      }
      if (kDebugMode) {
        print('Event ended. Getting final leaderboard.');
      }
    });

    quizSocket.socket!.on('leaderboard-update', (data) {
      // Update leaderboard
      if (mounted) {
        setState(() {
          leaderboard = List<Map<String, dynamic>>.from(data['leaderboard']);
        });
      }
      if (kDebugMode) {
        print('Leaderboard updated with ${leaderboard.length} entries.');
      }
    });
    
    quizSocket.socket!.on('error', (data) {
      final errorMsg = data is String ? data : (data is Map ? data['message'] ?? 'Unknown error' : 'Unknown error');
      if (kDebugMode) {
        print('Socket error: $errorMsg');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Socket error: $errorMsg')),
        );
      }
    });
  }

  void submitAnswer(String answer) {
    if (answerSubmitted || currentQuestion == null) return;
    
    setState(() {
      userAnswer = answer;
      answerSubmitted = true;
    });
    
    if (quizSocket.socket != null && quizSocket.socket!.connected) {
      quizSocket.submitAnswer(
        widget.quizId,
        widget.eventId,
        questionIndex,
        answer
      );
      
      if (kDebugMode) {
        print('Answer submitted: $answer for question $questionIndex');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit answer: Not connected to server')),
      );
    }
  }

  void startQuestionTimer(int seconds) {
    setState(() {
      _remainingSeconds = seconds;
    });
    
    // Create a timer that decrements the remaining seconds
    Future.doWhile(() async {
      if (!mounted) return false;
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return false;
      
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
      
      // Continue until time runs out or answer submitted
      return _remainingSeconds > 0 && !answerSubmitted && !waitingForNextQuestion;
    }).then((_) {
      // Auto-submit if timer runs out and answer not yet submitted
      if (!answerSubmitted && !waitingForNextQuestion && mounted) {
        submitAnswer(''); // Submit empty answer
      }
    });
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
        title: const Text('Live Quiz Event'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showResults)
            Text('Question $questionIndex results. Waiting for next question...')
          else
            Text('Waiting for question ${questionIndex + 1}...'),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _initializeSocket(); // Retry connection if needed
            },
            child: const Text('Reconnect'),
          ),
        ],
      ),
    );
  }

  Widget buildQuestionUI() {
    if (currentQuestion == null) {
      return const Center(child: Text('Loading question...'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${questionIndex + 1}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_remainingSeconds',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Question text
          Text(currentQuestion!.text, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          // Answer input or display
          if (!answerSubmitted)
            Column(
              children: [
                TextField(
                  onSubmitted: (value) {
                    submitAnswer(value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Type your answer',
                    border: OutlineInputBorder(),
                    helperText: 'Press Enter to submit your answer',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Use a controller to get the text
                    final TextEditingController controller = TextEditingController();
                    submitAnswer(controller.text);
                  },
                  child: const Text('Submit Answer'),
                ),
              ],
            )
          else
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Answer Submitted',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Your answer: $userAnswer'),
                    const SizedBox(height: 8),
                    const Text('Waiting for results...'),
                  ],
                ),
              ),
            ),
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
          const Text(
            'Event Ended!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Final Leaderboard:', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          leaderboard.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading final results...'),
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = leaderboard[index];
                      return ListTile(
                        leading: Text('${index + 1}.'),
                        title: Text(entry['username'] ?? 'Unknown'),
                        trailing: Text('${entry['score'] ?? 0} points'),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
  
  Color _getTimerColor() {
    if (_remainingSeconds > 10) {
      return Colors.green;
    } else if (_remainingSeconds > 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
} 