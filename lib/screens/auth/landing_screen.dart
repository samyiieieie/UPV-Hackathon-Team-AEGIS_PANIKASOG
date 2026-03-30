import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_logo.dart';
import 'login_screen.dart';
import 'signup_step1_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      title: 'Stay\nInformed',
      icon: Icons.notifications_active_outlined,
      description: 'Get real-time alerts on disasters and emergencies in your community.',
    ),
    _SlideData(
      title: 'Report\nHazards',
      icon: Icons.report_problem_outlined,
      description: 'Quickly report hazards so responders can act fast when it matters most.',
    ),
    _SlideData(
      title: 'Earn\nPoints',
      icon: Icons.emoji_events_outlined,
      description: 'Complete volunteer tasks and earn points that reflect your impact.',
    ),
    _SlideData(
      title: 'Redeem\nRewards',
      icon: Icons.card_giftcard_outlined,
      description: 'Turn your points into real rewards from our partner brands.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Top carousel (gradient + phone mockup) ─────────────────────────
          Expanded(
            flex: 6,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (context, index) =>
                  _SlideTop(slide: _slides[index]),
            ),
          ),

          // ── Dot indicators ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => _Dot(active: i == _currentPage)),
            ),
          ),

          // ── Bottom card ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
            decoration: const BoxDecoration(color: AppColors.white),
            child: Column(
              children: [
                const AppLogo(),
                const SizedBox(height: 8),
                Text(
                  'Join our community and earn rewards',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Sign Up',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupStep1Screen()),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Login',
                  variant: ButtonVariant.outline,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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

// ─── Slide top section ─────────────────────────────────────────────────────────
class _SlideTop extends StatelessWidget {
  final _SlideData slide;
  const _SlideTop({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.splashGradient,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Title
              Text(
                slide.title,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.white,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Phone mockup
              _PhoneMockup(icon: slide.icon),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Phone mockup illustration ─────────────────────────────────────────────────
class _PhoneMockup extends StatelessWidget {
  final IconData icon;
  const _PhoneMockup({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: Stack(
        children: [
          // Screen
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                color: AppColors.white.withValues(alpha: 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: AppColors.white, size: 48),
                    const SizedBox(height: 12),
                    Container(
                      height: 6,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Notch
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page dot indicator ────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.borderGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Data class ────────────────────────────────────────────────────────────────
class _SlideData {
  final String title;
  final IconData icon;
  final String description;

  const _SlideData({
    required this.title,
    required this.icon,
    required this.description,
  });
}
