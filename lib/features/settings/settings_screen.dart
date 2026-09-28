import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/identity_verification.dart';
import '../../data/repositories/app_state_providers.dart';
import 'privacy_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'notification_prefs_screen.dart';
import 'account_switch_screen.dart';
import 'preferences_screen.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import '../verification/verification_center_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Account Configuration', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.badge_outlined, title: 'Profile Information', trailingText: 'Faisal Al-Said', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            )),
            _SettingsRow(icon: Icons.phone_outlined, title: 'Omani Phone Number', trailingText: '+968 9123 4567', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen(initialFocus: EditProfileFocus.phone)),
            )),
            _SettingsRow(icon: Icons.swap_horiz_rounded, title: 'Account Type', trailingText: 'Premium Landlord', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountSwitchScreen()),
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('Identity & Security', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.verified_user_outlined, title: 'THEQA Digital Identity', trailingText: 'Connected', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const VerificationCenterScreen()),
            )),
            _SettingsRow(icon: Icons.security_rounded, title: 'Security & PIN', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            )),
            _SettingsRow(icon: Icons.devices_other_outlined, title: 'Active Device Sessions', trailingText: 'Muscat, Oman', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SecurityScreen()),
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('App Preferences', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.language_rounded, title: 'Ecosystem Language', trailingText: 'English', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PreferencesScreen()),
            )),
            _SettingsRow(icon: Icons.notifications_active_outlined, title: 'Instant Notifications', trailingText: 'Active', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NotificationPrefsScreen()),
            )),
            _SettingsRow(icon: Icons.accessibility_new_rounded, title: 'Accessibility Controls', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PreferencesScreen()),
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('Privacy & Data', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.privacy_tip_outlined, title: 'Ecosystem Privacy', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            )),
            _SettingsRow(icon: Icons.file_download_outlined, title: 'Data Export & Portability', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacyScreen()),
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('Ecosystem Support', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.help_outline_rounded, title: 'Help & Support Center', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
            )),
            _SettingsRow(icon: Icons.report_gmailerrorred_outlined, title: 'Report a Technical Problem', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpSupportScreen(initialTab: 2)),
            )),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('About AQARATI', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _SettingsGroup(children: [
            _SettingsRow(icon: Icons.info_outline_rounded, title: 'About App & Version', trailingText: 'v3.40 (Oman)', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            )),
            _SettingsRow(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            )),
            _SettingsRow(icon: Icons.policy_outlined, title: 'Privacy & Cookie Policy', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            )),
            _SettingsRow(icon: Icons.gavel_outlined, title: 'Royal Decrees & Licenses', onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            )),
          ]),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.red200),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => _confirmSignOut(context, ref),
            child: const Text('Sign Out Account'),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out? You can sign in again whenever you\'re ready.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(currentUserProvider.notifier).state = User.guest;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Sign Out Account'),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: AppColors.surface,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const Divider(height: 1, indent: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsRow({required this.icon, required this.title, this.trailingText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
          Icon(Icons.chevron_right_rounded, color: AppColors.mist),
        ],
      ),
      onTap: onTap,
    );
  }
}
