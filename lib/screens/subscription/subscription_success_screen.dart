import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../config/colors.dart';
import '../../models/subscription.dart';
import '../../router/routes.dart';

class SubscriptionSuccessScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const SubscriptionSuccessScreen({
    Key? key,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<SubscriptionSuccessScreen> createState() => _SubscriptionSuccessScreenState();
}

class _SubscriptionSuccessScreenState extends State<SubscriptionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subscription details when the screen loads
    context.read<SubscriptionBloc>().add(const FetchSubscriptionDetails());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionDetailsLoaded) {
            return _buildSuccessContent(context, state.subscription);
          }
          
          // Fallback UI while waiting
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Verifying your subscription...'),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSuccessContent(BuildContext context, Subscription subscription) {
    return Stack(
      children: [
        // Background with gradient and confetti pattern
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
        
        // Content
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Success icon
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 60,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Success message
                        const Text(
                          'Subscription Successful!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Thank you for subscribing to ${_getPlanName(subscription.planId)}.',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Subscription details card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Subscription Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildDetailRow(
                                'Plan', 
                                _getPlanName(subscription.planId),
                                Icons.card_membership,
                              ),
                              
                              const SizedBox(height: 12),
                              
                              _buildDetailRow(
                                'Status',
                                subscription.status.toUpperCase(),
                                Icons.verified,
                                valueColor: Colors.green,
                              ),
                              
                              const SizedBox(height: 12),
                              
                              if (subscription.currentPeriodEnd != null)
                                _buildDetailRow(
                                  'Next Billing Date',
                                  _formatDate(subscription.currentPeriodEnd!),
                                  Icons.calendar_today,
                                ),
                              
                              const SizedBox(height: 12),
                              
                              _buildDetailRow(
                                'Billing Cycle',
                                subscription.interval?.toUpperCase() ?? 'N/A',
                                Icons.schedule,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // What's included section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'What\'s Included',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              ..._getPlanFeatures(subscription.planId).map(
                                (feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.home,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Using Premium Features',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.manageSubscription);
                      },
                      child: const Text(
                        'Manage Subscription',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getPlanName(String? planId) {
    if (planId == null) return 'Free Plan';
    
    switch (planId) {
      case 'premium_monthly':
        return 'Premium Monthly';
      case 'premium_yearly':
        return 'Premium Yearly';
      case 'student_monthly':
        return 'Student Monthly';
      case 'student_yearly':
        return 'Student Yearly';
      default:
        return planId.replaceAll('_', ' ').toUpperCase();
    }
  }
  
  List<String> _getPlanFeatures(String? planId) {
    if (planId == null) return [];
    
    if (planId.contains('premium')) {
      return [
        'Unlimited quizzes',
        'Ad-free experience',
        'Custom study materials',
        'Create private lobbies',
        'Advanced analytics',
        if (planId.contains('yearly')) 'Priority support',
      ];
    } else if (planId.contains('student')) {
      return [
        'Unlimited quizzes',
        'Ad-free experience',
        'Custom study materials',
        'Create private lobbies',
        if (planId.contains('yearly')) 'Basic analytics',
      ];
    }
    
    return [];
  }
  
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 