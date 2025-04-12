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
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      category: json['category'],
      difficulty: json['difficulty'],
    );
  }
}