import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import 'lobby_screen.dart';

class GameModeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const GameModeScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Modes 🎮',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<GameBloc>().add(FetchPublicLobbies());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        isPublic: true,
                        toggleTheme: toggleTheme,
                      ),
                    ),
                  );
                },
                child: const Text('Join Public Game'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<GameBloc>().add(
                        CreateLobby(
                          name: 'Private Room',
                          isPublic: false,
                          maxPlayers: 5,
                        ),
                      );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        isPublic: false,
                        toggleTheme: toggleTheme,
                      ),
                    ),
                  );
                },
                child: const Text('Create Private Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}