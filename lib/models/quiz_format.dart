class QuizFormat {
  final int duration; // Total quiz duration in minutes
  final int questionTimeLimit; // Time limit per question in seconds
  final bool premiumAward; // Whether this quiz awards premium to winner
  
  QuizFormat({
    this.duration = 10,
    this.questionTimeLimit = 15,
    this.premiumAward = true,
  });
  
  factory QuizFormat.fromJson(Map<String, dynamic> json) {
    return QuizFormat(
      duration: json['duration'] ?? 10,
      questionTimeLimit: json['questionTimeLimit'] ?? 15,
      premiumAward: json['premiumAward'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'questionTimeLimit': questionTimeLimit,
      'premiumAward': premiumAward,
    };
  }
  
  Duration getTotalDuration() {
    return Duration(minutes: duration);
  }
  
  Duration getQuestionDuration() {
    return Duration(seconds: questionTimeLimit);
  }
} 