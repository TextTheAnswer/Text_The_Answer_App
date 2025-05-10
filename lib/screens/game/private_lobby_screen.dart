import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';

class PrivateLobbyScreen extends StatefulWidget {
  const PrivateLobbyScreen({super.key});

  @override
  State<PrivateLobbyScreen> createState() => _PrivateLobbyScreenState();
}

class _PrivateLobbyScreenState extends State<PrivateLobbyScreen> {
  // Controller for the name of lobby
  final TextEditingController _nameController = TextEditingController();

  // Max number of players
  final ValueNotifier<int> _maxPlayers = ValueNotifier(4);

  @override
  void dispose() {
    _nameController.dispose();
    _maxPlayers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 148, 72, 235),
      appBar: CustomAppBar(
        title: Text(
          'Create Private Lobby',
          style: FontUtility.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        showBackArrow: false,
        leadingIcon: Icons.close,
        onPressed: context.pop,
        shouldCenterTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            _createLobbyCard(),
            const SizedBox(height: 40),

            SizedBox(
              width: 220,
              child: Custom3DButton(
                backgroundColor: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                onPressed: () {},
                child: Text(
                  'Create Lobby',
                  style: FontUtility.montserrat(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createLobbyCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color.fromARGB(255, 42, 24, 77),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Lobby Name
          const Text(
            'Lobby Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // -- Lobby Name Text Field
          TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 3,
                  color: const Color.fromARGB(255, 89, 39, 229),
                ),
              ),
              hintText: 'Player123\'s Lobby',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
          ),
          const SizedBox(height: 12),

          // -- Max Players
          const Text(
            'Max Players',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // -- Max Player Selector
          DecoratedBox(
            position: DecorationPosition.background,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 12, 55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // -- Substract button
                CreateLobbyPlayerButton(
                  icon: IconsaxPlusLinear.minus,
                  onPressed: () {
                    if (_maxPlayers.value > 2) _maxPlayers.value--;
                  },
                ),

                // Current Max value
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Center(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _maxPlayers,
                        builder: (_, value, __) {
                          return Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // -- Add
                CreateLobbyPlayerButton(
                  icon: IconsaxPlusLinear.add,
                  onPressed: () {
                    if (_maxPlayers.value < 10) _maxPlayers.value++;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateLobbyPlayerButton extends StatelessWidget {
  const CreateLobbyPlayerButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 43, 24, 83),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 63, 35, 180),
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 30, color: Color.fromARGB(255, 103, 189, 255)),
        onPressed: onPressed,
      ),
    );
  }
}
