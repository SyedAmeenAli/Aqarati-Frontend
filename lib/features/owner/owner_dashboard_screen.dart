import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/states.dart';
import '../../core/widgets/verification_badge.dart';
import '../../data/models/enums.dart';
import '../verification/verification_center_screen.dart';
import 'owner_mock_data.dart';
import 'owner_state.dart';
import 'property_creation_flow.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(ownerListingsProvider);
    final enquiries = ref.watch(ownerEnquiriesProvider);
    final bookings = ref.watch(ownerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slate,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Properties'),
            Tab(text: 'Enquiries'),
            Tab(text: 'Viewings'),
            Tab(text: 'Verification'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PropertyCreationFlow()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add property', style: TextStyle(color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(listings: listings, enquiries: enquiries, bookings: bookings),
          listings.isEmpty
              ? const AqaratiEmptyState(
                  icon: Icons.home_work_outlined,
                  title: 'No properties listed yet',
                  message: 'Add your first property to start reaching buyers.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: listings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final p = listings[i];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.title, style: Theme.of(context).textTheme.titleSmall),
                                Text(p.priceLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                          VerificationBadge(status: p.verification.status),
                        ],
                      ),
                    );
                  },
                ),
          enquiries.isEmpty
              ? const AqaratiEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No enquiries yet',
                  message: 'Buyer enquiries about your listings will show up here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: enquiries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final e = enquiries[enquiries.length - 1 - i];
                    return _SimpleTile(title: e.propertyTitle, subtitle: e.message);
                  },
                ),
          bookings.isEmpty
              ? const AqaratiEmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'No viewings scheduled',
                  message: 'Confirmed viewings for your properties appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final b = bookings[bookings.length - 1 - i];
                    return _SimpleTile(title: b.contextTitle, subtitle: '${b.date.day}/${b.date.month} · ${b.timeSlotLabel}');
                  },
                ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify your identity and properties to build buyer trust.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const VerificationCenterScreen()),
                  ),
                  child: const Text('Open Verification Centre'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final List<dynamic> listings;
  final List<dynamic> enquiries;
  final List<dynamic> bookings;

  const _OverviewTab({required this.listings, required this.enquiries, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusCounts = <VerificationStatus, int>{};
    for (final p in listings) {
      final status = p.verification.status as VerificationStatus;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Expanded(child: _StatTile(label: 'Listings', value: '${listings.length}', icon: Icons.home_work_outlined)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatTile(label: 'Enquiries', value: '${enquiries.length}', icon: Icons.forum_outlined)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _StatTile(label: 'Viewings', value: '${bookings.length}', icon: Icons.event_available_outlined)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Views this week', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.line),
          ),
          child: _ViewsTrendChart(dailyViews: ownerMockDailyViews),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Listing verification status', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.line),
          ),
          child: listings.isEmpty
              ? Text('No listings yet.', style: theme.textTheme.bodyMedium)
              : Column(
                  children: VerificationStatus.values
                      .where((s) => statusCounts.containsKey(s))
                      .map((s) => _StatusBarRow(status: s, count: statusCounts[s]!, total: listings.length))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Icon(icon, color: AppColors.primary, size: AppIconSize.sm),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: theme.textTheme.headlineSmall),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
        ],
      ),
    );
  }
}

/// Single-series trend — one hue (brand primary), thin line, recessive
/// gridlines, no dual axis. A single series needs no legend — the title
/// above it already names it.
class _ViewsTrendChart extends StatelessWidget {
  final List<double> dailyViews;

  const _ViewsTrendChart({required this.dailyViews});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxY = (dailyViews.reduce((a, b) => a > b ? a : b) * 1.25).ceilToDouble();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: AppColors.mist, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_dayLabels[i], style: TextStyle(color: AppColors.mist, fontSize: 10)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.charcoal,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem('${s.y.toInt()} views', const TextStyle(color: Colors.white, fontSize: 12)))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < dailyViews.length; i++) FlSpot(i.toDouble(), dailyViews[i])],
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}

/// Status is reserved semantics, not a fourth categorical color — verified
/// (green), under review (amber), needs attention (red), each with a
/// label + count, never color alone.
class _StatusBarRow extends StatelessWidget {
  final VerificationStatus status;
  final int count;
  final int total;

  const _StatusBarRow({required this.status, required this.count, required this.total});

  Color get _color {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.verified;
      case VerificationStatus.underReview:
        return AppColors.underReview;
      case VerificationStatus.needsAttention:
        return AppColors.needsAttention;
      case VerificationStatus.unverified:
        return AppColors.unverified;
      case VerificationStatus.submitted:
        return AppColors.underReview;
    }
  }

  String get _label {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.underReview:
        return 'Under review';
      case VerificationStatus.needsAttention:
        return 'Needs attention';
      case VerificationStatus.unverified:
        return 'Unverified';
      case VerificationStatus.submitted:
        return 'Submitted';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(_label, style: theme.textTheme.bodySmall),
                ],
              ),
              Text('$count', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SimpleTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
