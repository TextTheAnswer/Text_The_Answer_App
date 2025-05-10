import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class PrivateLobbyScreen extends StatelessWidget {
  const PrivateLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Create Private Lobby'),
        showBackArrow: false,
        leadingIcon: Icons.close,
        onPressed: context.pop,
        shouldCenterTitle: true,
      ),
      body: Column(),
    );
  }
}
