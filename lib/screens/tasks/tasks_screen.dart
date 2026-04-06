import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      final user = context.read<AuthProvider>().user;
      if (user != null) provider.setCurrentUser(user.uid);
      provider.loadTasks(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final currentUserId = context.read<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Tasks', style: AppTextStyles.h2),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.hintGrey,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelMedium,
          tabs: const [Tab(text: 'Available'), Tab(text: 'My Tasks')],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabs,
              children: [
                _TaskList(tasks: provider.openTasks, emptyMsg: 'No available tasks right now.'),
                _TaskList(
                  tasks: provider.myTasks.where((t) => t.acceptedBy == currentUserId).toList(),
                  emptyMsg: 'You have not accepted any tasks yet.',
                ),
              ],
            ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final String emptyMsg;
  const _TaskList({required this.tasks, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppColors.borderGrey),
          const SizedBox(height: 12),
          Text(emptyMsg, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ]),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<TaskProvider>().loadTasks(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tasks.length,
        itemBuilder: (_, i) => TaskCard(
          task: tasks[i],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: tasks[i]))),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _CategoryChip(label: task.categoryLabel),
            if (task.isUrgent) ...[
              const SizedBox(width: 6),
              const _UrgentBadge(),
            ],
            const Spacer(),
            _StatusBadge(status: task.status),
          ]),
          const SizedBox(height: 10),
          Text(task.title, style: AppTextStyles.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.hintGrey),
            const SizedBox(width: 4),
            Text('${task.barangay}, ${task.city}', style: AppTextStyles.bodySmall),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _InfoPill(icon: Icons.star_outline, label: '${task.points} pts', color: AppColors.primary),
            const SizedBox(width: 8),
            _InfoPill(icon: Icons.people_outline, label: '${task.volunteersAccepted}/${task.volunteersNeeded}', color: AppColors.textGrey),
            const Spacer(),
            Text(
              DateFormat('MMM d • h:mma').format(task.scheduledStart),
              style: AppTextStyles.bodySmall,
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(
                task.status == TaskStatus.open ? 'View Task Details >' : 'View Progress',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11)),
      );
}

class _UrgentBadge extends StatelessWidget {
  const _UrgentBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.urgent, width: 1)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.urgent, size: 11),
          const SizedBox(width: 3),
          Text('URGENT', style: AppTextStyles.bodySmall.copyWith(color: AppColors.urgent, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5)),
        ]),
      );
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg; String label;
    switch (status) {
      case TaskStatus.accepted: bg = const Color(0xFFE3F2FD); label = 'Accepted'; break;
      case TaskStatus.inProgress: bg = const Color(0xFFFFF3E0); label = 'In Progress'; break;
      case TaskStatus.completed: bg = const Color(0xFFE8F5E9); label = 'Completed'; break;
      case TaskStatus.verified: bg = const Color(0xFFE8F5E9); label = 'Verified ✓'; break;
      default: return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _InfoPill({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w500)),
      ]);
}