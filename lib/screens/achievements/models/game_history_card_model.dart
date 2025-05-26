class GameHistoryCardModel {
  final String title;
  final String score;
  final String date;
  final String duration;
  final String
  headerIcon; //TODO: Using text emoji for now, update to use unicode icon

  GameHistoryCardModel({
    required this.title,
    required this.score,
    required this.date,
    required this.duration,
    required this.headerIcon,
  });

  factory GameHistoryCardModel.fromMap(Map<String, dynamic> map) {
    return GameHistoryCardModel(
      title: map['title'] ?? '',
      headerIcon: map['header'] ?? '',
      score: map['score'] ?? '',
      date: map['date'] ?? '',
      duration: map['duration'] ?? '',
    );
  }
}

// Dummy test data
final List<GameHistoryCardModel> mockGameHistory = [
  GameHistoryCardModel(
    title: 'Daily Quiz #10',
    headerIcon: '☄️',
    score: '8/10',
    date: '26 May',
    duration: '2m 15s',
  ),
  GameHistoryCardModel(
    title: 'Science Challenge',
    headerIcon: '👏🏻',
    score: '6/10',
    date: '25 May',
    duration: '3m 02s',
  ),
  GameHistoryCardModel(
    title: 'History Quick Round',
    score: '10/10',
    headerIcon: '🏆',
    date: '24 May',
    duration: '1m 50s',
  ),
  GameHistoryCardModel(
    title: 'Math Drill #5',
    headerIcon: '🤯',
    score: '7/10',
    date: '22 May',
    duration: '2m 45s',
  ),
  GameHistoryCardModel(
    title: 'Trivia Mix Vol. 1',
    headerIcon: '🚀',
    score: '9/10',
    date: '20 May',
    duration: '3m 30s',
  ),
  GameHistoryCardModel(
    title: 'Daily Quiz #20',
    headerIcon: '👾',
    score: '2/10',
    date: '24 May',
    duration: '1m 30s',
  ),
];
