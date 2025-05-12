import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../blocs/achievement/achievement_bloc.dart';
import '../../blocs/achievement/achievement_event.dart';
import '../../blocs/achievement/achievement_state.dart';
import '../../models/achievement.dart';
import '../../config/colors.dart';

class LibraryAchievementsPage extends StatefulWidget {
  const LibraryAchievementsPage({Key? key}) : super(key: key);

  @override
  State<LibraryAchievementsPage> createState() => _LibraryAchievementsPageState();
}

class _LibraryAchievementsPageState extends State<LibraryAchievementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load achievements data
    context.read<AchievementBloc>().add(LoadAllAchievements());
    context.read<AchievementBloc>().add(LoadUserAchievements());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDarkMode ? AppColors.darkPrimaryBg : AppColors.lightPrimaryBg;
    final tabTextColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Achievement Library',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDarkMode ? Colors.white : Colors.red,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
          indicatorColor: isDarkMode ? Colors.white : Colors.red,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All Achievements'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocListener<AchievementBloc, AchievementState>(
        listener: (context, state) {
          if (state is AchievementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AchievementUnlocked) {
            _showAchievementUnlockedDialog(context, state.achievement);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllAchievementsTab(),
            _buildCompletedAchievementsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAchievementsTab() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AllAchievementsLoaded) {
          final achievements = state.achievements;
          if (achievements.isEmpty) {
            return _buildEmptyState(
              'No achievements available',
              'Check back later to see achievements.',
              Icons.emoji_events_outlined,
            );
          }
          
          return _buildAllAchievementsView(achievements);
        }
        
        return _buildEmptyState(
          'No achievements found',
          'Check back later to see achievements.',
          Icons.error_outline,
        );
      },
    );
  }

  Widget _buildCompletedAchievementsTab() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserAchievementsLoaded) {
          final achievements = state.achievements;
          if (achievements.isEmpty) {
            return _buildEmptyState(
              'No achievements found',
              'Check back later to see achievements.',
              Icons.emoji_events_outlined,
            );
          }
          
          return _buildCompletedAchievementsView(achievements);
        }
        
        return _buildEmptyState(
          'No achievements found',
          'Check back later to see your achievements.',
          Icons.error_outline,
        );
      },
    );
  }

  Widget _buildAllAchievementsView(List<Achievement> achievements) {
    // Filter out hidden achievements for the public view
    final visibleAchievements = achievements.where((a) => !a.isHidden).toList();
    
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildEmptyStateIfNoAchievements(visibleAchievements),
      ],
    );
  }

  Widget _buildCompletedAchievementsView(List<Achievement> completedAchievements) {
    if (completedAchievements.isEmpty) {
      return _buildEmptyState(
        'No achievements unlocked yet',
        'Complete quizzes, maintain streaks, and participate in activities to earn achievements!',
        Icons.emoji_events_outlined,
      );
    }

    // Add stats card at the top
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        _buildCompletedSummaryCard(completedAchievements),
        SizedBox(height: 24.h),
        _buildAchievementsByTier(completedAchievements),
      ],
    );
  }

  Widget _buildEmptyStateIfNoAchievements(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return _buildEmptyState(
        'No achievements available',
        'Check back later to see achievements.',
        Icons.emoji_events_outlined,
      );
    }
    
    return Column(
      children: [
        Center(
          child: Icon(
            Icons.warning_rounded,
            size: 80.r,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'No achievements found',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Check back later to see achievements.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompletedSummaryCard(List<Achievement> achievements) {
    // Count achievements by tier
    int totalCount = achievements.length;
    int bronzeCount = 0;
    int silverCount = 0;
    int goldCount = 0;
    int platinumCount = 0;
    
    for (var achievement in achievements) {
      switch (achievement.tier.toLowerCase()) {
        case 'bronze':
          bronzeCount++;
          break;
        case 'silver':
          silverCount++;
          break;
        case 'gold':
          goldCount++;
          break;
        case 'platinum':
          platinumCount++;
          break;
      }
    }
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed Achievements',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalCount, '🏆'),
                _buildStatItem('Bronze', bronzeCount, '🥉'),
                _buildStatItem('Silver', silverCount, '🥈'),
                _buildStatItem('Gold', goldCount, '🥇'),
                _buildStatItem('Platinum', platinumCount, '💎'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsByTier(List<Achievement> achievements) {
    // Group achievements by tier
    final Map<String, List<Achievement>> achievementsByTier = {};
    for (var achievement in achievements) {
      if (!achievementsByTier.containsKey(achievement.tier)) {
        achievementsByTier[achievement.tier] = [];
      }
      achievementsByTier[achievement.tier]!.add(achievement);
    }
    
    // Sort tiers by preset order
    final tiers = ['platinum', 'gold', 'silver', 'bronze'];
    tiers.retainWhere((tier) => achievementsByTier.containsKey(tier));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiers.map((tier) {
        return _buildTierSection(
          title: '${tier.substring(0, 1).toUpperCase()}${tier.substring(1)} Achievements',
          achievements: achievementsByTier[tier]!,
        );
      }).toList(),
    );
  }

  Widget _buildTierSection({
    required String title,
    required List<Achievement> achievements,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          children: achievements.map((achievement) => 
            _buildAchievementCard(achievement)
          ).toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final bool isUnlocked = achievement.unlockedAt != null;
    final bool isNew = isUnlocked && !achievement.viewed;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: _getTierColor(achievement.tier),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: () => _showAchievementDetailsDialog(context, achievement),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievement.emojiIcon,
                style: TextStyle(fontSize: 32.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isNew)
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetailsDialog(BuildContext context, Achievement achievement) {
    final bool isUnlocked = achievement.unlockedAt != null;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge with tier color
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: _getTierColor(achievement.tier).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getTierColor(achievement.tier),
                    width: 2.w,
                  ),
                ),
                child: Text(
                  achievement.emojiIcon,
                  style: TextStyle(fontSize: 40.sp),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                achievement.description,
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              if (isUnlocked) 
                Text(
                  'Unlocked on ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                  ),
                )
              else if (achievement.criteria != null)
                Text(
                  'Criteria: ${_formatCriteria(achievement.criteria!)}',
                  style: TextStyle(fontSize: 12.sp),
                ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  // Mark as viewed if unlocked and not viewed
                  if (isUnlocked && !achievement.viewed) {
                    context.read<AchievementBloc>().add(
                      MarkAchievementAsViewed(achievement.id),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementUnlockedDialog(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Achievement Unlocked! 🎉',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              // Badge with tier color
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: _getTierColor(achievement.tier).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getTierColor(achievement.tier),
                    width: 2.w,
                  ),
                ),
                child: Text(
                  achievement.emojiIcon,
                  style: TextStyle(fontSize: 50.sp),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                achievement.description,
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  // Mark as viewed
                  context.read<AchievementBloc>().add(
                    MarkAchievementAsViewed(achievement.id),
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze': return Color(0xFFCD7F32);
      case 'silver': return Color(0xFFC0C0C0);
      case 'gold': return Color(0xFFFFD700);
      case 'platinum': return Color(0xFFE5E4E2);
      default: return Color(0xFFCD7F32);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCriteria(AchievementCriteria criteria) {
    switch (criteria.type) {
      case 'streak':
        return 'Maintain a streak of ${criteria.value} days';
      case 'questions_answered':
        return 'Answer ${criteria.value} questions';
      case 'correct_answers':
        return 'Get ${criteria.value} correct answers';
      case 'perfect_quizzes':
        return 'Complete ${criteria.value} perfect quizzes';
      case 'multiplayer_wins':
        return 'Win ${criteria.value} multiplayer games';
      case 'study_materials':
        return 'Read ${criteria.value} study materials';
      default:
        return 'Complete the challenge';
    }
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80.r,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 