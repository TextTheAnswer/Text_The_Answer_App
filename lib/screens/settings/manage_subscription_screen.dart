import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../config/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/subscription_modal.dart';
import 'package:text_the_answer/models/user_profile_model.dart';
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
        ),
        body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is CheckoutSessionCreated) {
              _launchCheckoutUrl(state.checkoutUrl);
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
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              subscription.planId?.contains('premium') ?? false 
                  ? 'Premium Plan' 
                  : 'Free Plan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isActive && subscription.planId?.contains('premium') == true)
              Text(
                endDate != null 
                    ? 'Valid until: ${dateFormat.format(endDate)}' 
                    : 'Active subscription',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (!isActive && subscription.status == 'canceled')
              Text(
                endDate != null 
                    ? 'Access until: ${dateFormat.format(endDate)}' 
                    : 'Subscription canceled',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
          ],
        ),
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
        _buildBenefitItem(Icons.check_circle_outline, 'Access to premium question banks'),
        _buildBenefitItem(Icons.check_circle_outline, 'Early access to new features'),
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
    final isPremium = subscription.planId?.contains('premium') ?? false;
    
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
              context.read<SubscriptionBloc>().add(
                const CreateCheckoutSession(priceId: 'price_premium_monthly')
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Upgrade to Premium'),
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

  Future<void> _launchCheckoutUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
