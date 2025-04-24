import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import '../../models/lobby.dart';
import 'game_screen.dart';
import 'lobby_waiting_screen.dart';

class LobbyScreen extends StatefulWidget {
  final bool isPublic;
  final VoidCallback toggleTheme;

  const LobbyScreen({required this.isPublic, required this.toggleTheme, super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController(text: 'My Game Lobby');
  final _maxPlayersController = TextEditingController(text: '4');
  Lobby? _currentLobby;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize socket connection when entering screen
    context.read<GameBloc>().add(InitializeSockets());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _maxPlayersController.dispose();
    
    // Leave the lobby when exiting screen if in one
    if (_currentLobby != null) {
      context.read<GameBloc>().add(LeaveLobby(lobbyId: _currentLobby!.id));
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPublic ? 'Public Game Lobbies' : 'Private Game'),
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is LobbyJoined) {
            setState(() {
              _currentLobby = state.lobby;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Joined lobby successfully')),
            );
            // Navigate to the waiting screen after joining
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LobbyWaitingScreen(
                  lobby: state.lobby,
                  toggleTheme: widget.toggleTheme,
                ),
              ),
            );
          } else if (state is LobbyCreated) {
            setState(() {
              _currentLobby = state.lobby;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Created lobby successfully')),
            );
            // Navigate to the waiting screen after creating
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LobbyWaitingScreen(
                  lobby: state.lobby,
                  toggleTheme: widget.toggleTheme,
                ),
              ),
            );
          } else if (state is LobbyUpdated) {
            setState(() {
              _currentLobby = state.lobby;
            });
          } else if (state is LobbyLeft) {
            setState(() {
              _currentLobby = null;
              _isReady = false;
            });
            Navigator.pop(context);
          } else if (state is GameStarted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  gameId: state.gameId,
                  questions: state.questions,
                  players: state.players,
                  toggleTheme: widget.toggleTheme,
                ),
              ),
            );
          } else if (state is AllPlayersReady) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All players are ready!')),
            );
          }
        },
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // If user is in a lobby, show the lobby screen
          if (_currentLobby != null) {
            return _buildLobbyView(_currentLobby!);
          }

          // If user is viewing public lobbies
          if (widget.isPublic && state is PublicLobbiesLoaded) {
            return _buildPublicLobbiesView(state.lobbies);
          }

          // Default view for entering a code or creating a lobby
          return _buildLobbyEntryView();
        },
      ),
    );
  }
  
  Widget _buildLobbyView(Lobby lobby) {
    final bool isHost = lobby.host == lobby.players.first['user'];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isPublic ? 'Public Lobby 🌐' : 'Private Lobby 🔒',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          
          // Lobby info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
  
  Widget _buildPublicLobbiesView(List<Map<String, dynamic>> lobbies) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Public Lobbies 🌐',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          
          // Join by code
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Enter Lobby Code',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.login),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_codeController.text.isNotEmpty) {
                context.read<GameBloc>().add(JoinLobby(code: _codeController.text));
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Join by Code'),
          ),
          
          const SizedBox(height: 20),
          
          // Create new lobby
          ElevatedButton(
            onPressed: () {
              _showCreateLobbyDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Create New Lobby'),
          ),
          
          const SizedBox(height: 20),
          const Text('Available Lobbies:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Lobby list
          Expanded(
            child: lobbies.isEmpty 
                ? const Center(child: Text('No lobbies available')) 
                : ListView.builder(
                    itemCount: lobbies.length,
                    itemBuilder: (context, index) {
                      final lobby = lobbies[index];
                      final bool isFull = (lobby['playerCount'] ?? 0) >= (lobby['maxPlayers'] ?? 4);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(lobby['name'] ?? 'Game Lobby'),
                          subtitle: Text('Players: ${lobby['playerCount'] ?? 0}/${lobby['maxPlayers'] ?? 4}'),
                          trailing: isFull 
                              ? const Chip(label: Text('Full'))
                              : ElevatedButton(
                                  onPressed: () {
                                    context.read<GameBloc>().add(JoinLobby(code: lobby['code']));
                                  },
                                  child: const Text('Join'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Refresh button
          ElevatedButton.icon(
            onPressed: () {
              context.read<GameBloc>().add(FetchPublicLobbies());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLobbyEntryView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isPublic ? 'Join Game Lobby' : 'Create Private Game',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          
          if (widget.isPublic) ...[
            // Join by code
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter Lobby Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_codeController.text.isNotEmpty) {
                  context.read<GameBloc>().add(JoinLobby(code: _codeController.text));
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Join Lobby'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(FetchPublicLobbies());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Browse Public Lobbies'),
            ),
          ] else ...[
            // Create private lobby form will be shown via dialog
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showCreateLobbyDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Create Private Lobby'),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showCreateLobbyDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'My Game Lobby');
    final maxPlayersController = TextEditingController(text: '4');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Lobby'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Lobby Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxPlayersController,
              decoration: const InputDecoration(
                labelText: 'Max Players (2-8)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final name = nameController.text.isEmpty ? 'My Game Lobby' : nameController.text;
              final maxPlayers = int.tryParse(maxPlayersController.text) ?? 4;
              
              context.read<GameBloc>().add(
                CreateLobby(
                  name: name,
                  isPublic: widget.isPublic,
                  maxPlayers: maxPlayers.clamp(2, 8),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}