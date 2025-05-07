import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ApiService _apiService;
  final SocketService _socketService = SocketService();

  LeaderboardBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(LeaderboardInitial()) {
    on<FetchDailyLeaderboard>((event, emit) async {
      emit(LeaderboardLoading());
      try {
        print('LeaderboardBloc: Fetching daily leaderboard...');
        final leaderboardData = await _apiService.getDailyQuizLeaderboard();
        
        emit(LeaderboardLoaded(
          leaderboard: List<Map<String, dynamic>>.from(leaderboardData['leaderboard']),
          userRank: leaderboardData['userRank'],
          userScore: leaderboardData['userScore'],
          theme: Map<String, dynamic>.from(leaderboardData['theme'] ?? {}),
          winner: leaderboardData['winner'] != null 
              ? Map<String, dynamic>.from(leaderboardData['winner']) 
              : null,
        ));
      } catch (e) {
        print('LeaderboardBloc Error: $e');
        emit(LeaderboardError(message: 'Failed to load leaderboard: ${e.toString()}'));
      }
    });
    
    // Method to fetch the leaderboard periodically during events
    on<RefreshLeaderboard>((event, emit) async {
      // Don't show loading state for refreshes to prevent UI flicker
      try {
        if (state is LeaderboardLoaded) {
          print('LeaderboardBloc: Refreshing leaderboard...');
          final leaderboardData = await _apiService.getDailyQuizLeaderboard();
          
          emit((state as LeaderboardLoaded).copyWith(
            leaderboard: List<Map<String, dynamic>>.from(leaderboardData['leaderboard']),
            userRank: leaderboardData['userRank'],
            userScore: leaderboardData['userScore'],
            theme: Map<String, dynamic>.from(leaderboardData['theme'] ?? {}),
            winner: leaderboardData['winner'] != null 
                ? Map<String, dynamic>.from(leaderboardData['winner']) 
                : null,
            lastUpdated: DateTime.now(),
          ));
        } else {
          // If not already loaded, treat like a fresh fetch
          add(FetchDailyLeaderboard());
        }
      } catch (e) {
        print('LeaderboardBloc Error during refresh: $e');
        // Don't emit error on refresh to prevent UI disruption
        // Just keep the current state
      }
    });

    on<FetchGameLeaderboard>((event, emit) async {
      emit(LeaderboardLoading());
      try {
        final response = await _apiService.getGameLeaderboard(event.gameId);
        _socketService.subscribeToGameLeaderboard(event.gameId);
        
        // Convert the response to the correct types
        final leaderboardEntries = List<Map<String, dynamic>>.from(
          (response['leaderboard'] as List).map((entry) => Map<String, dynamic>.from(entry))
        );
        
        // Ensure userRank is an int
        int userRank = 0;
        int userScore = 0;
        if (response['userRank'] != null) {
          userRank = int.tryParse(response['userRank'].toString()) ?? 0;
        }
        if (response['userScore'] != null) {
          userScore = int.tryParse(response['userScore'].toString()) ?? 0;
        }
        
        emit(LeaderboardLoaded(
          leaderboard: leaderboardEntries,
          userRank: userRank,
          userScore: userScore,
          theme: {'name': 'Game Leaderboard', 'description': 'Current game standings'},
          lastUpdated: DateTime.now(),
        ));
      } catch (e) {
        print('LeaderboardBloc Error (FetchGameLeaderboard): $e');
        emit(LeaderboardError(message: e.toString()));
      }
    });
  }
}
