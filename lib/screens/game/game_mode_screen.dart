import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../blocs/game/game_event.dart';
import '../../blocs/game/game_state.dart';
import 'lobby_screen.dart';

class GameModeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const GameModeScreen({required this.toggleTheme, super.key});

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize sockets when entering the game section
    context.read<GameBloc>().add(InitializeSockets());
  }
  
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
              const SizedBox(height: 40),
              
              // Public game option
              _buildGameModeCard(
                title: 'Public Game',
                description: 'Play with others in public lobbies',
                icon: Icons.public,
                color: Colors.blue,
                onTap: () {
                  // Fetch public lobbies first
                  context.read<GameBloc>().add(FetchPublicLobbies());
                  
                  // Then navigate to the lobby screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        isPublic: true,
                        toggleTheme: widget.toggleTheme,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Private game option
              _buildGameModeCard(
                title: 'Private Game',
                description: 'Create a private game for friends',
                icon: Icons.lock,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        isPublic: false,
                        toggleTheme: widget.toggleTheme,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              const Divider(),
              
              const SizedBox(height: 20),
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                '1. Join a public lobby or create your own private game\n'
                '2. Wait for all players to join and mark themselves as ready\n'
                '3. The game host will start the match when everyone is ready\n'
                '4. Answer questions as quickly as possible to earn points!\n'
                '5. The player with the most points at the end wins',
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameModeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}