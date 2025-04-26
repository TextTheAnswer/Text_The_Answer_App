import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../config/colors.dart';
import '../../router/routes.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const SubscriptionScreen({required this.toggleTheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: AppColors.primary,
      ),
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
                      'Subscription Details',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      context,
                      title: 'Current Plan',
                      content: subscription.planId?.toUpperCase() ?? 'FREE',
                      icon: Icons.card_membership,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      context,
                      title: 'Status',
                      content: _formatStatus(subscription.status),
                      icon: Icons.info_outline,
                    ),
                    if (subscription.currentPeriodEnd != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: 'Renewal Date',
                        content: DateTime.fromMillisecondsSinceEpoch(
                          subscription.currentPeriodEnd! * 1000,
                        ).toString().split(' ')[0],
                        icon: Icons.calendar_today,
                      ),
                    ],
                    const SizedBox(height: 30),
                    if (subscription.status == 'active')
                      ElevatedButton(
                        onPressed: () {
                          context.read<SubscriptionBloc>().add(const CancelSubscription());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Cancel Subscription'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.subscriptionPlans);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Subscribe Now'),
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
                    'Go Premium',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 30),
                  
                  // Premium benefits
                  ...['Unlimited quizzes', 'Create private lobbies', 'Custom study materials', 'Advanced analytics']
                      .map((benefit) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                                const SizedBox(width: 12),
                                Text(benefit, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ))
                      .toList(),
                  
                  const SizedBox(height: 40),
                  
                  // Subscription options button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.subscriptionPlans);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('View Subscription Plans', style: TextStyle(fontSize: 16)),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Check subscription status button  
                  OutlinedButton(
                    onPressed: () {
                      context.read<SubscriptionBloc>().add(const FetchSubscriptionDetails());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Check Subscription Status'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  String _formatStatus(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'canceled':
        return 'Canceled';
      case 'past_due':
        return 'Past Due';
      case 'unpaid':
        return 'Unpaid';
      default:
        return 'Inactive';
    }
  }
  
  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String content, 
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              Text(
                content,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
