import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.authorAvatarUrl != null ? NetworkImage(post.authorAvatarUrl!) : null,
                  child: post.authorAvatarUrl == null ? Text(post.authorUsername[0].toUpperCase()) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorUsername, style: AppTextStyles.labelMedium),
                      Text('${post.barangay}, ${post.city} • ${DateFormat('MMM d, yyyy').format(post.createdAt)}', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(post.title, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            // Image
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.imageUrl!, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            // Caption
            Text(post.caption, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            // Tags
            Wrap(
              spacing: 8,
              children: post.tags.map((t) => Chip(label: Text('#$t', style: AppTextStyles.bodySmall))).toList(),
            ),
            const SizedBox(height: 20),
            // Stats
            Row(
              children: [
                Icon(Icons.arrow_upward, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('${post.upvotes}', style: AppTextStyles.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.hintGrey),
                const SizedBox(width: 4),
                Text('${post.commentCount}', style: AppTextStyles.bodyMedium),
              ],
            ),
            const Divider(),
            // Comments placeholder
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Comments coming soon', style: AppTextStyles.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}