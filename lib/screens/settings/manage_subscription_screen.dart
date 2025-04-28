import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../config/colors.dart';
import '../../router/routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/subscription_modal.dart';
import 'package:text_the_answer/models/subscription.dart';
import 'package:text_the_answer/services/api_service.dart';
import 'package:text_the_answer/widgets/common/app_loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ManageSubscriptionScreen extends StatelessWidget {
  const ManageSubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc(
        apiService: ApiService(),
      )..add(const FetchSubscriptionDetails()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Subscription'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionCancelled) {
              // Navigate to cancellation confirmation screen
              Navigator.pushNamed(
                context, 
                Routes.cancellationConfirmation,
                arguments: {'subscription': state.subscription},
              );
            } else if (state is SubscriptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const AppLoadingIndicator();
            } else if (state is SubscriptionDetailsLoaded) {
              return _buildSubscriptionDetails(context, state.subscription);
            } else if (state is SubscriptionError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('No subscription information available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, Subscription subscription) {
    final bool isActive = subscription.status == 'active';
    final DateTime? endDate = subscription.currentPeriodEnd != null 
        ? DateTime.fromMillisecondsSinceEpoch(subscription.currentPeriodEnd! * 1000)
        : null;
        
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPlanCard(context, subscription, isActive, endDate),
          const SizedBox(height: 24),
          if (subscription.planId?.isNotEmpty == true)
            _buildSubscriptionHistory(context, subscription, isActive, endDate),
          const SizedBox(height: 24),
          _buildPremiumBenefits(),
          const SizedBox(height: 24),
          _buildActionButtons(context, subscription, isActive),
          const SizedBox(height: 24),
          _buildFaqSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, Subscription subscription, bool isActive, DateTime? endDate) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final String planName = _getPlanName(subscription.planId);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPlanIcon(subscription.planId),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Plan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        planName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (endDate != null)
              Row(
                children: [
                  Icon(
                    isActive ? Icons.calendar_today : Icons.calendar_today_outlined,
                    size: 18,
                    color: isActive ? Colors.black87 : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActive
                        ? 'Next billing date: ${dateFormat.format(endDate)}'
                        : 'Access until: ${dateFormat.format(endDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? Colors.black87 : Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubscriptionHistory(BuildContext context, Subscription subscription, bool isActive, DateTime? endDate) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              date: DateTime.now(),
              action: 'Viewing subscription details',
              isActive: true,
            ),
            if (subscription.currentPeriodStart != null)
              _buildHistoryItem(
                date: DateTime.fromMillisecondsSinceEpoch(subscription.currentPeriodStart! * 1000),
                action: 'Current billing period started',
                isActive: false,
              ),
            if (!isActive && subscription.status == 'canceled')
              _buildHistoryItem(
                date: DateTime.now().subtract(const Duration(days: 1)),
                action: 'Subscription cancelled',
                isActive: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({required DateTime date, required String action, required bool isActive}) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(Icons.check_circle_outline, 'Unlimited quiz attempts'),
        _buildBenefitItem(Icons.check_circle_outline, 'Ad-free experience'),
        _buildBenefitItem(Icons.check_circle_outline, 'Create private lobbies'),
        _buildBenefitItem(Icons.check_circle_outline, 'Advanced analytics'),
        _buildBenefitItem(Icons.check_circle_outline, 'Custom study materials'),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Subscription subscription, bool isActive) {
    final isPremium = subscription.planId?.isNotEmpty ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPremium && isActive)
          ElevatedButton(
            onPressed: () => _showCancellationDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[900],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel Subscription'),
          ),
        if (!isPremium || !isActive)
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.subscriptionPlans);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Upgrade to Premium'),
          ),
        if (isPremium && isActive)
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.subscriptionPlans);
            },
            child: const Text('View Other Plans'),
          ),
      ],
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFaqItem(
          'How do I cancel my subscription?',
          'You can cancel your subscription anytime from this screen. Your premium benefits will continue until the end of your current billing period.',
        ),
        _buildFaqItem(
          'Will I lose my data if I cancel?',
          'No, all your quiz history and achievements will be preserved even if you cancel your premium subscription.',
        ),
        _buildFaqItem(
          'Can I get a refund?',
          'Refund requests are handled case by case. Please contact our support team at support@texttheanswer.com for assistance.',
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text(
          'Are you sure you want to cancel your subscription? You will still have access to premium features until the end of your current billing period.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('KEEP SUBSCRIPTION'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SubscriptionBloc>().add(const CancelSubscription());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('CANCEL SUBSCRIPTION'),
          ),
        ],
      ),
    );
  }
  
  IconData _getPlanIcon(String? planId) {
    if (planId == null || planId.isEmpty) return Icons.card_membership;
    
    if (planId.contains('premium')) {
      return Icons.workspace_premium;
    } else if (planId.contains('student')) {
      return Icons.school;
    }
    
    return Icons.card_membership;
  }
  
  String _getPlanName(String? planId) {
    if (planId == null || planId.isEmpty) return 'Free Plan';
    
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
}
