import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/game/game_bloc.dart';
import 'package:text_the_answer/blocs/game/game_event.dart';
import 'package:text_the_answer/models/lobby.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

//TODO: Do a complete port of [LobbyWaitingScreen]
class WaitingLobbyScreen extends StatefulWidget {
  const WaitingLobbyScreen({super.key, required this.lobby});

  final Lobby lobby;

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  late Lobby _currentLobby;

  @override
  void initState() {
    super.initState();
    _currentLobby = widget.lobby;
  }

  @override
  void dispose() {
    // Leave the lobby when exiting screen
    context.read<GameBloc>().add(LeaveLobby(lobbyId: _currentLobby.id));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: CustomAppBar(
        title: Text('Waiting for Players..'),
        showBackArrow: false,
        leadingIcon: Icons.close,
        onPressed: context.pop,
        shouldCenterTitle: true,
      ),
      body: Column(
        children: [
          // -- Lobby Card
          LobbyCard(lobby: _currentLobby),
          const SizedBox(height: 30),

          // -- Players
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _currentLobby.players.map((player) {
                  return PlayerChip();
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class PlayerChip extends StatelessWidget {
  const PlayerChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(width: 8),
          Text('Andrew', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class LobbyCard extends StatelessWidget {
  const LobbyCard({super.key, required this.lobby});

  final Lobby lobby;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            //TODO: Replace with image
            child: Container(height: 200, color: Colors.deepPurpleAccent),
          ),
          SizedBox(height: 12),

          // -- Lobby Title
          Text(
            lobby.name,
            style: FontUtility.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Divider(),

          // -- Player number
          Text(
            '${lobby.players.length} players have joined',
            style: FontUtility.montserrat(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
