import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../core/widgets/aqarati_fee_card.dart';
import '../../data/models/enums.dart';
import '../../data/models/identity_verification.dart';
import '../../data/models/verification_models.dart';
import '../../data/repositories/app_state_providers.dart';
import '../onboarding/onboarding_preferences.dart';
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
    final onboarding = ref.watch(onboardingPreferencesProvider);
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
                    ? 'Your identity is verified.'
                    : 'Signed in with Google. Verify your identity to unlock listing and messaging.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!user.identity.isConfirmed)
            AqaratiButton(
              label: 'Verify identity',
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
          if (onboarding != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _VerificationSummaryCard(prefs: onboarding),
          ],
          if (onboarding?.serviceMode != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _ServiceModeCard(mode: onboarding!.serviceMode!),
          ],
          if (onboarding?.serviceMode == ServiceMode.selfManaged) ...[
            const SizedBox(height: AppSpacing.lg),
            _FeeDisclosureCard(),
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

/// Shows the account facts collected during onboarding — never conflates
/// email/phone verification with passport identity verification.
class _VerificationSummaryCard extends StatelessWidget {
  final OnboardingPreferences prefs;

  const _VerificationSummaryCard({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <(String, String)>[
      if (prefs.email != null) ('Email', prefs.emailVerified ? 'Verified' : 'Unverified'),
      if (prefs.phone != null) ('Phone', prefs.phoneVerified ? 'Verified' : 'Unverified'),
      if (prefs.citizenshipStatus != null) ('Status', prefs.citizenshipStatus!.label),
      ('Identity document', _passportLabel(prefs.passportState)),
      if (prefs.serviceMode != null) ('Service preference', prefs.serviceMode!.label),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
                  Text(r.$2, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _passportLabel(PassportVerificationState state) {
    switch (state) {
      case PassportVerificationState.notStarted:
        return 'Not started';
      case PassportVerificationState.uploading:
        return 'Uploading';
      case PassportVerificationState.submitted:
        return 'Submitted';
      case PassportVerificationState.pending:
        return 'Pending review';
      case PassportVerificationState.verified:
        return 'Verified';
      case PassportVerificationState.failed:
        return 'Failed';
      case PassportVerificationState.resubmissionRequired:
        return 'Resubmission required';
    }
  }
}

class _ServiceModeCard extends StatelessWidget {
  final ServiceMode mode;

  const _ServiceModeCard({required this.mode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broker = mode == ServiceMode.broker;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Aqarati mode', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(mode.label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            broker ? 'Aqarati helps manage your property journey.' : 'You manage your property journey yourself.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _FeeDisclosureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aqarati service fee', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(formatServiceFeeRate(), style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'An Aqarati service / convenience fee of ${formatServiceFeeRate()} applies to applicable completed transactions.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, alignment: Alignment.centerLeft),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How the ${formatServiceFeeRate()} fee works', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Aqarati charges a ${formatServiceFeeRate()} service / convenience fee on applicable completed transactions when this fee applies.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const AqaratiFeeCard(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('How it works'),
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
