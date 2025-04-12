import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;

  const PaymentResultScreen({required this.success, super.key});

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
                success ? 'Congrats! 🎉' : 'Payment Failed 😔',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Text(success
                  ? 'Welcome to Premium!'
                  : 'Please try again with a different payment method.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}