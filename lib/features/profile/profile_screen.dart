import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../data/models/enums.dart';
import '../../data/models/identity_verification.dart';
import '../../data/repositories/app_state_providers.dart';
import '../calculators/calculators_list_screen.dart';
import '../enquiry/my_enquiries_screen.dart';
import '../myhome/my_home_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../verification/google_signin_flow.dart';
import '../verification/identity_verification_flow.dart';
import '../verification/verification_center_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/account_switch_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.sand,
            child: Icon(Icons.person_outline, color: AppColors.slate, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(user.isGuest ? "You're browsing as a guest" : user.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            user.isGuest
                ? 'Sign in to save properties, message professionals and manage your home.'
                : user.identity.isConfirmed
                    ? 'Verified via THEQA — Oman national digital identity.'
                    : 'Signed in with Google. Verify with THEQA to unlock listing and messaging.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!user.identity.isConfirmed)
            AqaratiButton(
              label: 'Continue with THEQA',
              icon: Icons.fingerprint_rounded,
              fullWidth: true,
              onPressed: () async {
                final verified = await Navigator.of(context, rootNavigator: true).push<bool>(
                  MaterialPageRoute(builder: (context) => const IdentityVerificationFlow()),
                );
                if (verified == true) {
                  ref.read(currentUserProvider.notifier).signIn(User(
                    id: 'u1',
                    name: 'Faisal Al-Said',
                    identity: IdentityVerification(
                      status: VerificationStatus.verified,
                      method: 'qr',
                      confirmedAt: DateTime.now(),
                    ),
                  ));
                }
              },
            ),
          if (user.isGuest) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                final name = await Navigator.of(context, rootNavigator: true).push<String>(
                  MaterialPageRoute(builder: (context) => const GoogleSignInFlow()),
                );
                if (name != null) {
                  ref.read(currentUserProvider.notifier).signIn(User(
                    id: 'u2',
                    name: name,
                    identity: const IdentityVerification(status: VerificationStatus.unverified),
                  ));
                }
              },
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            label: 'Saved properties',
            onTap: () => context.push('/saved'),
          ),
          _MenuTile(
            icon: Icons.forum_outlined,
            label: 'My enquiries, offers & viewings',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const MyEnquiriesScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.house_outlined,
            label: 'My Home',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const MyHomeScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.calculate_outlined,
            label: 'Property tools',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const CalculatorsListScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.verified_outlined,
            label: 'Verification Centre',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const VerificationCenterScreen()),
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          Text('FOR PROFESSIONALS & OWNERS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          _MenuTile(
            icon: Icons.dashboard_outlined,
            label: 'Owner Dashboard',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch Account (Personal / Business)',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const AccountSwitchScreen()),
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
