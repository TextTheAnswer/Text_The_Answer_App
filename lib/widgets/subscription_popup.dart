import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../router/routes.dart';

class SubscriptionPopup extends StatelessWidget {
  final String title;
  final String message;
  final String? featureImage;
  final VoidCallback onClose;

  const SubscriptionPopup({
    Key? key,
    required this.title,
    required this.message,
    this.featureImage,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onClose,
            ),
          ),
          
          // Icon or image
          if (featureImage != null)
            Image.asset(
              featureImage!,
              height: 100,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Message
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Buttons
          Row(
            children: [
              // Maybe later button
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Upgrade button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    onClose();
                    Navigator.pushNamed(context, Routes.subscriptionPlans);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Upgrade Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 