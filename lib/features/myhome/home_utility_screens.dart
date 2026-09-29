import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../core/widgets/states.dart';
import '../../data/datasources/mock_business_data.dart';
import '../../data/models/business.dart';
import '../../data/models/enums.dart';
import '../../data/models/money.dart';
import '../../data/models/payment.dart';
import '../../data/models/property.dart';
import '../../data/repositories/providers.dart';
import '../business/business_profile_screen.dart';
import 'documents_screen.dart';

/// Shared row shown across every My Home utility screen for a consistent
/// list-of-things layout (title + subtitle + optional trailing pill).
class _UtilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _UtilityTile({required this.icon, required this.title, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
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
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
    );
  }
}

// ---------------------------------------------------------------------------
// Property
// ---------------------------------------------------------------------------

class PropertyOverviewScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyOverviewScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(propertyRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Property')),
      body: FutureBuilder<Property?>(
        future: repo.getById(propertyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AqaratiLoadingLine(label: 'Loading property...');
          final property = snapshot.data;
          if (property == null) {
            return const AqaratiEmptyState(icon: Icons.home_outlined, title: 'Property not found', message: 'This property could not be loaded.');
          }
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(property.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(property.locationLabel, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate)),
              const SizedBox(height: AppSpacing.md),
              Text(property.priceLabel, style: theme.textTheme.titleLarge?.copyWith(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.xl),
              Text('Specs', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _UtilityTile(icon: Icons.category_outlined, title: 'Type', subtitle: property.type.label),
              if (property.bedrooms != null) _UtilityTile(icon: Icons.bed_outlined, title: 'Bedrooms', subtitle: '${property.bedrooms}'),
              if (property.bathrooms != null) _UtilityTile(icon: Icons.bathtub_outlined, title: 'Bathrooms', subtitle: '${property.bathrooms}'),
              _UtilityTile(icon: Icons.straighten_outlined, title: 'Area', subtitle: '${property.areaSqm.toStringAsFixed(0)} m²'),
              const SizedBox(height: AppSpacing.lg),
              Text('Ownership', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              _UtilityTile(
                icon: Icons.description_outlined,
                title: 'Documents',
                subtitle: 'Title deed, contracts and warranties',
                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DocumentsScreen())),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Maintenance
// ---------------------------------------------------------------------------

class MaintenanceRequest {
  final String description;
  final DateTime createdAt;
  final String status;

  const MaintenanceRequest({required this.description, required this.createdAt, this.status = 'Submitted'});
}

final maintenanceRequestsProvider = StateProvider<List<MaintenanceRequest>>((ref) => []);

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  void _requestMaintenance(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.lg + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request maintenance', style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Describe the issue'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AqaratiButton(
              label: 'Submit request',
              fullWidth: true,
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                ref.read(maintenanceRequestsProvider.notifier).update(
                      (state) => [MaintenanceRequest(description: controller.text.trim(), createdAt: DateTime.now()), ...state],
                    );
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance request submitted')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(maintenanceRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: requests.isEmpty
          ? AqaratiEmptyState(
              icon: Icons.build_outlined,
              title: 'No maintenance requests',
              message: 'Request a repair or service and track it here.',
              ctaLabel: 'Request maintenance',
              onCta: () => _requestMaintenance(context, ref),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final r in requests)
                  _UtilityTile(
                    icon: Icons.build_outlined,
                    title: r.description,
                    subtitle: '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                    trailing: _StatusPill(label: r.status, color: AppColors.pending),
                  ),
                const SizedBox(height: AppSpacing.md),
                AqaratiButton(label: 'Request maintenance', fullWidth: true, onPressed: () => _requestMaintenance(context, ref)),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expenses
// ---------------------------------------------------------------------------

class ExpenseEntry {
  final String label;
  final Money amount;
  final DateTime date;

  const ExpenseEntry({required this.label, required this.amount, required this.date});
}

final expensesProvider = Provider<List<ExpenseEntry>>((ref) => [
      ExpenseEntry(label: 'Monthly rent', amount: const Money(650), date: DateTime.now().subtract(const Duration(days: 3))),
      ExpenseEntry(label: 'Electricity bill', amount: const Money(38), date: DateTime.now().subtract(const Duration(days: 10))),
      ExpenseEntry(label: 'Water bill', amount: const Money(12), date: DateTime.now().subtract(const Duration(days: 10))),
    ]);

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expenses.isEmpty
          ? const AqaratiEmptyState(icon: Icons.receipt_long_outlined, title: 'No expenses yet', message: 'Spending on this home will show up here.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Total this period', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.slate)),
                Text(Money(total).formatted, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppSpacing.lg),
                for (final e in expenses)
                  _UtilityTile(icon: Icons.receipt_long_outlined, title: e.label, subtitle: '${e.date.day}/${e.date.month}/${e.date.year}', trailing: Text(e.amount.formatted)),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Renovations
// ---------------------------------------------------------------------------

class RenovationProject {
  final String title;
  final String status;

  const RenovationProject({required this.title, required this.status});
}

final renovationsProvider = Provider<List<RenovationProject>>((ref) => []);

class RenovationsScreen extends ConsumerWidget {
  const RenovationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(renovationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Renovations')),
      body: projects.isEmpty
          ? AqaratiEmptyState(
              icon: Icons.brush_outlined,
              title: 'No renovation projects',
              message: 'Plan and track improvement projects for this home.',
              ctaLabel: 'Start a project',
              onCta: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renovation planning is not built yet'))),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final p in projects) _UtilityTile(icon: Icons.brush_outlined, title: p.title, subtitle: p.status),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payments
// ---------------------------------------------------------------------------

final homePaymentsProvider = Provider<List<Payment>>((ref) => [
      Payment(
        id: 'pay1',
        contextTitle: 'Monthly rent — Al Khoudh Villa',
        amount: const Money(650),
        aqaratiFee: const Money(0),
        paymentMethodLabel: 'Visa •••• 4421',
        status: PaymentStatus.succeeded,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Payment(
        id: 'pay2',
        contextTitle: 'Service fee',
        amount: const Money(25),
        aqaratiFee: const Money(0.5),
        paymentMethodLabel: 'Visa •••• 4421',
        status: PaymentStatus.succeeded,
        createdAt: DateTime.now().subtract(const Duration(days: 33)),
      ),
    ]);

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  Color _statusColor(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.succeeded:
        return AppColors.verified;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return AppColors.pending;
      case PaymentStatus.failed:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(homePaymentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: payments.isEmpty
          ? const AqaratiEmptyState(icon: Icons.payments_outlined, title: 'No payments yet', message: 'Rent, service fees and receipts will appear here.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final p in payments)
                  _UtilityTile(
                    icon: Icons.payments_outlined,
                    title: p.contextTitle,
                    subtitle: '${p.paymentMethodLabel} · ${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.total.formatted, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        _StatusPill(label: p.status.name, color: _statusColor(p.status)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Providers (professionals you have worked with)
// ---------------------------------------------------------------------------

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = mockBusinesses.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Providers')),
      body: providers.isEmpty
          ? const AqaratiEmptyState(icon: Icons.groups_outlined, title: 'No providers yet', message: 'Professionals you work with will appear here.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final Business b in providers)
                  _UtilityTile(
                    icon: Icons.groups_outlined,
                    title: b.name,
                    subtitle: b.categories.isNotEmpty ? b.categories.first.label : b.locationLabel,
                    trailing: Icon(Icons.chevron_right_rounded, color: AppColors.mist),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => BusinessProfileScreen(businessId: b.id))),
                  ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Warranty
// ---------------------------------------------------------------------------

class WarrantyItem {
  final String label;
  final DateTime expires;

  const WarrantyItem({required this.label, required this.expires});
}

final warrantiesProvider = Provider<List<WarrantyItem>>((ref) => [
      WarrantyItem(label: 'Air conditioning unit', expires: DateTime.now().add(const Duration(days: 420))),
      WarrantyItem(label: 'Structural warranty', expires: DateTime.now().add(const Duration(days: 1800))),
    ]);

class WarrantyScreen extends ConsumerWidget {
  const WarrantyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warranties = ref.watch(warrantiesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Warranty')),
      body: warranties.isEmpty
          ? const AqaratiEmptyState(icon: Icons.verified_outlined, title: 'No warranties on file', message: 'Appliance and structural warranties will appear here.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final w in warranties)
                  _UtilityTile(
                    icon: Icons.verified_outlined,
                    title: w.label,
                    subtitle: 'Expires ${w.expires.day}/${w.expires.month}/${w.expires.year}',
                  ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

class HistoryEvent {
  final String label;
  final DateTime date;

  const HistoryEvent({required this.label, required this.date});
}

final homeHistoryProvider = Provider<List<HistoryEvent>>((ref) => [
      HistoryEvent(label: 'Home added to Aqarati', date: DateTime.now().subtract(const Duration(days: 40))),
      HistoryEvent(label: 'Maintenance requested', date: DateTime.now().subtract(const Duration(days: 20))),
      HistoryEvent(label: 'Rent payment received', date: DateTime.now().subtract(const Duration(days: 3))),
    ]);

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(homeHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: events.isEmpty
          ? const AqaratiEmptyState(icon: Icons.history_rounded, title: 'Nothing yet', message: 'Everything that happens here will show up in this timeline.')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final e in events) _UtilityTile(icon: Icons.history_rounded, title: e.label, subtitle: '${e.date.day}/${e.date.month}/${e.date.year}'),
              ],
            ),
    );
  }
}
