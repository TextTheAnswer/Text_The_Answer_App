import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../models/lobby.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  // Stream subscriptions to handle socket events
  StreamSubscription? _lobbyDataSubscription;
  StreamSubscription? _playerJoinedSubscription;
  StreamSubscription? _playerLeftSubscription;
  StreamSubscription? _playerReadyChangedSubscription;
  StreamSubscription? _allPlayersReadySubscription;
  StreamSubscription? _socketErrorSubscription;
  
  // Current lobby state
  Lobby? _currentLobby;

  GameBloc() : super(GameInitial()) {
    // Initialize socket connections and subscriptions
    _initSocketSubscriptions();
    
    on<InitializeSockets>((event, emit) async {
      await _socketService.init();
    });
    
    on<CreateLobby>((event, emit) async {
      emit(GameLoading());
      try {
        // First initialize the socket connection
        await _socketService.init();
        
        // Then create the lobby through API
        final lobby = await _apiService.createGameLobby(
            event.name, event.isPublic, event.maxPlayers);
        
        // Store current lobby
        _currentLobby = lobby;
        
        // Join the lobby's socket room
        _socketService.joinGameLobby(lobby.id);
        
        emit(LobbyCreated(lobby: lobby));
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (CreateLobby): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });

    on<FetchPublicLobbies>((event, emit) async {
      emit(GameLoading());
      try {
        // Initialize socket connection if needed
        await _socketService.init();
        
        final lobbies = await _apiService.getPublicLobbies();
        emit(PublicLobbiesLoaded(lobbies: lobbies));
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (FetchPublicLobbies): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });

    on<JoinLobby>((event, emit) async {
      emit(GameLoading());
      try {
        // Initialize socket connection
        await _socketService.init();
        
        // Join the lobby through the API
        final lobby = await _apiService.joinLobbyByCode(event.code);
        
        if (lobby == null) {
          throw Exception('Failed to join lobby: Received null lobby object');
        }
        
        // Store current lobby
        _currentLobby = lobby;
        
        // Debug log
        print('Joined lobby with ID: ${lobby.id} (${lobby.id.runtimeType})');
        
        // Join the lobby's socket room - joinGameLobby now handles type conversion
        _socketService.joinGameLobby(lobby.id);
        
        emit(LobbyJoined(lobby: lobby));
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (JoinLobby): $e');
        }
        emit(GameError(message: 'Failed to join lobby: ${e.toString()}'));
      }
    });

    on<LeaveLobby>((event, emit) async {
      emit(GameLoading());
      try {
        // Leave the lobby through API
        await _apiService.leaveLobby(event.lobbyId);
        
        // Leave the socket room
        _socketService.leaveGameLobby(event.lobbyId);
        
        // Clear current lobby
        _currentLobby = null;
        
        emit(LobbyLeft());
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (LeaveLobby): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });
    
    on<SetPlayerReady>((event, emit) async {
      try {
        if (_currentLobby != null) {
          _socketService.setReady(_currentLobby!.id, event.ready);
          // State will be updated through socket events
        }
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (SetPlayerReady): $e');
        }
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
        if (kDebugMode) {
          print('GameBloc Error (StartGame): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });

    on<SubmitGameAnswer>((event, emit) async {
      emit(GameLoading());
      try {
        final result = await _apiService.submitGameAnswer(
            event.gameId, event.questionIndex.toString(), event.answer);
        emit(GameAnswerSubmitted(
          isCorrect: result['isCorrect'],
          correctAnswer: result['correctAnswer'],
          score: result['score'],
          totalScore: result['totalScore'],
          allAnswered: result['allAnswered'],
        ));
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (SubmitGameAnswer): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });

    on<FetchGameResults>((event, emit) async {
      emit(GameLoading());
      try {
        final results = await _apiService.getGameResults(event.gameId);
        emit(GameResultsLoaded(results: results));
      } catch (e) {
        if (kDebugMode) {
          print('GameBloc Error (FetchGameResults): $e');
        }
        emit(GameError(message: e.toString()));
      }
    });
    
    // Handle socket events
    on<UpdateLobbyData>((event, emit) {
      _currentLobby = event.lobby;
      emit(LobbyUpdated(lobby: event.lobby));
    });
    
    on<PlayerJoinedEvent>((event, emit) {
      // We'll rely on the lobby-data event to update the full state
      if (kDebugMode) {
        print('Player joined: ${event.playerData}');
      }
    });
    
    on<PlayerLeftEvent>((event, emit) {
      // We'll rely on the lobby-data event to update the full state
      if (kDebugMode) {
        print('Player left: ${event.playerData}');
      }
    });
    
    on<PlayerReadyChangedEvent>((event, emit) {
      // We'll rely on the lobby-data event to update the full state
      if (kDebugMode) {
        print('Player ready changed: ${event.playerData}');
      }
    });
    
    on<AllPlayersReadyEvent>((event, emit) {
      emit(AllPlayersReady());
    });
  }
  
  void _initSocketSubscriptions() {
    // Listen for lobby data updates
    _lobbyDataSubscription = _socketService.onLobbyData.listen((lobby) {
      add(UpdateLobbyData(lobby: lobby));
    });
    
    // Listen for player joined events
    _playerJoinedSubscription = _socketService.onPlayerJoined.listen((data) {
      add(PlayerJoinedEvent(playerData: data));
    });
    
    // Listen for player left events
    _playerLeftSubscription = _socketService.onPlayerLeft.listen((data) {
      add(PlayerLeftEvent(playerData: data));
    });
    
    // Listen for player ready changed events
    _playerReadyChangedSubscription = _socketService.onPlayerReadyChanged.listen((data) {
      add(PlayerReadyChangedEvent(playerData: data));
    });
    
    // Listen for all players ready event
    _allPlayersReadySubscription = _socketService.onAllPlayersReady.listen((_) {
      add(AllPlayersReadyEvent());
    });
    
    // Listen for socket errors
    _socketErrorSubscription = _socketService.onError.listen((errorMsg) {
      add(SocketErrorEvent(message: errorMsg));
    });
  }
  
  @override
  Future<void> close() {
    // Clean up all subscriptions
    _lobbyDataSubscription?.cancel();
    _playerJoinedSubscription?.cancel();
    _playerLeftSubscription?.cancel();
    _playerReadyChangedSubscription?.cancel();
    _allPlayersReadySubscription?.cancel();
    _socketErrorSubscription?.cancel();
    
    return super.close();
  }
}