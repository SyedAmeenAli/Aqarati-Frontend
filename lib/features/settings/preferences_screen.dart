import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/widgets/aqarati_button.dart';
import 'notification_prefs_screen.dart';
import 'privacy_screen.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String _textSize = 'Default';
  bool _reduceMotion = false;
  String _locationAccess = 'While Using';

  void _pickLocationAccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['While Using', 'Always', 'Never']
              .map((option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _locationAccess,
                    onChanged: (v) {
                      setState(() => _locationAccess = v!);
                      Navigator.of(sheetContext).pop();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Preferences', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Tailor your Omani real estate search', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Text('LANGUAGE', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mist)),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.language_rounded,
            title: 'App Language',
            trailing: locale.languageCode == 'ar' ? 'العربية' : 'English',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const _LanguageScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('DISPLAY & ACCESSIBILITY', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mist)),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.text_fields_rounded,
            title: 'Text Size',
            trailing: _textSize,
            onTap: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (context) => _TextSizeScreen(current: _textSize)),
              );
              if (result != null) setState(() => _textSize = result);
            },
          ),
          _Row(
            icon: Icons.visibility_outlined,
            title: 'Appearance',
            trailing: switch (themeMode) {
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
              ThemeMode.system => 'System',
            },
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const _AppearanceScreen()),
            ),
          ),
          _ToggleTile(
            icon: Icons.accessibility_new_rounded,
            title: 'Reduce Motion',
            subtitle: 'Limit animations across maps & galleries',
            value: _reduceMotion,
            onChanged: (v) => setState(() => _reduceMotion = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('PERMISSIONS & PRIVACY', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mist)),
          const SizedBox(height: AppSpacing.sm),
          _Row(icon: Icons.notifications_none_rounded, title: 'Notification Settings', onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NotificationPrefsScreen()),
          )),
          _Row(
            icon: Icons.location_on_outlined,
            title: 'Location (Oman Maps)',
            trailing: _locationAccess,
            onTap: () => _pickLocationAccess(context),
          ),
          _Row(icon: Icons.shield_outlined, title: 'Privacy Settings', onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PrivacyScreen()),
          )),
        ],
      ),
    );
  }
}

class _LanguageScreen extends ConsumerWidget {
  const _LanguageScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _LanguageOption(
            label: 'English',
            subtitle: 'App standard interface',
            selected: locale.languageCode == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          const SizedBox(height: AppSpacing.md),
          _LanguageOption(
            label: 'العربية',
            subtitle: 'الواجهة القياسية لعقاراتي',
            selected: locale.languageCode == 'ar',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: AppIconSize.compact, color: AppColors.slate),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Applies instantly — layout mirrors automatically for Arabic.', style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.subtitle, required this.selected, required this.onTap});

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
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? AppBorder.strong : AppBorder.thin),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleSmall),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? AppColors.primary : AppColors.mist),
          ],
        ),
      ),
    );
  }
}

class _TextSizeScreen extends StatefulWidget {
  final String current;

  const _TextSizeScreen({required this.current});

  @override
  State<_TextSizeScreen> createState() => _TextSizeScreenState();
}

class _TextSizeScreenState extends State<_TextSizeScreen> {
  static const _sizes = ['Small', 'Default', 'Medium', 'Large'];
  late int _index = _sizes.indexOf(widget.current).clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = 0.85 + (_index * 0.15);
    return Scaffold(
      appBar: AppBar(title: const Text('Text Size')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Adjust typography scale for comfortable browsing', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.line)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PREVIEW CARD', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mist)),
                const SizedBox(height: AppSpacing.sm),
                Text('Luxury Villa in Al Mouj, Muscat', style: theme.textTheme.titleLarge?.copyWith(fontSize: (theme.textTheme.titleLarge?.fontSize ?? 22) * scale)),
                const SizedBox(height: 4),
                Text(
                  'Featuring breathtaking ocean views and modern Omani architectural highlights.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * scale),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A', style: TextStyle(fontSize: 14, color: AppColors.mist)),
              Text('Drag slider below', style: theme.textTheme.titleSmall),
              Text('A', style: TextStyle(fontSize: 22, color: AppColors.mist)),
            ],
          ),
          Slider(
            value: _index.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _index = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sizes.map((s) => Text(s, style: theme.textTheme.labelSmall)).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _index = 1),
              icon: const Icon(Icons.refresh_rounded, size: AppIconSize.compact),
              label: const Text('Reset to Default Size'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AqaratiButton(label: 'Save', fullWidth: true, onPressed: () => Navigator.of(context).pop(_sizes[_index])),
        ],
      ),
    );
  }
}

class _AppearanceScreen extends ConsumerWidget {
  const _AppearanceScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Choose your primary viewing preference — applies instantly.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _AppearanceOption(
                label: 'Light',
                icon: Icons.wb_sunny_outlined,
                selected: mode == ThemeMode.light,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
              ),
              const SizedBox(width: AppSpacing.md),
              _AppearanceOption(
                label: 'Dark',
                icon: Icons.nightlight_outlined,
                selected: mode == ThemeMode.dark,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
              ),
              const SizedBox(width: AppSpacing.md),
              _AppearanceOption(
                label: 'System',
                icon: Icons.smartphone_rounded,
                selected: mode == ThemeMode.system,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('PREVIEW', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mist)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            alignment: Alignment.bottomLeft,
            child: Text('Earthy Interior', style: theme.textTheme.titleSmall?.copyWith(color: isDark ? Colors.white : AppColors.ink, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceOption({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? AppBorder.strong : AppBorder.thin),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.slate),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, size: AppIconSize.compact, color: selected ? AppColors.primary : AppColors.mist),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _Row({required this.icon, required this.title, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
          Icon(Icons.chevron_right_rounded, color: AppColors.mist),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch(value: value, activeColor: AppColors.primary, onChanged: onChanged),
    );
  }
}
