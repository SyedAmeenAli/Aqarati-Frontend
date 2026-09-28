import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/enums.dart';
import '../../data/models/identity_verification.dart';
import '../../data/repositories/app_state_providers.dart';
import '../../features/enquiry/my_enquiries_screen.dart';
import '../../features/myhome/my_home_screen.dart';
import '../../features/owner/owner_dashboard_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/settings/account_switch_screen.dart';
import '../../features/settings/help_support_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/verification/identity_verification_flow.dart';
import '../../features/verification/verification_center_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Left-side navigation drawer — colored header + expandable sections,
/// modeled on the NoBroker sidebar (header with sign-in/CTA, then grouped
/// accordion sections) but wired only to AQARATI's own real screens.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Drawer(
      backgroundColor: AppColors.surface,
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(user: user),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerGroup(
                    title: 'Buying & Renting',
                    icon: Icons.home_work_outlined,
                    children: [
                      _DrawerTile(
                        icon: Icons.favorite_border_rounded,
                        label: 'Saved properties',
                        onTap: () => _push(context, const SavedScreen()),
                      ),
                      _DrawerTile(
                        icon: Icons.forum_outlined,
                        label: 'My enquiries, offers & viewings',
                        onTap: () => _push(context, const MyEnquiriesScreen()),
                      ),
                      _DrawerTile(
                        icon: Icons.house_outlined,
                        label: 'My Home',
                        onTap: () => _push(context, const MyHomeScreen()),
                      ),
                    ],
                  ),
                  _DrawerGroup(
                    title: 'For Professionals & Owners',
                    icon: Icons.apartment_rounded,
                    children: [
                      _DrawerTile(
                        icon: Icons.dashboard_outlined,
                        label: 'Owner Dashboard',
                        onTap: () => _push(context, const OwnerDashboardScreen()),
                      ),
                      _DrawerTile(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Switch Account (Personal / Business)',
                        onTap: () => _push(context, const AccountSwitchScreen()),
                      ),
                    ],
                  ),
                  _DrawerGroup(
                    title: 'Trust & Identity',
                    icon: Icons.verified_user_outlined,
                    children: [
                      _DrawerTile(
                        icon: Icons.verified_outlined,
                        label: 'Verification Centre',
                        onTap: () => _push(context, const VerificationCenterScreen()),
                      ),
                    ],
                  ),
                  _DrawerGroup(
                    title: 'Support',
                    icon: Icons.help_outline_rounded,
                    initiallyExpanded: false,
                    children: [
                      _DrawerTile(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => _push(context, const SettingsScreen()),
                      ),
                      _DrawerTile(
                        icon: Icons.support_agent_outlined,
                        label: 'Help & Support Centre',
                        onTap: () => _push(context, const HelpSupportScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => screen));
  }
}

class _DrawerHeader extends ConsumerWidget {
  final User user;

  const _DrawerHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_outline, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.isGuest ? "You're browsing as a guest" : user.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (user.isGuest)
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                final verified = await Navigator.of(context, rootNavigator: true).push<bool>(
                  MaterialPageRoute(builder: (context) => const IdentityVerificationFlow()),
                );
                if (verified == true) {
                  ref.read(currentUserProvider.notifier).state = User(
                    id: 'u1',
                    name: 'Faisal Al-Said',
                    identity: IdentityVerification(status: VerificationStatus.verified, method: 'qr', confirmedAt: DateTime.now()),
                  );
                }
              },
              child: Text(
                'Continue with THEQA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, decoration: TextDecoration.underline),
              ),
            )
          else
            Text(
              'Verified via THEQA',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _DrawerGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _DrawerGroup({required this.title, required this.icon, required this.children, this.initiallyExpanded = true});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        childrenPadding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: AppSpacing.xxl, right: AppSpacing.lg),
      leading: Icon(icon, size: AppIconSize.sm, color: AppColors.slate),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
