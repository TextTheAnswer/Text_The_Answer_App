import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class SubscriptionInfoCard extends StatelessWidget {
  final SubscriptionInfo subscription;
  final bool isPremium;
  final bool isDarkMode;
  final VoidCallback? onManageSubscription;

  const SubscriptionInfoCard({
    Key? key,
    required this.subscription,
    required this.isPremium,
    required this.isDarkMode,
    this.onManageSubscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor = isPremium 
        ? Colors.amber.withOpacity(isDarkMode ? 0.15 : 0.1)
        : isDarkMode ? AppColors.darkPrimaryBg : AppColors.white;
    
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: isPremium 
            ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1) 
            : isDarkMode ? null : Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPremium ? Icons.diamond : Icons.person_outline,
                color: isPremium ? Colors.amber : isDarkMode ? Colors.white70 : Colors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Subscription',
                style: FontUtility.montserratBold(
                  fontSize: 18.sp,
                  color: isDarkMode ? Colors.white : AppColors.darkGray,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _formatStatus(subscription.status),
                  style: FontUtility.interMedium(
                    fontSize: 12.sp,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Subscription details
          if (subscription.currentPeriodEnd.isNotEmpty && isPremium) ...[
            _buildInfoRow(
              'Current Period Ends',
              subscription.currentPeriodEnd,
              Icons.calendar_today_outlined,
            ),
            SizedBox(height: 8.h),
            _buildInfoRow(
              'Auto Renew',
              subscription.cancelAtPeriodEnd ? 'Off' : 'On',
              subscription.cancelAtPeriodEnd ? Icons.cancel_outlined : Icons.autorenew,
            ),
          ],
          
          if (!isPremium) ...[
            Text(
              'Upgrade to Premium for exclusive content and features.',
              style: FontUtility.interRegular(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
          
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onManageSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? Colors.amber : AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                isPremium ? 'Manage Subscription' : 'Upgrade to Premium',
                style: FontUtility.montserratBold(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: FontUtility.interRegular(
            fontSize: 14.sp,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: FontUtility.interMedium(
            fontSize: 14.sp,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'premium':
        return Colors.amber;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      case 'canceled':
        return Colors.orange;
      default:
        return isDarkMode ? Colors.white70 : Colors.grey;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Free';
    
    // Capitalize first letter
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
} 