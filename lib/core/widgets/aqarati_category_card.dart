import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Explore category tile — real Omani property photography as a subtle
/// full-bleed background, dark scrim for label legibility, icon chip
/// floating on top. Reused by every "Explore" style grid in the app.
class AqaratiCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? image;
  final VoidCallback onTap;

  const AqaratiCategoryCard({super.key, required this.icon, required this.label, this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(color: AppColors.sand),
              ),
            if (image != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withValues(alpha: 0.62), Colors.black.withValues(alpha: 0.18)],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: image != null ? Colors.white.withValues(alpha: 0.9) : AppColors.red50,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: image != null ? Colors.white : AppColors.charcoal,
                            fontSize: 12.5,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
