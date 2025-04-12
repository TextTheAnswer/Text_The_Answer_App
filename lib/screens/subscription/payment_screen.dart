import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_result_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String sessionUrl;
  final VoidCallback toggleTheme;

  const PaymentScreen({required this.sessionUrl, required this.toggleTheme, super.key});

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
                'Complete Payment 💳',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunch(sessionUrl)) {
                    await launch(sessionUrl);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentResultScreen(success: true),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentResultScreen(success: false),
                      ),
                    );
                  }
                },
                child: const Text('Pay with Stripe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}