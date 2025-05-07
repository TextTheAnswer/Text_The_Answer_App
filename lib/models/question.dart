class Question {
  final String id;
  final String text;
  final List<String> options;
  final List<String> acceptedAnswers;
  final String category;
  final String difficulty;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.acceptedAnswers,
    required this.category,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Get ID with MongoDB ObjectId validation in mind
    String questionId = json['_id'] ?? json['id'] ?? '';
    
    // Log the ID for debugging
    print('Question.fromJson: Extracted ID: $questionId from JSON keys: ${json.keys.join(", ")}');
    
    return Question(
      id: questionId,
      text: json['text'] ?? 'No question text available',
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : ['No options available'],
      acceptedAnswers: json['acceptedAnswers'] != null
          ? List<String>.from(json['acceptedAnswers'])
          : json['options'] != null 
              ? List<String>.from(json['options']) 
              : ['No accepted answers available'],
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'acceptedAnswers': acceptedAnswers,
      'category': category,
      'difficulty': difficulty,
    };
  }
  
  // Helper method to prepare an answer submission entry
  Map<String, dynamic> prepareAnswerSubmission(String userAnswer, double timeSpent) {
    // Don't submit if ID is empty or invalid
    if (id.isEmpty) {
      return {};
    }
    
    return {
      'questionId': id,
      'answer': userAnswer,
      'timeSpent': timeSpent,
    };
  }
  
  // Check if this question has a valid MongoDB ObjectId
  bool hasValidId() {
    if (id.isEmpty || id == 'unknown' || id == 'unknown_id') {
      return false;
    }
    
    // Check if it's exactly 24 characters long and contains only hex characters
    return id.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
  }
}