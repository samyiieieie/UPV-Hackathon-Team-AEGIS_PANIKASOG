import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/text_styles.dart';
import '../../models/post_model.dart';
import '../../models/task_model.dart';
import '../../models/urgent_task_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post_card.dart';
import '../tasks/task_detail_screen.dart';
import 'post_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
// Note: If you have a custom app logo widget, import it here:
// import '../../widgets/app_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadFeed(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<PostProvider>().loadFeed();
    }
  }

  Future<void> _handleVote(
      BuildContext context, PostModel post, String voteType) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final confirmed = await showVoteDialog(
      context: context,
      post: post,
      voteType: voteType,
    );
    if (confirmed == true && context.mounted) {
      await context.read<PostProvider>().vote(
            postId: post.id,
            userId: userId,
            voteType: voteType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final auth = context.watch<AuthProvider>();
    final allPosts = postProvider.posts;
    final filteredPosts = _filteredPosts(allPosts);
    final urgentTasks = postProvider.urgentTasks;

    // Use a very light pinkish-grey background based on the screenshot
    final Color backgroundColor = const Color(0xFFFCF5F7); 

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // Replace Icon with your AppLogo() widget if it renders the graphic
            const Icon(Icons.cyclone, color: Color(0xFFC2185B), size: 28), 
            const SizedBox(width: 8),
            Text(
              'PANIKASOG', 
              style: AppTextStyles.h1.copyWith(
                fontSize: 20, 
                color: const Color(0xFFC2185B), // Deep pink/red logo color
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
               // Assuming profile screen navigation
               Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(auth.user?.avatarUrl ?? 'https://via.placeholder.com/150'),
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87, size: 26),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => postProvider.loadFeed(refresh: true),
            color: const Color(0xFFC2185B),
            child: CustomScrollView(
              slivers: [
                // "Home" Header Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5A2A66), // Deep purple/magenta
                      ),
                    ),
                  ),
                ),

                // Search bar and Filter Button Row
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (value) => setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Search posts...',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B225E), // Purple background for icon
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B225E).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                            onPressed: () {
                              // Handle filter opening
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter chips
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedFilter == FeedFilter.all,
                            onSelected: () => setState(() => _selectedFilter = FeedFilter.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Community',
                            isSelected: _selectedFilter == FeedFilter.community,
                            onSelected: () => setState(() => _selectedFilter = FeedFilter.community),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Verified',
                            isSelected: _selectedFilter == FeedFilter.verified,
                            onSelected: () => setState(() => _selectedFilter = FeedFilter.verified),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Tasks',
                            isSelected: _selectedFilter == FeedFilter.tasks,
                            onSelected: () => setState(() => _selectedFilter = FeedFilter.tasks),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'News',
                            isSelected: _selectedFilter == FeedFilter.news,
                            onSelected: () => setState(() => _selectedFilter = FeedFilter.news),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Posts feed
                if (postProvider.isLoading && allPosts.isEmpty)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFC2185B))))
                else if (postProvider.error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(postProvider.error!, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => postProvider.loadFeed(refresh: true), 
                            child: const Text('Retry')
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredPosts.isEmpty)
                  const SliverFillRemaining(child: Center(child: Text('No posts found', style: AppTextStyles.bodyMedium)))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final post = filteredPosts[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: PostCard(
                            post: post,
                            currentUserId: auth.user?.uid,
                            userVote: postProvider.userVoteFor(post.id),
                            onUpvote: () => postProvider.vote(postId: post.id, userId: auth.user?.uid ?? '', voteType: 'up'),
                            onDownvote: () => postProvider.vote(postId: post.id, userId: auth.user?.uid ?? '', voteType: 'down'),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
                          ),
                        );
                      },
                      childCount: filteredPosts.length,
                    ),
                  ),
                  
                  // Add bottom padding to prevent items from hiding behind the Urgent Tasks bottom sheet
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          ),

          // Collapsible Urgent Tasks section (Floating at bottom as in image)
          if (urgentTasks.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: _UrgentCollapsible(
                expanded: _urgentExpanded,
                onToggle: () => setState(() => _urgentExpanded = !_urgentExpanded),
                tasks: urgentTasks,
              ),
            ),
        ],
      ),
    );
  }
}

// Collapsible widget redesigned to match screenshot (White, top-rounded)
class _UrgentCollapsible extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<UrgentTaskModel> tasks;

  const _UrgentCollapsible({
    required this.expanded,
    required this.onToggle,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (always visible)
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC2185B), // Magenta circle
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Urgent Tasks',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5A2A66), // Dark purple text
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(color: Colors.black12, height: 1, thickness: 1),
                Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return _UrgentTaskTile(task: task);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Individual urgent task tile - adapted to light theme
class _UrgentTaskTile extends StatelessWidget {
  final UrgentTaskModel task;
  const _UrgentTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final fullTask = TaskModel(
          id: task.id,
          title: task.title,
          description: task.urgentReasons.join(', '),
          barangay: task.barangay,
          city: task.city,
          category: TaskCategory.emergencyResponse,
          points: task.points,
          volunteersNeeded: task.volunteersNeeded,
          volunteersAccepted: task.volunteersAccepted,
          scheduledStart: task.scheduledAt,
          scheduledEnd: task.scheduledAt.add(const Duration(hours: 2)),
          createdBy: '',
          isUrgent: true,
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: fullTask)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_outlined, color: Colors.black54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.barangay}, ${task.city} • ${task.points} pts',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFC2185B); // Match magenta in screenshot

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}