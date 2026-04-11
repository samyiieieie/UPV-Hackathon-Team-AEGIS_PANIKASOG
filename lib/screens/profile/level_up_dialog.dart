import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_model.dart';
import '../../services/user_progress_service.dart';

/// Celebratory dialog shown when user levels up
class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final String levelTitle;
  final int totalExp;

  const LevelUpDialog({
    required this.newLevel,
    required this.levelTitle,
    required this.totalExp,
  });

  /// Show level-up dialog
  static void show(
    BuildContext context, {
    required int newLevel,
    required String levelTitle,
    required int totalExp,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelUpDialog(
        newLevel: newLevel,
        levelTitle: levelTitle,
        totalExp: totalExp,
      ),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = _getLevelInfo(widget.newLevel);
    
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celebration emoji
                    Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),

                    // Level up text
                    Text(
                      'LEVEL UP!',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Level display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFDF0B33),
                            Color(0xFFAB0857),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Level ${widget.newLevel}',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.levelTitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badge icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFB300),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          levelInfo['emoji'] ?? '⭐',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Achievement message
                    Text(
                      levelInfo['achievement']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // EXP display
                    Text(
                      'Total EXP: ${widget.totalExp}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Celebrate!',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _getLevelInfo(int level) {
    switch (level) {
      case 1:
        return {
          'emoji': '🌱',
          'achievement': 'Welcome to the Community!\nYou\'ve taken your first step as a Community Member.',
        };
      case 2:
        return {
          'emoji': '🏘️',
          'achievement': 'You\'re now a Neighborhood Helper!\nKeep helping your neighbors stay safe.',
        };
      case 3:
        return {
          'emoji': '👥',
          'achievement': 'Promoted to Barangay Volunteer!\nYour commitment to your community is recognized.',
        };
      case 4:
        return {
          'emoji': '🛡️',
          'achievement': 'You\'re now a Community Guardian!\nYour leadership inspires others.',
        };
      case 5:
        return {
          'emoji': '🚨',
          'achievement': 'Welcome, Disaster Responder!\nYou\'re equipped to handle emergencies.',
        };
      case 6:
        return {
          'emoji': '👨‍💼',
          'achievement': 'You\'re now an Emergency Leader!\nPeople look to you in times of crisis.',
        };
      case 7:
        return {
          'emoji': '🦸',
          'achievement': 'You\'ve become a Community Hero!\nYour impact on the community is undeniable.',
        };
      case 8:
        return {
          'emoji': '👑',
          'achievement': 'ULTIMATE: Disaster Champion!\nYou are the pinnacle of community service.',
        };
      default:
        return {
          'emoji': '⭐',
          'achievement': 'You\'ve reached a new milestone!\nContinue your amazing work.',
        };
    }
  }
}
