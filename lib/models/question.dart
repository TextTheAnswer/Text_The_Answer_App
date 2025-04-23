class Question {
  final String id;
  final String text;
  final List<String> options;
  final String category;
  final String difficulty;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.category,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 'unknown_id',
      text: json['text'] ?? 'No question text available',
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : ['No options available'],
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
}