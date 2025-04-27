import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key, required this.navigationShell});

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          // -- Home
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            activeIcon: Icon(IconlyBold.home),
            label: 'Home',
          ),

          // -- Library
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.category),
            activeIcon: Icon(IconlyBold.category),
            label: 'Library',
          ),

          // -- Game Mode
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.category),
            activeIcon: Icon(IconlyBold.category),
            label: 'GameMode',
          ),

          // -- Quiz
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.plus),
            activeIcon: Icon(IconlyBold.plus),
            label: 'Quiz',
          ),

          // -- Quiz
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.profile),
            activeIcon: Icon(IconlyBold.profile),
            label: 'Profile',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  /// Function to navigate to the right screen
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
