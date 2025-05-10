import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import '../../models/lobby.dart';
import '../../widgets/common/theme_aware_widget.dart';
import 'game_screen.dart';
import '../../utils/theme/theme_cubit.dart';

class LobbyWaitingScreen extends StatefulWidget {
  final Lobby lobby;
  final VoidCallback toggleTheme;

  const LobbyWaitingScreen({
    Key? key, 
    required this.lobby, 
    required this.toggleTheme
  }) : super(key: key);

  @override
  State<LobbyWaitingScreen> createState() => _LobbyWaitingScreenState();
}

class _LobbyWaitingScreenState extends State<LobbyWaitingScreen> {
  Lobby? _currentLobby;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _currentLobby = widget.lobby;
  }

  @override
  void dispose() {
    // Leave the lobby when exiting screen
    if (_currentLobby != null) {
      context.read<GameBloc>().add(LeaveLobby(lobbyId: _currentLobby!.id));
    }
    super.dispose();
  }

  void _toggleTheme() {
    // Get the current ThemeCubit and its state
    final ThemeCubit cubit = context.read<ThemeCubit>();
    final currentState = cubit.state;
    
    // Toggle between light and dark modes
    if (currentState.mode == AppThemeMode.dark) {
      cubit.setTheme(AppThemeMode.light);
    } else {
      cubit.setTheme(AppThemeMode.dark);
    }
    
    // Call the original toggleTheme callback
    widget.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeAwareWidget(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Waiting Room'),
            automaticallyImplyLeading: false, // Disable back button
          ),
          body: BlocConsumer<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is LobbyUpdated) {
                setState(() {
                  _currentLobby = state.lobby;
                });
              } else if (state is LobbyLeft) {
                Navigator.pop(context);
              } else if (state is GameStarted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      gameId: state.gameId,
                      questions: state.questions,
                      players: state.players,
                      toggleTheme: _toggleTheme,
                    ),
                  ),
                );
              } else if (state is AllPlayersReady) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All players are ready! Game will start soon.')),
                );
              }
            },
            builder: (context, state) {
              if (state is GameLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildWaitingRoom();
            },
          ),
        );
      },
    );
  }

  Widget _buildWaitingRoom() {
    final lobby = _currentLobby ?? widget.lobby;
    final bool isHost = lobby.host == lobby.players.firstWhere(
      (player) => player['user'] == lobby.host, 
      orElse: () => {'user': ''}
    )['user'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting for Players',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          
          // Lobby info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lobby Name:'),
                      Text(lobby.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lobby Code:'),
                      SelectableText(lobby.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Players:'),
                      Text('${lobby.players.length}/${lobby.maxPlayers}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Text(
            'Players',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          
          // Player list
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: lobby.players.length,
                itemBuilder: (context, index) {
                  final player = lobby.players[index];
                  final bool playerIsHost = player['user'] == lobby.host;
                  final bool isReady = player['ready'] ?? false;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(player['name']?[0] ?? '?'),
                    ),
                    title: Text(
                      player['name'] ?? 'Unknown Player',
                      style: TextStyle(
                        fontWeight: playerIsHost ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: playerIsHost ? const Text('Host') : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReady ? Icons.check_circle : Icons.circle_outlined,
                          color: isReady ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(isReady ? 'Ready' : 'Not Ready'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Ready button
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isReady = !_isReady;
              });
              context.read<GameBloc>().add(SetPlayerReady(ready: _isReady));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isReady ? Colors.green : Colors.orange,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(_isReady ? 'Ready' : 'Not Ready'),
          ),
          
          const SizedBox(height: 12),
          
          // Start game button (host only)
          if (isHost)
            ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(StartGame(lobbyId: lobby.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Start Game'),
            ),
          
          const SizedBox(height: 12),
          
          // Leave lobby button
          ElevatedButton(
            onPressed: () {
              context.read<GameBloc>().add(LeaveLobby(lobbyId: lobby.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Leave Lobby'),
          ),
        ],
      ),
    );
  }
} 