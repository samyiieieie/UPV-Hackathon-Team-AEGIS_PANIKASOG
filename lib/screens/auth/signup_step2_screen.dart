import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupStep2Screen extends StatefulWidget {
  const SignupStep2Screen({super.key});

  @override
  State<SignupStep2Screen> createState() => _SignupStep2ScreenState();
}

class _SignupStep2ScreenState extends State<SignupStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _prefTasksCtrl = TextEditingController();
  final List<String> _skills = [];
  final List<String> _preferredTasks = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _addressCtrl.dispose();
    _referralCtrl.dispose();
    _skillsCtrl.dispose();
    _prefTasksCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final val = _skillsCtrl.text.trim();
    if (val.isNotEmpty && !_skills.contains(val)) {
      setState(() => _skills.add(val));
      _skillsCtrl.clear();
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _addPreferredTask() {
    final val = _prefTasksCtrl.text.trim();
    if (val.isNotEmpty && !_preferredTasks.contains(val)) {
      setState(() => _preferredTasks.add(val));
      _prefTasksCtrl.clear();
    }
  }

  void _removePreferredTask(String task) {
    setState(() => _preferredTasks.remove(task));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      skills: _skills,
      preferredTasks: _preferredTasks,
      referralCode: _referralCtrl.text.trim().isEmpty ? null : _referralCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Sign up failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Complete Profile', style: AppTextStyles.h2),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(
                label: 'First Name',
                hint: 'e.g., Juan',
                controller: _firstNameCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'First name required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Last Name',
                hint: 'e.g., Dela Cruz',
                controller: _lastNameCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Last name required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Username',
                hint: 'e.g., juandc',
                controller: _usernameCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Username required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Address',
                hint: 'e.g., Brgy. Rizal, Iloilo City',
                controller: _addressCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: 16),
              _ChipInput(
                label: 'Skills (e.g., First Aid, Driving)',
                controller: _skillsCtrl,
                chips: _skills,
                onAdd: _addSkill,
                onRemove: _removeSkill,
              ),
              const SizedBox(height: 16),
              _ChipInput(
                label: 'Preferred Tasks (e.g., Cleanup, Relief)',
                controller: _prefTasksCtrl,
                chips: _preferredTasks,
                onAdd: _addPreferredTask,
                onRemove: _removePreferredTask,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Referral Code (optional)',
                hint: 'Enter code if you have one',
                controller: _referralCtrl,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Sign Up',
                onPressed: _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> chips;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  const _ChipInput({
    required this.label,
    required this.controller,
    required this.chips,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: AppTextStyles.inputText,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onAdd(),
                decoration: const InputDecoration(hintText: 'Enter a value'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: onAdd,
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips.map((chip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chip, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontSize: 12)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => onRemove(chip),
                    child: const Icon(Icons.close, size: 13, color: AppColors.primary),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}