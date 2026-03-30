import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/urgent_task_model.dart';

class UrgentTasksDrawer extends StatelessWidget {
  final List<UrgentTaskModel> tasks;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(UrgentTaskModel) onTaskTap;

  const UrgentTasksDrawer({
    super.key,
    required this.tasks,
    required this.isExpanded,
    required this.onToggle,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header bar (always visible) ────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_up,
                        color: AppColors.textDark, size: 22),
                  ),
                  const SizedBox(width: 8),
                  const Text('Urgent Tasks', style: AppTextStyles.h3),
                  if (tasks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.urgent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (!isExpanded)
                    TextButton(
                      onPressed: () {}, // Navigate to full urgent tasks list
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        'See More >',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Expanded task list ──────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: tasks.isEmpty
                ? _EmptyUrgent()
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _UrgentTaskCard(
                      task: tasks[i],
                      onTap: () => onTaskTap(tasks[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Single urgent task card ───────────────────────────────────────────────────
class _UrgentTaskCard extends StatelessWidget {
  final UrgentTaskModel task;
  final VoidCallback onTap;
  const _UrgentTaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Urgency reasons ──────────────────────────────────────────────
            if (task.urgentReasons.isNotEmpty) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.urgent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.urgent.withValues(alpha: 0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.urgent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'URGENT',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.urgent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...task.urgentReasons.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppColors.urgent, fontSize: 12)),
                            Expanded(
                              child: Text(
                                r,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Task info ────────────────────────────────────────────────────
            Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services_outlined,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),

                // Title + location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 4,
                        children: task.tags
                            .map((t) => _SmallTag(label: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.chevron_right,
                    color: AppColors.hintGrey, size: 20),
              ],
            ),
            const SizedBox(height: 10),

            // ── Points + volunteers + date ─────────────────────────────────
            Row(
              children: [
                _InfoChip(
                  icon: Icons.star_outline,
                  label: '${task.points} pts',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.people_outline,
                  label: '${task.volunteersAccepted}/${task.volunteersNeeded}',
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: DateFormat('MMM d, yyyy • h:mma')
                      .format(task.scheduledAt),
                  color: AppColors.textGrey,
                ),
              ],
            ),

            // ── Location ────────────────────────────────────────────────────
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.hintGrey, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${task.barangay}, ${task.city}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;
  const _SmallTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.urgent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.urgent,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

class _EmptyUrgent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No urgent tasks right now 🎉',
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}
