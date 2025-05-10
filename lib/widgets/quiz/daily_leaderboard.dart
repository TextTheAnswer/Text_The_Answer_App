import 'dart:async';
import 'package:flutter/material.dart';

class DailyLeaderboardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> leaderboardEntries;
  final int userRank;
  final int userScore;
  final Map<String, dynamic> theme;
  final Map<String, dynamic>? winner;
  final Function refreshLeaderboard;
  final DateTime lastUpdated;
  final bool showPremiumBadge;

  const DailyLeaderboardWidget({
    super.key,
    required this.leaderboardEntries,
    required this.userRank,
    required this.userScore,
    required this.theme,
    this.winner,
    required this.refreshLeaderboard,
    required this.lastUpdated,
    this.showPremiumBadge = true,
  });

  @override
  State<DailyLeaderboardWidget> createState() => _DailyLeaderboardWidgetState();
}

class _DailyLeaderboardWidgetState extends State<DailyLeaderboardWidget> with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startRefreshTimer() {
    // Refresh more frequently during active events
    const refreshInterval = Duration(seconds: 30);
    
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      _refreshLeaderboard();
    });
  }
  
  Future<void> _refreshLeaderboard() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    await widget.refreshLeaderboard();
    
    setState(() {
      _isRefreshing = false;
    });
  }
  
  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.lastUpdated);
    
    if (difference.inSeconds < 60) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes} min ago';
    } else {
      return 'Updated ${difference.inHours} hr ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshLeaderboard,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: widget.leaderboardEntries.isEmpty
                ? _buildEmptyLeaderboard(context)
                : _buildLeaderboardList(context),
          ),
          if (widget.userRank > 10) _buildUserPosition(context),
          _buildLastUpdated(),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Leaderboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isRefreshing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Theme: ${widget.theme['name']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (widget.theme['description'] != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.theme['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (widget.winner != null) ...[
            const SizedBox(height: 16),
            _buildWinnerCard(context),
          ],
        ],
      ),
    );
  }
  
  Widget _buildWinnerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Winner',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Score: ${widget.winner!['score']}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                if (widget.winner!['totalTime'] != null)
                  Text(
                    'Time: ${_formatTime(widget.winner!['totalTime'])}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showPremiumBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyLeaderboard(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.leaderboard_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No participants yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join the quiz to be the first on the leaderboard!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardList(BuildContext context) {
    return ListView.builder(
      itemCount: widget.leaderboardEntries.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final entry = widget.leaderboardEntries[index];
        final isCurrentUser = entry['rank'] == widget.userRank;
        
        return _buildLeaderboardEntry(
          context,
          entry,
          isCurrentUser,
          index,
        );
      },
    );
  }
  
  Widget _buildLeaderboardEntry(
    BuildContext context,
    Map<String, dynamic> entry,
    bool isCurrentUser,
    int index,
  ) {
    final rank = entry['rank'] as int;
    final backgroundColor = isCurrentUser
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : (index % 2 == 0
            ? Colors.grey.withOpacity(0.05)
            : Colors.white);
    
    // Determine medal color for top 3
    Color? medalColor;
    if (rank == 1) {
      medalColor = Colors.amber;
    } else if (rank == 2) {
      medalColor = Colors.grey.shade400;
    } else if (rank == 3) {
      medalColor = Colors.brown.shade300;
    }
    
    Widget rankWidget = Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: medalColor != null
          ? BoxDecoration(
              color: medalColor,
              shape: BoxShape.circle,
            )
          : null,
      child: Text(
        '#$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: medalColor != null ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
    
    Widget content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: Theme.of(context).primaryColor)
            : null,
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            rankWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['name'] as String,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${entry['correctAnswers']} correct answers',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry['score']} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCurrentUser ? Theme.of(context).primaryColor : null,
                  ),
                ),
                if (entry['totalTime'] != null)
                  Text(
                    _formatTime(entry['totalTime']),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                if (entry['isPerfectScore'] == true)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Perfect',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                if (rank == 1 && widget.showPremiumBadge)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    
    // Add subtle highlight animation for the current user
    if (isCurrentUser) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(
                  _animationController.value * 0.5,
                ),
                width: 2,
              ),
            ),
            child: child,
          );
        },
        child: content,
      );
    }
    
    return content;
  }
  
  Widget _buildUserPosition(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#${widget.userRank}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Position',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Keep playing to move up!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.userScore} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLastUpdated() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.update,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            _getTimeAgo(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _refreshLeaderboard,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  // Helper method to format time in seconds
  String _formatTime(dynamic totalTime) {
    // Handle different types of time inputs
    int timeInMs = 0;
    if (totalTime is int) {
      timeInMs = totalTime;
    } else if (totalTime is String) {
      timeInMs = int.tryParse(totalTime) ?? 0;
    }
    
    if (timeInMs == 0) return '';
    
    // Convert to seconds with 1 decimal place
    final seconds = (timeInMs / 1000).toStringAsFixed(1);
    return '$seconds sec';
  }
} 