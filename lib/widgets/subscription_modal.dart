import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../blocs/subscription/subscription_bloc.dart';
import '../blocs/subscription/subscription_event.dart';
import '../config/colors.dart';
import '../router/routes.dart';
import '../screens/subscription/subscription_screen.dart';
import 'custom_button.dart';

class SubscriptionModal extends StatelessWidget {
  final VoidCallback onDismiss;
  final String? feature; // Optional feature name that triggered this modal

  const SubscriptionModal({
    Key? key,
    required this.onDismiss,
    this.feature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Premium Icon
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              size: 40.r,
              color: Colors.amber[800],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Title
          Text(
            feature != null
                ? 'Unlock $feature with Premium'
                : 'Upgrade to Premium',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16.h),
          
          // Description
          Text(
            feature != null
                ? 'Get unlimited access to $feature and all other premium features.'
                : 'Enjoy unlimited questions, no ads, and exclusive content with our premium subscription.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24.h),
          
          // Feature list
          _buildFeatureItem(context, 'Unlimited daily questions'),
          _buildFeatureItem(context, 'Ad-free experience'),
          _buildFeatureItem(context, 'Exclusive categories'),
          _buildFeatureItem(context, 'Premium support'),
          
          SizedBox(height: 24.h),
          
          // Buttons
          CustomButton(
            text: 'Get Premium',
            onPressed: () {
              Navigator.of(context).pop(); // Close the modal
              Navigator.of(context).pushNamed(Routes.manageSubscription);
            },
            bgColor: AppColors.primary,
            icon: Icons.star,
          ),
          
          SizedBox(height: 12.h),
          
          CustomButton(
            text: 'Maybe Later',
            onPressed: onDismiss,
            buttonType: CustomButtonType.outline,
            borderColor: Colors.grey,
            textColor: Colors.grey[700],
          ),
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the subscription modal
void showSubscriptionModal(BuildContext context, {String? feature}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SubscriptionModal(
      onDismiss: () => Navigator.of(context).pop(),
      feature: feature,
    ),
  );
} 