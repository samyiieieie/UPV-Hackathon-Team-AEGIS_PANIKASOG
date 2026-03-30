import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/post_model.dart';

/// Shows a bottom sheet confirming an upvote/downvote action.
/// Matches the "Home - Voting Dialog" screenshot exactly.
Future<bool?> showVoteDialog({
  required BuildContext context,
  required PostModel post,
  required String voteType, // 'up' or 'down'
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _VoteDialog(post: post, voteType: voteType),
  );
}

class _VoteDialog extends StatelessWidget {
  final PostModel post;
  final String voteType;
  const _VoteDialog({required this.post, required this.voteType});

  @override
  Widget build(BuildContext context) {
    final isUpvote = voteType == 'up';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color:
                  (isUpvote ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUpvote
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isUpvote ? AppColors.primary : AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isUpvote ? 'Upvote this post?' : 'Downvote this post?',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            '"${post.title}"',
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUpvote ? AppColors.primary : AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                isUpvote ? 'Yes, upvote' : 'Yes, downvote',
                style: AppTextStyles.labelLarge,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderGrey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
