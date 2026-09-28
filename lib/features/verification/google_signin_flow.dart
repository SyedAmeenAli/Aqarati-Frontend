import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Google sign-in as a second option alongside THEQA. No real Google OAuth
/// client is configured (no backend yet) — this mirrors
/// IdentityVerificationFlow's own honesty pattern: real frontend states,
/// a picked mock account, ready to wire to real `google_sign_in` /
/// Firebase Auth once a backend exists. Never claims a real Google session.
class GoogleSignInFlow extends StatefulWidget {
  const GoogleSignInFlow({super.key});

  @override
  State<GoogleSignInFlow> createState() => _GoogleSignInFlowState();
}

class _GoogleSignInFlowState extends State<GoogleSignInFlow> {
  bool _signingIn = false;

  Future<void> _signIn(String name) async {
    setState(() => _signingIn = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with Google')),
      body: _signingIn
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose an account', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text('to continue to AQARATI', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  _AccountTile(
                    name: 'Faisal Al-Said',
                    email: 'faisal.alsaid@gmail.com',
                    onTap: () => _signIn('Faisal Al-Said'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _AccountTile(
                    icon: Icons.add_circle_outline,
                    name: 'Use another account',
                    email: '',
                    onTap: () => _signIn('Faisal Al-Said'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;
  final IconData? icon;

  const _AccountTile({required this.name, required this.email, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.sand,
              child: icon != null
                  ? Icon(icon, color: AppColors.slate)
                  : Text(name.isNotEmpty ? name[0] : '?', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall),
                  if (email.isNotEmpty) Text(email, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
