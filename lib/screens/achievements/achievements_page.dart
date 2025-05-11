import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/achievement/achievement_bloc.dart';
import '../../blocs/achievement/achievement_event.dart';
import '../../blocs/achievement/achievement_state.dart';
import '../../models/achievement.dart';
import '../../widgets/common/section_title.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load achievements data
    context.read<AchievementBloc>().add(LoadAllAchievements());
    context.read<AchievementBloc>().add(LoadUserAchievements());
    context.read<AchievementBloc>().add(LoadHiddenAchievements());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Achievements'),
            Tab(text: 'All Achievements'),
            Tab(text: 'Hidden'),
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
            _buildUserAchievementsTab(),
            _buildAllAchievementsTab(),
            _buildHiddenAchievementsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAchievementsTab() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserAchievementsLoaded) {
          final achievements = state.achievements;
          if (achievements.isEmpty) {
            return _buildEmptyState(
              'No achievements unlocked yet',
              'Complete quizzes, maintain streaks, and participate in our activities to earn achievements!',
              Icons.emoji_events_outlined,
            );
          }
          
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
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card at the top with total achievements
              _buildSummaryCard(achievements),
              const SizedBox(height: 16),
              ...tiers.map((tier) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: '${tier.substring(0, 1).toUpperCase()}${tier.substring(1)} Achievements',
                    ),
                    const SizedBox(height: 8),
                    _buildAchievementGrid(achievementsByTier[tier]!),
                    const SizedBox(height: 24),
                  ],
                );
              }).toList(),
            ],
          );
        }
        
        return _buildEmptyState(
          'No achievements found',
          'Check back later to see your achievements.',
          Icons.error_outline,
        );
      },
    );
  }
  
  Widget _buildSummaryCard(List<Achievement> achievements) {
    // Calculate statistics for the summary card
    final totalAchievements = achievements.length;
    
    // Count achievements by tier
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievement Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalAchievements.toString(), '🏆'),
                _buildStatItem('Bronze', bronzeCount.toString(), '🥉'),
                _buildStatItem('Silver', silverCount.toString(), '🥈'),
                _buildStatItem('Gold', goldCount.toString(), '🥇'),
                _buildStatItem('Platinum', platinumCount.toString(), '💎'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
              'Check back later for achievements to earn.',
              Icons.emoji_events_outlined,
            );
          }
          
          // Filter out hidden achievements
          final visibleAchievements = achievements.where((a) => !a.isHidden).toList();
          
          // Group achievements by type using criteria.type
          final Map<String, List<Achievement>> achievementsByType = {};
          for (var achievement in visibleAchievements) {
            final type = achievement.criteria?.type ?? 'other';
            if (!achievementsByType.containsKey(type)) {
              achievementsByType[type] = [];
            }
            achievementsByType[type]!.add(achievement);
          }
          
          final types = achievementsByType.keys.toList();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: types.map((type) {
              // Format the type name for display
              final displayType = type.split('_').map((word) => 
                '${word.substring(0, 1).toUpperCase()}${word.substring(1)}'
              ).join(' ');
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: displayType,
                  ),
                  const SizedBox(height: 8),
                  _buildAchievementGrid(achievementsByType[type]!),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          );
        }
        
        return _buildEmptyState(
          'No achievements found',
          'Check back later to see achievements.',
          Icons.error_outline,
        );
      },
    );
  }

  Widget _buildHiddenAchievementsTab() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HiddenAchievementsLoaded) {
          final hiddenAchievements = state.hiddenAchievements;
          if (hiddenAchievements.isEmpty) {
            return _buildEmptyState(
              'No hidden achievements',
              'Hidden achievements will appear here when they are discovered.',
              Icons.lock_outline,
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle(
                title: 'Hidden Achievements',
              ),
              const SizedBox(height: 8),
              Text(
                'These achievements are special and can be discovered by completing secret challenges or finding easter eggs in the app.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildHiddenAchievementsGrid(hiddenAchievements),
            ],
          );
        }
        
        return _buildEmptyState(
          'No hidden achievements found',
          'Check back later for hidden achievements.',
          Icons.lock_outline,
        );
      },
    );
  }

  Widget _buildAchievementGrid(List<Achievement> achievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = achievement.unlockedAt != null;
        
        return GestureDetector(
          onTap: () => _showAchievementDetailsDialog(context, achievement),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isUnlocked 
                  ? Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000)
                  : Colors.grey.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    achievement.emojiIcon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isUnlocked && !achievement.viewed)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHiddenAchievementsGrid(List<Achievement> hiddenAchievements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: hiddenAchievements.length,
      itemBuilder: (context, index) {
        final achievement = hiddenAchievements[index];
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 32, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  '???',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hint: ${achievement.description}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAchievementDetailsDialog(BuildContext context, Achievement achievement) {
    final isUnlocked = achievement.unlockedAt != null;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge with tier color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000),
                    width: 2,
                  ),
                ),
                child: Text(
                  achievement.emojiIcon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isUnlocked) 
                Text(
                  'Unlocked on ${_formatDate(achievement.unlockedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                )
              else if (achievement.criteria != null)
                Text(
                  'Criteria: ${_formatCriteria(achievement.criteria!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 24),
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
                child: const Text('Close'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Achievement Unlocked! 🎉',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Badge with tier color
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(int.parse(achievement.tierColor.substring(1), radix: 16) | 0xFF000000),
                    width: 2,
                  ),
                ),
                child: Text(
                  achievement.emojiIcon,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Mark as viewed
                  context.read<AchievementBloc>().add(
                    MarkAchievementAsViewed(achievement.id),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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