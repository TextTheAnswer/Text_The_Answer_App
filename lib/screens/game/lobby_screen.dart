import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final bool isPublic;
  final VoidCallback toggleTheme;

  const LobbyScreen({required this.isPublic, required this.toggleTheme, super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<GameBloc, GameState>(
          listener: (context, state) {
            if (state is GameError) {
              print('LobbyScreen Error: ${state.message}'); // Debug statement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is LobbyJoined || state is LobbyCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joined lobby successfully')),
              );
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
                    toggleTheme: widget.toggleTheme,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.isPublic) {
              if (state is PublicLobbiesLoaded) {
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
                          context.read<GameBloc>().add(
                                JoinLobby(code: _codeController.text),
                              );
                        },
                        child: const Text('Join Lobby'),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.lobbies.length,
                          itemBuilder: (context, index) {
                            final lobby = state.lobbies[index];
                            return ListTile(
                              title: Text(lobby['name']),
                              subtitle: Text(
                                  'Players: ${lobby['playerCount']}/${lobby['maxPlayers']}'),
                              trailing: lobby['isFull']
                                  ? const Text('Full')
                                  : ElevatedButton(
                                      onPressed: () {
                                        context.read<GameBloc>().add(
                                              JoinLobby(code: lobby['code']),
                                            );
                                      },
                                      child: const Text('Join'),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            }

            if (state is LobbyCreated || state is LobbyJoined) {
              final lobby = (state is LobbyCreated)
                  ? state.lobby
                  : (state as LobbyJoined).lobby;
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
                    Text('Lobby Code: ${lobby.code}'),
                    const SizedBox(height: 20),
                    Text('Players: ${lobby.players.length}/${lobby.maxPlayers}'),
                    const SizedBox(height: 20),
                    if (lobby.host == lobby.players.first['user'])
                      ElevatedButton(
                        onPressed: () {
                          context.read<GameBloc>().add(StartGame(lobbyId: lobby.id));
                        },
                        child: const Text('Start Game'),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameBloc>().add(LeaveLobby(lobbyId: lobby.id));
                      },
                      child: const Text('Leave Lobby'),
                    ),
                  ],
                ),
              );
            }

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
                  if (widget.isPublic)
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Lobby Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (widget.isPublic)
                    ElevatedButton(
                      onPressed: () {
                        context.read<GameBloc>().add(
                              JoinLobby(code: _codeController.text),
                            );
                      },
                      child: const Text('Join Lobby'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}