import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_card.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_image.dart';
import 'package:text_the_answer/screens/profile/widgets/profile_stats.dart';
import 'package:text_the_answer/utils/constants/app_images.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../config/colors.dart';
import '../../models/user_profile_model.dart';
import '../../models/user_profile_full_model.dart';
import '../../models/profile_model.dart';
import '../../router/routes.dart';
import '../../services/profile_service.dart';
import '../../utils/common_ui.dart';
import '../../utils/font_utility.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_screen.dart';
import 'game_history_screen.dart';
import 'streak_progress_screen.dart';

// Extension method to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Set current index to 4 (Profile) for the bottom nav bar
  int _currentIndex = 4;

  // Service instance
  final ProfileService _profileService = ProfileService();

  // Profile data and loading state
  ProfileData? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch profile data from the API
  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the getFullProfile method directly
      final response = await _profileService.getFullProfile();

      if (kDebugMode) {
        print('ProfileScreen: Full profile fetch response - ${response.success}');
        print('ProfileScreen: Response message - "${response.message}"');
        print('ProfileScreen: Profile data available - ${response.profile != null}');
      }

      setState(() {
        _isLoading = false;
        
        if (response.success && response.profile != null) {
          _profileData = response.profile;
          _errorMessage = null;
          
          if (kDebugMode) {
            print('ProfileScreen: Profile loaded successfully');
            print('ProfileScreen: User: ${_profileData?.name}');
            print('ProfileScreen: Email: ${_profileData?.email}');
            print('ProfileScreen: Achievements: ${_profileData?.achievements?.length ?? 0}');
          }
        } else {
          _profileData = null;
          _errorMessage = response.message ?? 'Failed to load profile';
          
          if (kDebugMode) {
            print('ProfileScreen: Failed to load profile: $_errorMessage');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('ProfileScreen: Exception in _fetchProfileData - $e');
      }

      setState(() {
        _isLoading = false;
        _profileData = null;
        _errorMessage = 'Error loading profile: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTap: _onTabTapped,
      // ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg,
        elevation: 0,
        title: Text(
          'Profile',
          style: FontUtility.interSemiBold(
            fontSize: 20.sp,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: _navigateToHome,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              context.push(AppRoutePath.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: _buildProfileBody(),
      ),
    );
  }

  Widget _buildProfileBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text('Error', style: FontUtility.interSemiBold(fontSize: 20.sp)),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: FontUtility.interRegular(fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Retry',
              onPressed: _fetchProfileData,
              bgColor: AppColors.primary,
              icon: Icons.refresh,
            ),
          ],
        ),
      );
    }

    if (_profileData == null) {
      return Center(
        child: Text(
          'No profile data available',
          style: FontUtility.interMedium(fontSize: 16.sp),
        ),
      );
    }

    // Profile data loaded successfully
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsSection(),
                SizedBox(height: 24.h),
                _buildDailyQuizSection(),
                SizedBox(height: 24.h),
                _buildSubscriptionSection(),
                SizedBox(height: 24.h),
                if (_profileData?.education != null &&
                    _profileData!.education!.isStudent)
                  _buildEducationSection(),
                if (_profileData?.education != null &&
                    _profileData!.education!.isStudent)
                  SizedBox(height: 24.h),
                if (_profileData?.achievements != null &&
                    _profileData!.achievements!.isNotEmpty)
                  _buildAchievementsSection(),
                if (_profileData?.achievements != null &&
                    _profileData!.achievements!.isNotEmpty)
                  SizedBox(height: 24.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                  image:
                      _profileData?.profile?.imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(
                              _profileData!.profile!.imageUrl!,
                            ),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    _profileData?.profile?.imageUrl == null
                        ? Icon(
                          Icons.person,
                          size: 40.sp,
                          color: Colors.grey[400],
                        )
                        : null,
              ),
              SizedBox(width: 16.w),

              // Name, Email & Subscription Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _profileData?.name ??
                                'User Name',
                            style: FontUtility.interBold(
                              fontSize: 20.sp,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (_profileData?.isPremium == true)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _profileData?.isEducation == true
                                      ? Colors.blue
                                      : Colors.amber,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              _profileData?.isEducation == true ? 'EDU' : 'PRO',
                              style: FontUtility.interBold(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _profileData?.email ??
                          'email@example.com',
                      style: FontUtility.interRegular(
                        fontSize: 14.sp,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bio
          if (_profileData?.profile?.bio != null &&
              _profileData!.profile!.bio!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Text(
                _profileData!.profile!.bio!,
                style: FontUtility.interRegular(
                  fontSize: 14.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),

          // Location
          if (_profileData?.profile?.location != null &&
              _profileData!.profile!.location!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _profileData!.profile!.location!,
                    style: FontUtility.interRegular(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          // Favorite Categories
          if (_profileData?.profile?.preferences?.favoriteCategories != null &&
              _profileData!
                  .profile!
                  .preferences!
                  .favoriteCategories!
                  .isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _profileData!.profile!.preferences!.favoriteCategories!
                        .map(
                          (category) => Chip(
                            label: Text(category),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.sp,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 20.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Your Stats',
                  style: FontUtility.interSemiBold(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  value: _profileData?.stats.streak.toString() ?? '0',
                  label: 'Streak',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  value: _profileData?.stats.totalCorrect.toString() ?? '0',
                  label: 'Correct',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: _profileData?.stats.accuracy ?? '0%',
                  label: 'Accuracy',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.quiz,
                  value: _profileData?.stats.totalAnswered.toString() ?? '0',
                  label: 'Total',
                  color: AppColors.primary,
                ),
              ],
            ),
            if (_profileData?.stats.lastPlayed != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Last played: ${_formatDate(_profileData!.stats.lastPlayed!)}',
                      style: FontUtility.interRegular(
                        fontSize: 14.sp,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuizSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, size: 20.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Daily Quiz',
                  style: FontUtility.interSemiBold(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.question_answer,
                  value:
                      _profileData?.dailyQuiz.questionsAnswered.toString() ??
                      '0',
                  label: 'Questions',
                  color: Colors.purple,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  value:
                      _profileData?.dailyQuiz.correctAnswers.toString() ?? '0',
                  label: 'Correct',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.star,
                  value: _profileData?.dailyQuiz.score.toString() ?? '0',
                  label: 'Score',
                  color: Colors.amber,
                ),
              ],
            ),
            if (_profileData?.dailyQuiz.lastCompleted != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.sp,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Last completed: ${_formatDate(_profileData!.dailyQuiz.lastCompleted!)}',
                      style: FontUtility.interRegular(
                        fontSize: 14.sp,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;

    // Define status colors
    final statusColor =
        _profileData?.subscription.status == 'premium'
            ? Colors.amber
            : _profileData?.subscription.status == 'education'
            ? Colors.blue
            : Colors.grey;

    final String statusText =
        _profileData?.subscription.status?.toUpperCase() ?? 'FREE';

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_membership, size: 20.sp, color: statusColor),
                SizedBox(width: 8.w),
                Text(
                  'Subscription',
                  style: FontUtility.interSemiBold(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: FontUtility.interSemiBold(
                      fontSize: 12.sp,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_profileData?.subscription.currentPeriodEnd != null)
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Renewal Date',
                value: _formatDate(
                  _profileData!.subscription.currentPeriodEnd!,
                ),
              ),
            _buildInfoRow(
              icon: Icons.autorenew,
              label: 'Auto-Renewal',
              value:
                  _profileData?.subscription.cancelAtPeriodEnd == true
                      ? 'Off'
                      : 'On',
              valueColor:
                  _profileData?.subscription.cancelAtPeriodEnd == true
                      ? Colors.red
                      : Colors.green,
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: 'Manage Subscription',
              onPressed: () {
                // Navigate to subscription management screen
              },
              bgColor: AppColors.primary,
              icon: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;

    // Define verification status color
    Color verificationColor = Colors.grey;
    String verificationText = 'Unknown';

    if (_profileData?.education?.verificationStatus != null) {
      final status = _profileData!.education!.verificationStatus!.toLowerCase();
      if (status == 'verified') {
        verificationColor = Colors.green;
        verificationText = 'Verified';
      } else if (status == 'pending') {
        verificationColor = Colors.orange;
        verificationText = 'Pending Verification';
      } else if (status == 'rejected') {
        verificationColor = Colors.red;
        verificationText = 'Verification Rejected';
      }
    }

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, size: 20.sp, color: Colors.blue),
                SizedBox(width: 8.w),
                Text(
                  'Education',
                  style: FontUtility.interSemiBold(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_profileData?.education?.studentEmail != null)
              _buildInfoRow(
                icon: Icons.email,
                label: 'Student Email',
                value: _profileData!.education!.studentEmail!,
              ),
            if (_profileData?.education?.yearOfStudy != null)
              _buildInfoRow(
                icon: Icons.school,
                label: 'Year of Study',
                value: _profileData!.education!.yearOfStudy.toString(),
              ),
            if (_profileData?.education?.verificationStatus != null)
              _buildInfoRow(
                icon: Icons.verified_user,
                label: 'Verification Status',
                value: verificationText,
                valueColor: verificationColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;

    // Check if there are any achievements to display
    if (_profileData?.achievements == null || _profileData!.achievements!.isEmpty) {
      return SizedBox.shrink(); // Don't show the section if no achievements
    }

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, size: 20.sp, color: Colors.amber),
                SizedBox(width: 8.w),
                Text(
                  'Achievements',
                  style: FontUtility.interSemiBold(
                    fontSize: 18.sp,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // List the achievements
            ...(_profileData?.achievements ?? []).map((achievement) {
              // Format the unlock date
              final formattedDate = _formatDate(achievement.unlockedAt);
              
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievement #${achievement.achievementId}',
                            style: FontUtility.interSemiBold(
                              fontSize: 16.sp,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Unlocked on: $formattedDate',
                            style: FontUtility.interRegular(
                              fontSize: 12.sp,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // "New" badge for unviewed achievements
                    if (!achievement.viewed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'NEW',
                          style: FontUtility.interBold(
                            fontSize: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 12.h),
            // Button to view all achievements
            CustomButton(
              text: 'View All Achievements',
              onPressed: () {
                // Navigate to a detailed achievements screen (to be implemented)
              },
              buttonType: CustomButtonType.outline,
              icon: Icons.format_list_bulleted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: FontUtility.interBold(
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: FontUtility.interRegular(
              fontSize: 12.sp,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: 'Edit Profile',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  profileDetails: _profileData!,
                  onProfileUpdated: () {
                    // Refresh profile data when returning from edit screen
                    _fetchProfileData();
                  },
                ),
              ),
            );
          },
          bgColor: AppColors.primary,
          icon: Icons.edit,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Game History',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GameHistoryScreen()),
            );
          },
          bgColor: Colors.blue,
          icon: Icons.history,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Streak Progress',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StreakProgressScreen()),
            );
          },
          bgColor: Colors.orange,
          icon: Icons.local_fire_department,
        ),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Theme Settings',
          onPressed: () {
            context.push(AppRoutePath.settings);
          },
          buttonType: CustomButtonType.outline,
          icon: Icons.color_lens,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FontUtility.interRegular(
                  fontSize: 12.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: FontUtility.interMedium(
                  fontSize: 14.sp,
                  color:
                      valueColor ??
                      (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Format date string for display
  String _formatDate(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateToCheck = DateTime(date.year, date.month, date.day);
      
      // For today's date, show time instead of date
      if (dateToCheck.isAtSameMomentAs(today)) {
        return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      
      // For yesterday's date
      final yesterday = today.subtract(Duration(days: 1));
      if (dateToCheck.isAtSameMomentAs(yesterday)) {
        return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      
      // For dates this year, omit the year
      if (date.year == now.year) {
        return '${_getMonthName(date.month)} ${date.day}';
      }
      
      // For older dates, include the year
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      // In case of parsing error, return the original string
      print('Error formatting date: $e');
      return isoDateString;
    }
  }
  
  // Helper to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    
    return 'Unknown';
  }

  // Navigate back to home
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  // Navigate to settings
  void _navigateToSettings() {
    context.pushNamed(AppRouteName.settings);
  }

  // Handle tab navigation
  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        // Home
        Navigator.pushReplacementNamed(context, Routes.home);
        break;
      case 1:
      case 2:
      case 3:
        // Library, Games, Daily Quiz - Currently in Home as tabs
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
        break;
      case 4:
        // Profile - Already here
        break;
    }
  }
}
