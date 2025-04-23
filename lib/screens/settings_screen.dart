import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../router/routes.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const SettingsScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              
              // Settings List
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Account'),
                onTap: () {
                  // Navigate to account settings
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Subscription'),
                subtitle: const Text('Manage your premium subscription'),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.manageSubscription);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    toggleTheme();
                  },
                ),
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  // Navigate to about screen
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  // Navigate to help screen
                },
              ),
              
              const Spacer(),
              
              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}