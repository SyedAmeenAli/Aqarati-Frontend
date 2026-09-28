import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Atmospheric background layer for onboarding steps — a top hero band of
/// real Omani architectural photography that fades into the existing flat
/// background before reaching the selection controls/CTA, so the supplied
/// imagery enriches the screen without ever becoming the primary content.
/// The existing AqaratiOnboarding UI (title, chips, buttons) renders
/// unchanged on top; this widget owns only the photograph + fade.
class AqaratiOnboardingBackground extends StatelessWidget {
  final String asset;
  final Widget child;
  final bool emphasis;

  const AqaratiOnboardingBackground({super.key, required this.asset, required this.child, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fadeColor = isDark ? AppColors.neutral900 : AppColors.background;
    final stops = emphasis ? const [0.0, 0.42, 0.58, 0.72, 0.82] : const [0.0, 0.32, 0.46, 0.58, 0.66];

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stack) => Container(color: fadeColor),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  fadeColor.withValues(alpha: 0.0),
                  fadeColor.withValues(alpha: isDark ? 0.2 : 0.05),
                  fadeColor.withValues(alpha: isDark ? 0.55 : 0.4),
                  fadeColor.withValues(alpha: isDark ? 0.92 : 0.88),
                  fadeColor,
                ],
                stops: stops,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
