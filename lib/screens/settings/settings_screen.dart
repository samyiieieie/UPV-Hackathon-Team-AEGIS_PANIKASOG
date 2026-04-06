import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Settings', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Account', style: AppTextStyles.labelMedium),
                ),
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Privacy & Security',
                      style: AppTextStyles.labelMedium),
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _launchURL('https://your-privacy-policy-url.com'),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Terms of Service',
                  onTap: () => _launchURL('https://your-terms-url.com'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('App', style: AppTextStyles.labelMedium),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () => _showAboutDialog(context),
                ),
                _SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  onTap: () => _showBugReportDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/landing');
                            }
                          },
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

void _showChangePasswordDialog(BuildContext context) {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current Password'),
          ),
          TextField(
            controller: newCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          TextField(
            controller: confirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (newCtrl.text != confirmCtrl.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }
            try {
              await AuthService().changePassword(
                currentPassword: oldCtrl.text,
                newPassword: newCtrl.text,
              );
              // Use mounted check with the dialog context
              if (Navigator.of(context).mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully!')),
                );
              }
            } catch (e) {
              if (Navigator.of(context).mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            }
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PANIKASOG',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.warning_amber_rounded,
          color: AppColors.primary),
      children: const [
        Text(
            'PANIKASOG is a community disaster response and volunteer platform.'),
      ],
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report a Bug'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration:
              const InputDecoration(hintText: 'Describe the bug...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Thank you! Bug report submitted.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.hintGrey, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}