import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../data/models/enums.dart';
import '../../data/models/money.dart';
import '../../data/models/property.dart';
import '../../data/models/verification_models.dart';
import '../../data/repositories/app_state_providers.dart';

class MakeOfferScreen extends ConsumerStatefulWidget {
  final Property property;

  const MakeOfferScreen({super.key, required this.property});

  @override
  ConsumerState<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends ConsumerState<MakeOfferScreen> {
  final _priceController = TextEditingController();
  bool _agreedTerms = false;
  bool _submitted = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _priceController.text.trim().isNotEmpty && _agreedTerms;

  double get _offerAmount => double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Make an Offer')),
      body: _submitted ? _buildSuccess(theme) : _buildForm(theme),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.property.title, style: theme.textTheme.titleLarge),
          Text('Listed at ${widget.property.priceLabel}', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Text('YOUR OFFER PRICE (OMR)', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'OMR ', hintText: 'e.g. 175,000'),
            onChanged: (_) => setState(() {}),
          ),
          if (_offerAmount > 0 && ref.watch(onboardingPreferencesProvider)?.serviceMode == ServiceMode.selfManaged) ...[
            const SizedBox(height: AppSpacing.lg),
            _FeePreview(offerAmount: _offerAmount),
          ],
          const SizedBox(height: AppSpacing.xl),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            value: _agreedTerms,
            onChanged: (v) => setState(() => _agreedTerms = v ?? false),
            title: const Text('I understand this offer is not binding until accepted by the owner.'),
          ),
          const SizedBox(height: AppSpacing.xl),
          AqaratiButton(
            label: 'Submit offer',
            fullWidth: true,
            onPressed: _canSubmit
                ? () {
                    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;
                    ref.read(offersProvider.notifier).update((state) => [
                          ...state,
                          PropertyOffer(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            propertyId: widget.property.id,
                            propertyTitle: widget.property.title,
                            offerPrice: Money(price),
                            status: QuoteStatus.pending,
                            createdAt: DateTime.now(),
                          ),
                        ]);
                    setState(() => _submitted = true);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          Text('Offer submitted', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We've sent your offer to the listing owner. You'll be notified when they respond.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AqaratiButton(label: 'Back to listing', fullWidth: true, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

/// Live fee preview shown while entering an offer — only for DIY
/// (self-managed) users, since the 2% service/convenience fee applies to
/// the applicable completed transaction when Aqarati is not brokering it.
class _FeePreview extends StatelessWidget {
  final double offerAmount;

  const _FeePreview({required this.offerAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fee = offerAmount * kAqaratiServiceFeeRate;
    final total = offerAmount + fee;
    String omr(double v) => 'OMR ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('If this offer completes', style: theme.textTheme.labelMedium?.copyWith(color: AppColors.slate)),
          const SizedBox(height: AppSpacing.xs),
          _row(theme, 'Offer amount', omr(offerAmount)),
          _row(theme, 'Aqarati service / convenience fee (${formatServiceFeeRate()})', omr(fee)),
          const Divider(height: AppSpacing.md),
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
          Expanded(child: Text(label, style: emphasize ? theme.textTheme.titleSmall : theme.textTheme.bodySmall)),
          Text(value, style: emphasize ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
