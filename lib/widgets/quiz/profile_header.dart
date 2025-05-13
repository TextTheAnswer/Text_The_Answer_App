import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.userName,
    required this.email,
    required this.avaterUrl,
    required this.isPremium,
  });

  final String userName;
  final String email;
  final String avaterUrl;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    //TODO: Remove for center app theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color.fromARGB(255, 32, 35, 50)
                : const Color.fromARGB(255, 225, 225, 238),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          // -- Profile Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // -- Profile Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // -- Image
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(avaterUrl),
                    ),

                    // -- Level Badge
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white : Colors.black,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          'Lv5',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // -- Profile name
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Username
                    Text(userName, style: TextStyle(fontSize: 30)),
                    const SizedBox(height: 10),

                    // -- Email
                    Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // -- Divider
          Divider(),

          // -- Complete Profile
          Row(
            children: [
              Text('Complete Profile'),
              const SizedBox(width: 8),
              Text(
                '+10Xp',
                style: TextStyle(
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          // -- Is Premium
        ],
      ),
    );
  }
}
