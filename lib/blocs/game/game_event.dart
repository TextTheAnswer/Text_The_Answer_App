abstract class GameEvent {}

class InitializeSockets extends GameEvent {}

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

class SetPlayerReady extends GameEvent {
  final bool ready;

  SetPlayerReady({required this.ready});
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

// Socket-related events
class UpdateLobbyData extends GameEvent {
  final dynamic lobby;

  UpdateLobbyData({required this.lobby});
}

class PlayerJoinedEvent extends GameEvent {
  final Map<String, dynamic> playerData;

  PlayerJoinedEvent({required this.playerData});
}

class PlayerLeftEvent extends GameEvent {
  final Map<String, dynamic> playerData;

  PlayerLeftEvent({required this.playerData});
}

class PlayerReadyChangedEvent extends GameEvent {
  final Map<String, dynamic> playerData;

  PlayerReadyChangedEvent({required this.playerData});
}

class AllPlayersReadyEvent extends GameEvent {}

class SocketErrorEvent extends GameEvent {
  final String message;

  SocketErrorEvent({required this.message});
}