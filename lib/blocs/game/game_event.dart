abstract class GameEvent {}

class CreateLobby extends GameEvent {
  final String name;
  final bool isPublic;
  final int maxPlayers;

  CreateLobby({required this.name, required this.isPublic, required this.maxPlayers});
}

class FetchPublicLobbies extends GameEvent {}

class JoinLobby extends GameEvent {
  final String code;

  JoinLobby({required this.code});
}

class LeaveLobby extends GameEvent {
  final String lobbyId;

  LeaveLobby({required this.lobbyId});
}

class StartGame extends GameEvent {
  final String lobbyId;

  StartGame({required this.lobbyId});
}

class SubmitGameAnswer extends GameEvent {
  final String gameId;
  final int questionIndex;
  final String answer;

  SubmitGameAnswer({
    required this.gameId,
    required this.questionIndex,
    required this.answer,
  });
}

class FetchGameResults extends GameEvent {
  final String gameId;

  FetchGameResults({required this.gameId});
}