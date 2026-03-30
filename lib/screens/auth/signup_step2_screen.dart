import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/chip_input_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_shared_widgets.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();

  List<String> _selectedSkills = [];
  List<String> _selectedTasks = [];

  static const _skillSuggestions = [
    'First Aid',
    'Cleaning & Sanitation',
    'Driving',
    'Swimming',
    'Cooking',
    'Search & Rescue',
    'Medical',
    'Construction',
    'Communication',
    'Logistics',
    'IT / Tech',
    'Teaching',
    'Counseling',
    'Navigation',
  ];

  static const _taskSuggestions = [
    'Emergency Response',
    'Preparedness',
    'Cleanup & Recovery',
    'Relief Distribution',
    'Medical Assistance',
    'Evacuation Support',
    'Search & Rescue',
    'Community Education',
    'Infrastructure Repair',
    'Food & Water Distribution',
    'Psychosocial Support',
    'Coordination',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _addressCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      _showSnack('Please add at least one skill.');
      return;
    }
    if (_selectedTasks.isEmpty) {
      _showSnack('Please select at least one preferred task.');
      return;
    }

    final success = await context.read<AuthProvider>().signUp(
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          skills: _selectedSkills,
          preferredTasks: _selectedTasks,
          referralCode: _referralCtrl.text.trim().isEmpty
              ? null
              : _referralCtrl.text.trim().toUpperCase(),
        );

    if (!mounted) return;
    if (success) {
      _showSuccessDialog();
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      if (error != null) _showSnack(error);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.chipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Account Created!',
                style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'Welcome to PANIKASOG! A verification email has been sent to your inbox.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (_referralCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.referralBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '🎉 You earned 100 bonus points for using a referral code!',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              label: 'Go to Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PanikasogAppBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                const Text('Sign up', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                const AuthStepIndicator(
                  currentStep: 2,
                  totalSteps: 2,
                  label: 'Step 2: Additional Information',
                ),
                const SizedBox(height: 24),

                // ── Name ─────────────────────────────────────────────────────
                AppTextField(
                  label: 'Name',
                  hint: 'Juan Dela Cruz',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Username ──────────────────────────────────────────────────
                AppTextField(
                  label: 'Username',
                  hint: '@Juan_01',
                  controller: _usernameCtrl,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Icon(Icons.alternate_email,
                        size: 18, color: AppColors.hintGrey),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Username is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                      return 'Only letters, numbers and underscores';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Address ───────────────────────────────────────────────────
                AppTextField(
                  label: 'Address',
                  hint: 'e.g. 123 Main St, Springfield, IL',
                  controller: _addressCtrl,
                  textInputAction: TextInputAction.next,
                  suffixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.hintGrey, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Skills ────────────────────────────────────────────────────
                ChipInputField(
                  label: 'Skills',
                  hint: 'Enter skills...',
                  suggestions: _skillSuggestions,
                  selectedValues: _selectedSkills,
                  onChanged: (vals) =>
                      setState(() => _selectedSkills = vals),
                ),
                const SizedBox(height: 16),

                // ── Preferred Tasks ───────────────────────────────────────────
                ChipInputField(
                  label: 'Preferred Tasks',
                  hint: 'Enter preferred tasks...',
                  suggestions: _taskSuggestions,
                  selectedValues: _selectedTasks,
                  onChanged: (vals) =>
                      setState(() => _selectedTasks = vals),
                ),
                const SizedBox(height: 24),

                // ── Referral Code ─────────────────────────────────────────────
                _ReferralCodeSection(controller: _referralCtrl),
                const SizedBox(height: 28),

                // ── Finish button ─────────────────────────────────────────────
                AppButton(
                  label: 'Finish Sign up',
                  onPressed: _finishSignup,
                  isLoading: authProvider.isLoading,
                ),

                // ── Error banner ──────────────────────────────────────────────
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Referral code section ─────────────────────────────────────────────────────
class _ReferralCodeSection extends StatelessWidget {
  final TextEditingController controller;
  const _ReferralCodeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral Code',
            style: AppTextStyles.inputLabel.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'XXXXXXXX',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.hintGrey,
                letterSpacing: 2,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primaryLight, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "* Sign up using a friend's referral code and earn 100 rewards points each!",
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}