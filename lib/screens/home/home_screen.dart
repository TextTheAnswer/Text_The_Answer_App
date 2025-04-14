import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/screens/profile/profile_screen.dart';
import 'package:text_the_answer/widgets/custom_bottom_nav_bar.dart';
import '../daily_quiz_screen.dart';
import '../game/game_mode_screen.dart';
import '../leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import '../subscription/subscription_screen.dart';
import '../settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({required this.toggleTheme, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTabContent();
      case 1:
        return const Center(child: Text('Library'));
      case 2:
        return GameModeScreen(toggleTheme: widget.toggleTheme);
      case 3:
        return DailyQuizScreen(toggleTheme: widget.toggleTheme);
      case 4:
        return ProfileScreen(toggleTheme: widget.toggleTheme);
      default:
        return _buildHomeTabContent();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildHomeTabContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back! 👋',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          
          // Add your home content here
          
        ],
      ),
    );
  }
}