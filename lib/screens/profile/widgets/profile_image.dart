import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/config/colors.dart';

const double _kImageSize = 80;

/// Profile Avarter widget
class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: _kImageSize.w,
          height: _kImageSize.w,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                width: _kImageSize.w,
                height: _kImageSize.w,
                color: Colors.grey.shade300,
                child: Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                width: _kImageSize.w,
                height: _kImageSize.w,
                color: Colors.grey.shade300,
                child: Icon(Icons.person, size: 40.sp),
              ),
        ),
      );
    }

    return Container(
      width: _kImageSize.w,
      height: _kImageSize.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Icon(Icons.person, size: 40.sp, color: AppColors.primary),
      ),
    );
  }
}
