import 'package:flutter/material.dart';
import 'package:text_the_answer/utils/font_utility.dart';

class UploadingProfileLoader extends StatelessWidget {
  const UploadingProfileLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Updating profile...',
            style: FontUtility.interRegular(fontSize: 14, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
