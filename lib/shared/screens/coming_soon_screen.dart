import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coming Soon')),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Text(
            'We are working on this,'
            ''' so please be rest assured that... '''
            '''This feature is coming soon''',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
