import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';

enum _Stage { intro, waiting, success, failed }

/// Aqarati's own identity verification — no external government identity
/// provider. Frontend states only; wire to a real verification backend later.
class IdentityVerificationFlow extends StatefulWidget {
  const IdentityVerificationFlow({super.key});

  @override
  State<IdentityVerificationFlow> createState() => _IdentityVerificationFlowState();
}

class _IdentityVerificationFlowState extends State<IdentityVerificationFlow> {
  _Stage _stage = _Stage.intro;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startWaiting() {
    setState(() => _stage = _Stage.waiting);
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _stage = _Stage.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your identity')),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _buildStage(),
        ),
      ),
    );
  }

  Widget _buildStage() {
    final theme = Theme.of(context);
    switch (_stage) {
      case _Stage.intro:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 72, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text('Verify your identity', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "This helps others trust your listings and messages. We only ask for what's needed to verify who you are.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AqaratiButton(label: 'Start verification', fullWidth: true, onPressed: _startWaiting),
          ],
        );
      case _Stage.waiting:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text('Verifying...', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('This usually takes a few seconds.', style: theme.textTheme.bodySmall),
          ],
        );
      case _Stage.success:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text('Identity confirmed', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text("You're verified. This helps others trust your listings and messages.",
                style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxxl),
            AqaratiButton(label: 'Continue', fullWidth: true, onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      case _Stage.failed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 72, color: AppColors.error),
            const SizedBox(height: AppSpacing.xl),
            Text('Verification unsuccessful', style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Please try again.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxxl),
            AqaratiButton(label: 'Try again', fullWidth: true, onPressed: () => setState(() => _stage = _Stage.intro)),
          ],
        );
    }
  }
}
