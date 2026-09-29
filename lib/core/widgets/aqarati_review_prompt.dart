import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../data/repositories/app_state_providers.dart';
import 'aqarati_button.dart';

const _kSeenKey = 'aqarati_review_prompt_seen';
const _kCompletedKey = 'aqarati_review_prompt_completed';

/// Shows the "How are you finding Aqarati?" prompt at most once, the first
/// time Home is entered after onboarding has been completed with at least
/// one answer given (a light proxy for "meaningful engagement" — no
/// per-screen-view tracking exists yet to gate on something more specific).
///
/// NOTE: this app targets web in this build. There is no App Store / Play
/// Store to open a real platform review in — "Leave a review" is honest
/// about that rather than pretending a native review sheet was shown.
Future<void> maybeShowReviewPrompt(BuildContext context, WidgetRef ref) async {
  final onboarding = ref.read(onboardingPreferencesProvider);
  if (onboarding == null || !onboarding.hasAnyAnswer) return;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kSeenKey) == true) return;
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
    builder: (sheetContext) => _ReviewPromptSheet(prefs: prefs),
  );
}

class _ReviewPromptSheet extends StatelessWidget {
  final SharedPreferences prefs;

  const _ReviewPromptSheet({required this.prefs});

  Future<void> _dismiss(BuildContext context) async {
    await prefs.setBool(_kSeenKey, true);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _leaveReview(BuildContext context) async {
    await prefs.setBool(_kSeenKey, true);
    await prefs.setBool(_kCompletedKey, true);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you! App Store / Play Store review isn't available in this web build.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you finding Aqarati?', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your feedback helps us make property search simpler for everyone.',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (_) => const Icon(Icons.star_rounded, color: AppColors.primary, size: 32)),
          ),
          const SizedBox(height: AppSpacing.xl),
          AqaratiButton(label: 'Leave a review', fullWidth: true, onPressed: () => _leaveReview(context)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () => _dismiss(context), child: const Text('Maybe later')),
              TextButton(onPressed: () => _dismiss(context), child: const Text('Not now')),
            ],
          ),
        ],
      ),
    );
  }
}
