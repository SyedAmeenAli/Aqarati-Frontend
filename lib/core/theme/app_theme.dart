import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        ink: AppColors.neutral900,
        background: AppColors.neutral25,
        surface: AppColors.neutral0,
        line: AppColors.neutral200,
        sand: AppColors.neutral50,
        mist: AppColors.neutral400,
        charcoal: AppColors.neutral800,
        divider: AppColors.neutral100,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        ink: AppColors.neutral50,
        background: AppColors.neutral950,
        surface: AppColors.neutral900,
        line: AppColors.neutral700,
        sand: AppColors.neutral800,
        mist: AppColors.neutral500,
        charcoal: AppColors.neutral200,
        divider: AppColors.neutral800,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color ink,
    required Color background,
    required Color surface,
    required Color line,
    required Color sand,
    required Color mist,
    required Color charcoal,
    required Color divider,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: ink,
      surface: surface,
      onSurface: ink,
      error: AppColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTypography.textTheme.bodyMedium?.fontFamily,
      textTheme: brightness == Brightness.dark
          ? AppTypography.textTheme.apply(bodyColor: ink, displayColor: ink)
          : AppTypography.textTheme,
      dividerColor: divider,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: AppElevation.flat, // flat surfaces per foundations spec — shadows used sparingly
        shadowColor: ink.withValues(alpha: AppElevation.subtleAlpha),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: line, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: mist,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: line, width: AppBorder.regular),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sand,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.primary, width: AppBorder.regular),
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: mist),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: sand,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTypography.textTheme.labelLarge?.copyWith(color: charcoal),
        secondaryLabelStyle: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.primary),
        iconTheme: const IconThemeData(size: AppIconSize.compact),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide.none,
        ),
        side: WidgetStateBorderSide.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return BorderSide(color: selected ? AppColors.primary : line, width: 1.2);
        }),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : mist,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
    );
  }
}
