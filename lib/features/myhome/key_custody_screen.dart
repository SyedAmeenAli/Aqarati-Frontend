import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../core/widgets/states.dart';
import '../../data/models/verification_models.dart';
import '../../data/repositories/app_state_providers.dart';
import '../onboarding/onboarding_preferences.dart';

/// My Home's Key Custody section — shows the deposit set up during
/// onboarding (if any) and lets the owner request the keys back.
class KeyCustodyScreen extends ConsumerWidget {
  const KeyCustodyScreen({super.key});

  Future<void> _confirmReturn(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return my keys'),
        content: const Text('Are you sure you want to request the return of this key set?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Request return')),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(keyCustodyStateProvider.notifier).state = KeyCustodyState.returnRequested;
    Timer(const Duration(seconds: 2), () {
      ref.read(keyCustodyStateProvider.notifier).state = KeyCustodyState.returned;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(onboardingPreferencesProvider);
    final state = ref.watch(keyCustodyStateProvider);
    final theme = Theme.of(context);

    if (state == KeyCustodyState.notRequested) {
      return Scaffold(
        appBar: AppBar(title: const Text('Key custody')),
        body: const AqaratiEmptyState(
          icon: Icons.key_outlined,
          title: 'No keys deposited',
          message: 'Set up a key deposit from the Aqarati Broker onboarding path to let Aqarati coordinate viewings on your behalf.',
        ),
      );
    }

    final canReturn = state == KeyCustodyState.inCustody || state == KeyCustodyState.reserved || state == KeyCustodyState.awaitingHandover;

    return Scaffold(
      appBar: AppBar(title: const Text('Key custody')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prefs?.keySetPropertyName?.isNotEmpty == true ? prefs!.keySetPropertyName! : 'Property', style: theme.textTheme.titleMedium),
                    _StatusPill(state: state),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _row(theme, 'Key set', prefs?.keySetName ?? '—'),
                _row(theme, 'Number of keys', prefs?.keySetCount?.toString() ?? '—'),
                _row(theme, 'Handover method', prefs?.keyHandoverMethod?.label ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Timeline', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Demo timeline — not real account events.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
          const SizedBox(height: AppSpacing.md),
          _TimelineEntry(date: 'Today', label: 'Key deposit requested'),
          if (state != KeyCustodyState.awaitingHandover) ...[
            _TimelineEntry(date: 'Today', label: 'Keys received by Aqarati'),
          ],
          if (state == KeyCustodyState.returnRequested || state == KeyCustodyState.returned)
            _TimelineEntry(date: 'Today', label: 'Return requested'),
          if (state == KeyCustodyState.returned) _TimelineEntry(date: 'Today', label: 'Keys returned', isLast: true),
          const SizedBox(height: AppSpacing.xl),
          if (canReturn)
            AqaratiButton(label: 'Return my keys', fullWidth: true, onPressed: () => _confirmReturn(context, ref))
          else if (state == KeyCustodyState.returnRequested)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (state == KeyCustodyState.returned)
            Text('Keys returned. Thank you.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final KeyCustodyState state;

  const _StatusPill({required this.state});

  @override
  Widget build(BuildContext context) {
    final done = state == KeyCustodyState.returned || state == KeyCustodyState.completed;
    final color = done ? AppColors.verified : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(state.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final String date;
  final String label;
  final bool isLast;

  const _TimelineEntry({required this.date, required this.label, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(isLast ? Icons.check_circle_rounded : Icons.circle, size: isLast ? 18 : 10, color: AppColors.primary),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(date, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
