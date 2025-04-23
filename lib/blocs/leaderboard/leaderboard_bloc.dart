import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/leaderboard.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<FetchDailyLeaderboard>((event, emit) async {
      emit(LeaderboardLoading());
      try {
        final response = await _apiService.getDailyLeaderboard();
        _socketService.subscribeToDailyLeaderboard();
        
        // Convert the response to the correct types
        final leaderboardData = response['leaderboard'] as List;
        final List<LeaderboardEntry> leaderboardEntries = leaderboardData
            .map((entry) => LeaderboardEntry.fromJson(entry as Map<String, dynamic>))
            .toList();
        
        // Ensure userRank is an int
        int userRank = 0;
        if (response['userRank'] != null) {
          userRank = int.tryParse(response['userRank'].toString()) ?? 0;
        }
        
        emit(LeaderboardLoaded(
          leaderboard: leaderboardEntries,
          userRank: userRank,
        ));
      } catch (e) {
        print('LeaderboardBloc Error (FetchDailyLeaderboard): $e'); // Debug statement
        emit(LeaderboardError(message: e.toString()));
      }
    });

    on<FetchGameLeaderboard>((event, emit) async {
      emit(LeaderboardLoading());
      try {
        final response = await _apiService.getGameLeaderboard(event.gameId);
        _socketService.subscribeToGameLeaderboard(event.gameId);
        
        // Convert the response to the correct types
        final leaderboardData = response['leaderboard'] as List;
        final List<LeaderboardEntry> leaderboardEntries = leaderboardData
            .map((entry) => LeaderboardEntry.fromJson(entry as Map<String, dynamic>))
            .toList();
        
        // Ensure userRank is an int
        int userRank = 0;
        if (response['userRank'] != null) {
          userRank = int.tryParse(response['userRank'].toString()) ?? 0;
        }
        
        emit(LeaderboardLoaded(
          leaderboard: leaderboardEntries,
          userRank: userRank,
        ));
      } catch (e) {
        print('LeaderboardBloc Error (FetchGameLeaderboard): $e'); // Debug statement
        emit(LeaderboardError(message: e.toString()));
      }
    });
  }
}
