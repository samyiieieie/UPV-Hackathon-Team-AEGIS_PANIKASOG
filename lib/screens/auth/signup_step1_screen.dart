import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_shared_widgets.dart';
import 'signup_step2_screen.dart';
import 'login_screen.dart';

class SignupStep1Screen extends StatefulWidget {
  const SignupStep1Screen({super.key});

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack('Please accept the Terms & Conditions to continue.');
      return;
    }
    context.read<AuthProvider>().saveSignupStep1(
          email: _emailCtrl.text.trim(),
          phone: '+63${_phoneCtrl.text.trim()}',
          password: _passwordCtrl.text,
        );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupStep2Screen()),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  currentStep: 1,
                  totalSteps: 2,
                  label: 'Step 1: User Profile',
                ),
                const SizedBox(height: 24),

                // ── Email ────────────────────────────────────────────────────
                AppTextField(
                  label: 'Email',
                  hint: 'e.g. juandelacruz@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!AuthService.isValidEmail(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Phone Number ─────────────────────────────────────────────
                _PhoneField(controller: _phoneCtrl),
                const SizedBox(height: 16),

                // ── Password ─────────────────────────────────────────────────
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) {
                      return 'Include at least one uppercase letter';
                    }
                    if (!RegExp(r'(?=.*\d)').hasMatch(v)) {
                      return 'Include at least one number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ──────────────────────────────────────────
                AppTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Terms checkbox ────────────────────────────────────────────
                _TermsCheckbox(
                  value: _agreedToTerms,
                  onChanged: (v) =>
                      setState(() => _agreedToTerms = v ?? false),
                ),
                const SizedBox(height: 24),

                // ── Next button ───────────────────────────────────────────────
                AppButton(
                  label: 'Next →',
                  onPressed: _next,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),

                // ── Divider ───────────────────────────────────────────────────
                const AuthOrDivider(),
                const SizedBox(height: 16),

                // ── Google ────────────────────────────────────────────────────
                AppButton(
                  label: 'Sign up with Google',
                  variant: ButtonVariant.social,
                  prefixIcon: const GoogleSignInIcon(),
                  onPressed: () => _handleGoogleSignup(),
                ),
                const SizedBox(height: 12),

                // ── Facebook ──────────────────────────────────────────────────
                AppButton(
                  label: 'Sign up with Facebook',
                  variant: ButtonVariant.social,
                  prefixIcon: const FacebookSignInIcon(),
                  onPressed: () {},
                ),
                const SizedBox(height: 24),

                // ── Login link ────────────────────────────────────────────────
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.bodySmall,
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                            child: Text(
                              'Log in',
                              style: AppTextStyles.link
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);
    final success =
        await context.read<AuthProvider>().signInWithGoogle();
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      if (error != null) _showSnack(error);
    }
  }
}

// ─── Philippine phone number field ─────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Phone Number',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppColors.borderGrey),
                ),
              ),
              child: const Text(
                '+63',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: '9123456789',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.hintGrey,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Phone number is required';
            if (v.length < 10) {
              return 'Enter a valid 10-digit mobile number';
            }
            if (!v.startsWith('9')) {
              return 'Philippine mobile starts with 9';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ─── Terms checkbox ────────────────────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'By signing up, I have read and accept the ',
              style: AppTextStyles.bodySmall,
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: AppTextStyles.link.copyWith(fontSize: 12),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Notice',
                  style: AppTextStyles.link.copyWith(fontSize: 12),
                ),
                const TextSpan(text: ' of PANIKASOG.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
