import 'package:flutter/material.dart';
import '../../data/models/verification_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable "how the service fee works" card — reads [kAqaratiServiceFeeRate]
/// so the percentage is never hard-coded per screen. [exampleValueOmr] is
/// illustrative only, always labeled as an example, never a real quote.
class AqaratiFeeCard extends StatelessWidget {
  final double exampleValueOmr;

  const AqaratiFeeCard({super.key, this.exampleValueOmr = 125000});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = exampleValueOmr * kAqaratiServiceFeeRate;
    final total = exampleValueOmr + fee;
    String omr(double v) => 'OMR ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

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
          Text('Aqarati service / convenience fee', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(formatServiceFeeRate(), style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
          Text(
            'Applied to the applicable completed transaction.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate),
          ),
          const Divider(height: AppSpacing.xl),
          Text('Example', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.slate)),
          const SizedBox(height: AppSpacing.sm),
          _row(theme, 'Property value', omr(exampleValueOmr)),
          _row(theme, 'Aqarati fee (${formatServiceFeeRate()})', omr(fee)),
          const Divider(height: AppSpacing.lg),
          _row(theme, 'Total', omr(total), emphasize: true),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: emphasize ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium),
          Text(value, style: emphasize ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
