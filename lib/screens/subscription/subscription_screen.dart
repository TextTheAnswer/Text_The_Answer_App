import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const SubscriptionScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionError) {
              print('SubscriptionScreen Error: ${state.message}'); // Debug statement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is CheckoutSessionCreated) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    sessionUrl: state.checkoutUrl,
                    toggleTheme: toggleTheme,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SubscriptionDetailsLoaded) {
              final subscription = state.subscription;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Details 🌟',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text('Status: ${subscription.status}'),
                    Text('Plan: ${subscription.planId ?? 'N/A'}'),
                    Text('Ends: ${subscription.currentPeriodEnd != null ? 
                        DateTime.fromMillisecondsSinceEpoch(subscription.currentPeriodEnd! * 1000).toString() : 'N/A'}'),
                    const SizedBox(height: 20),
                    if (subscription.status == 'active' && subscription.planId?.contains('premium') == true)
                      ElevatedButton(
                        onPressed: () {
                          context.read<SubscriptionBloc>().add(const CancelSubscription());
                        },
                        child: const Text('Cancel Subscription'),
                      ),
                  ],
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Go Premium 🌟',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  const Text('Unlock all features with a premium subscription!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(
                        const CreateCheckoutSession(priceId: 'price_premium_monthly')
                      );
                    },
                    child: const Text('Choose Plan'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(const FetchSubscriptionDetails());
                    },
                    child: const Text('View Subscription Details'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
