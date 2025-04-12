import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  GameBloc() : super(GameInitial()) {
    on<CreateLobby>((event, emit) async {
      emit(GameLoading());
      try {
        final lobby = await _apiService.createLobby(
            event.name, event.isPublic, event.maxPlayers);
        _socketService.joinGameLobby(lobby.id);
        emit(LobbyCreated(lobby: lobby));
      } catch (e) {
        print('GameBloc Error (CreateLobby): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<FetchPublicLobbies>((event, emit) async {
      emit(GameLoading());
      try {
        final lobbies = await _apiService.getPublicLobbies();
        emit(PublicLobbiesLoaded(lobbies: lobbies));
      } catch (e) {
        print('GameBloc Error (FetchPublicLobbies): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<JoinLobby>((event, emit) async {
      emit(GameLoading());
      try {
        final lobby = await _apiService.joinLobby(event.code);
        _socketService.joinGameLobby(lobby.id);
        emit(LobbyJoined(lobby: lobby));
      } catch (e) {
        print('GameBloc Error (JoinLobby): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<LeaveLobby>((event, emit) async {
      emit(GameLoading());
      try {
        await _apiService.leaveLobby(event.lobbyId);
        _socketService.leaveGameLobby(event.lobbyId);
        emit(LobbyLeft());
      } catch (e) {
        print('GameBloc Error (LeaveLobby): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<StartGame>((event, emit) async {
      emit(GameLoading());
      try {
        final game = await _apiService.startGame(event.lobbyId);
        _socketService.joinGame(game['game']['id']);
        emit(GameStarted(
          gameId: game['game']['id'],
          questions: game['game']['questions'],
          players: game['game']['players'],
        ));
      } catch (e) {
        print('GameBloc Error (StartGame): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<SubmitGameAnswer>((event, emit) async {
      emit(GameLoading());
      try {
        final result = await _apiService.submitGameAnswer(
            event.gameId, event.questionIndex, event.answer);
        emit(GameAnswerSubmitted(
          isCorrect: result['isCorrect'],
          correctAnswer: result['correctAnswer'],
          score: result['score'],
          totalScore: result['totalScore'],
          allAnswered: result['allAnswered'],
        ));
      } catch (e) {
        print('GameBloc Error (SubmitGameAnswer): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });

    on<FetchGameResults>((event, emit) async {
      emit(GameLoading());
      try {
        final results = await _apiService.getGameResults(event.gameId);
        emit(GameResultsLoaded(results: results));
      } catch (e) {
        print('GameBloc Error (FetchGameResults): $e'); // Debug statement
        emit(GameError(message: e.toString()));
      }
    });
  }
}