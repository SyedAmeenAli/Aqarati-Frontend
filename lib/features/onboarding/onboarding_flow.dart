import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/aqarati_button.dart';
import '../../core/widgets/aqarati_fee_card.dart';
import '../../core/widgets/aqarati_otp_field.dart';
import '../../core/widgets/aqarati_startup_video.dart';
import '../../data/models/enums.dart';
import '../../data/models/verification_models.dart';
import '../../data/repositories/app_state_providers.dart';
import '../../core/locale/locale_provider.dart';
import 'onboarding_background.dart';
import 'onboarding_preferences.dart';

/// One real photograph per onboarding concept (see AQARATI_ONBOARDING_ASSETS.md
/// for the full asset audit). `intro` and `language` share the same subtle
/// welcome image since both are generic pre-commitment screens; `transaction`
/// is the actual "What are you looking for?" (Buy/Rent/Lease) screen — it's a
/// single combined chooser in this implementation, not three separate
/// screens, so it gets one representative image rather than a Buy/Rent/Lease
/// split that doesn't exist in the current UI. `locationPermission` and
/// `location` share the location asset since they're the same concept.
const _stepBackgrounds = {
  _Step.language: 'assets/onboarding/onboarding_01_language.jpg',
  _Step.intro: 'assets/onboarding/onboarding_01_language.jpg',
  _Step.transaction: 'assets/onboarding/onboarding_02_intent.jpg',
  _Step.propertyType: 'assets/onboarding/onboarding_06_property_types.jpg',
  _Step.services: 'assets/onboarding/onboarding_07_services.jpg',
  _Step.locationPermission: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.location: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.email: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.emailOtp: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.phone: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.phoneOtp: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.name: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.serviceMode: 'assets/onboarding/onboarding_02_intent.jpg',
  _Step.serviceModeExplanation: 'assets/onboarding/onboarding_02_intent.jpg',
  _Step.ownerJourney: 'assets/properties/p1/07_Waterfront_villa_with_infinity_pool.jpg',
  _Step.keyDepositIntro: 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg',
  _Step.keyDepositConsent: 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg',
  _Step.keySetDetails: 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg',
  _Step.keyHandoverMethod: 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg',
  _Step.keyHandoverConfirmation: 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg',
  _Step.citizenshipStatus: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.passportIntro: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.passportCapture: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.passportReview: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.verificationPending: 'assets/onboarding/onboarding_08_location.jpg',
  _Step.budget: 'assets/onboarding/onboarding_09_preferences.jpg',
  _Step.summary: 'assets/onboarding/onboarding_10_summary.jpg',
  _Step.success: 'assets/onboarding/onboarding_11_complete.jpg',
};

enum _Step {
  splash,
  language,
  locationPermission,
  email,
  emailOtp,
  phone,
  phoneOtp,
  name,
  intro,
  userType,
  transaction,
  propertyType,
  services,
  serviceMode,
  serviceModeExplanation,
  ownerJourney,
  keyDepositIntro,
  keyDepositConsent,
  keySetDetails,
  keyHandoverMethod,
  keyHandoverConfirmation,
  citizenshipStatus,
  passportIntro,
  passportCapture,
  passportReview,
  verificationPending,
  location,
  budget,
  summary,
  success,
}

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _prefs = OnboardingPreferences();
  _Step _step = _Step.splash;
  bool _skippedEarly = false;


  /// Computed fresh on every navigation — later branch points (service mode,
  /// owner journey, key deposit) depend on answers given at earlier ones, so
  /// this can't be a fixed list. Steps a user's answers don't apply to are
  /// simply left out of the list rather than shown and skipped.
  List<_Step> get _order {
    final consumer = _prefs.isConsumerFlow;
    final owner = _prefs.ownerJourney?.isOwnerSide ?? false;
    final wantsKeyDeposit = owner && _prefs.serviceMode == ServiceMode.broker;
    return [
      _Step.splash,
      _Step.language,
      _Step.locationPermission,
      _Step.email,
      _Step.emailOtp,
      _Step.phone,
      _Step.phoneOtp,
      _Step.name,
      _Step.intro,
      _Step.userType,
      _Step.transaction,
      _Step.propertyType,
      _Step.services,
      if (consumer) ...[
        _Step.serviceMode,
        _Step.serviceModeExplanation,
        _Step.ownerJourney,
        if (wantsKeyDeposit) ...[
          _Step.keyDepositIntro,
          if (_prefs.keyDepositOptedIn) ...[
            _Step.keyDepositConsent,
            _Step.keySetDetails,
            _Step.keyHandoverMethod,
            _Step.keyHandoverConfirmation,
          ],
        ],
        _Step.citizenshipStatus,
        _Step.passportIntro,
        if (_prefs.passportState != PassportVerificationState.notStarted) ...[
          _Step.passportCapture,
          _Step.passportReview,
          _Step.verificationPending,
        ],
      ],
      _Step.location,
      _Step.budget,
      _Step.summary,
      _Step.success,
    ];
  }

  void _goTo(_Step step) => setState(() => _step = step);

  void _next() {
    final i = _order.indexOf(_step);
    if (i < _order.length - 1) _goTo(_order[i + 1]);
  }

  void _back() {
    final i = _order.indexOf(_step);
    if (i > 0) _goTo(_order[i - 1]);
  }

  void _skipToHome() {
    if (_prefs.hasAnyAnswer) {
      setState(() => _skippedEarly = true);
      _goTo(_Step.success);
    } else {
      context.go('/home');
    }
  }

  void _finish() {
    if (_prefs.hasAnyAnswer) {
      ref.read(onboardingPreferencesProvider.notifier).state = _prefs;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _Step.splash) {
      return Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: AqaratiStartupVideo(onFinished: () => _goTo(_Step.language)),
      );
    }
    final asset = _backgroundFor(_step);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: asset == null
          ? SafeArea(child: _buildStep())
          : AqaratiOnboardingBackground(
              asset: asset,
              emphasis: _step == _Step.locationPermission,
              child: SafeArea(child: _buildStep()),
            ),
    );
  }

  /// Most steps use one fixed photo, but Transaction and Property Type
  /// reflect the user's actual choice — Buy/Rent/Lease and each property
  /// type ship their own real photo, swapped live as the user taps.
  String? _backgroundFor(_Step step) {
    if (step == _Step.transaction) {
      return switch (_prefs.transactionType) {
        TransactionType.buy => 'assets/onboarding/onboarding_03_buy.jpg',
        TransactionType.rent => 'assets/onboarding/onboarding_04_rent.jpg',
        TransactionType.lease => 'assets/onboarding/onboarding_05_lease.jpg',
        null => 'assets/onboarding/onboarding_02_intent.jpg',
      };
    }
    if (step == _Step.propertyType) {
      if (_prefs.propertyTypes.isEmpty) return 'assets/onboarding/onboarding_06_property_types.jpg';
      return _propertyTypeAsset(_prefs.propertyTypes.last);
    }
    return _stepBackgrounds[step];
  }

  String _propertyTypeAsset(PropertyType type) {
    switch (type) {
      case PropertyType.villa:
        return 'assets/properties/p1/07_Waterfront_villa_with_infinity_pool.jpg';
      case PropertyType.apartment:
        return 'assets/properties/p2/02_Apartment_buildings_in_Muscat.jpg';
      case PropertyType.townhouse:
        return 'assets/properties/p4/01_Contemporary_family_villa_comple.jpg';
      case PropertyType.residentialLand:
        return 'assets/properties/p3/01_Aerial_view_of_residential_plot.jpg';
      case PropertyType.penthouse:
        return 'assets/properties/p5/05_Modern_apartment_building_exterior.jpg';
      case PropertyType.commercialBuilding:
        return 'assets/properties/p6/04_Modern_commercial_building_exterior.jpg';
      default:
        return 'assets/onboarding/onboarding_06_property_types.jpg';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.splash:
        return const SizedBox.shrink();
      case _Step.language:
        return _LanguageStep(onContinue: _next);
      case _Step.locationPermission:
        return _LocationPermissionStep(onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.email:
        return _EmailStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.emailOtp:
        return _EmailOtpStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.phone:
        return _PhoneStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.phoneOtp:
        return _PhoneOtpStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.name:
        return _NameStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.intro:
        return _IntroStep(onBack: _back, onGetStarted: _next, onSkip: () => context.go('/home'));
      case _Step.userType:
        return _UserTypeStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.transaction:
        return _TransactionStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.propertyType:
        return _PropertyTypeStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.services:
        return _ServicesStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.serviceMode:
        return _ServiceModeStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome, onChanged: () => setState(() {}));
      case _Step.serviceModeExplanation:
        return _ServiceModeExplanationStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.ownerJourney:
        return _OwnerJourneyStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome, onChanged: () => setState(() {}));
      case _Step.keyDepositIntro:
        return _KeyDepositIntroStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.keyDepositConsent:
        return _KeyDepositConsentStep(onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.keySetDetails:
        return _KeySetDetailsStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome);
      case _Step.keyHandoverMethod:
        return _KeyHandoverMethodStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome, onChanged: () => setState(() {}));
      case _Step.keyHandoverConfirmation:
        return _KeyHandoverConfirmationStep(prefs: _prefs, onBack: _back, onContinue: _next);
      case _Step.citizenshipStatus:
        return _CitizenshipStatusStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome, onChanged: () => setState(() {}));
      case _Step.passportIntro:
        return _PassportIntroStep(prefs: _prefs, onBack: _back, onContinue: _next, onSkip: _skipToHome, onChanged: () => setState(() {}));
      case _Step.passportCapture:
        return _PassportCaptureStep(prefs: _prefs, onBack: _back, onContinue: _next, onChanged: () => setState(() {}));
      case _Step.passportReview:
        return _PassportReviewStep(prefs: _prefs, onBack: _back, onContinue: _next, onChanged: () => setState(() {}));
      case _Step.verificationPending:
        _prefs.passportState = PassportVerificationState.pending;
        return _VerificationPendingStep(prefs: _prefs, onContinue: _next);
      case _Step.location:
        return _LocationStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.budget:
        return _BudgetStep(
          prefs: _prefs,
          onBack: _back,
          onContinue: _next,
          onSkip: _skipToHome,
          onChanged: () => setState(() {}),
        );
      case _Step.summary:
        return _SummaryStep(prefs: _prefs, onBack: _back, onConfirm: _next);
      case _Step.success:
        return _SuccessStep(skippedEarly: _skippedEarly, onDone: _finish);
    }
  }
}

/// Shared chrome for every intake step: back arrow, Skip link, title,
/// scrollable content, bottom Continue button.
class _OnboardingScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback onSkip;
  final VoidCallback onContinue;
  final bool continueEnabled;
  final String continueLabel;

  const _OnboardingScaffold({
    required this.title,
    this.subtitle,
    required this.child,
    this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.continueEnabled = true,
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              onBack != null
                  ? IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded))
                  : const SizedBox(width: 48),
              TextButton(onPressed: onSkip, child: const Text('Skip')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AqaratiButton(
            label: continueLabel,
            fullWidth: true,
            onPressed: continueEnabled ? onContinue : null,
          ),
        ),
      ],
    );
  }
}

class _LanguageStep extends ConsumerStatefulWidget {
  final VoidCallback onContinue;

  const _LanguageStep({required this.onContinue});

  @override
  ConsumerState<_LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends ConsumerState<_LanguageStep> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return _OnboardingScaffold(
      title: 'Choose your language',
      subtitle: 'You can change this later in Profile settings.',
      onSkip: widget.onContinue,
      onContinue: widget.onContinue,
      child: Column(
        children: [
          _LanguageTile(
            label: 'English',
            selected: locale.languageCode == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          const SizedBox(height: AppSpacing.md),
          _LanguageTile(
            label: 'العربية (Arabic)',
            selected: locale.languageCode == 'ar',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _LocationPermissionStep({required this.onBack, required this.onContinue, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Find properties near you',
      subtitle: 'Allow location access to see verified properties and services close to you.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueLabel: 'Enable location',
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: Icon(Icons.location_on_rounded, size: 72, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const _IntroStep({required this.onBack, required this.onGetStarted, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const Spacer(),
          Text('Make Aqarati yours', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Tell us what you're interested in right now — we'll make your experience more relevant.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AqaratiButton(label: 'Get started', fullWidth: true, onPressed: onGetStarted),
          const SizedBox(height: AppSpacing.md),
          TextButton(onPressed: onSkip, child: const Text('Skip for now')),
        ],
      ),
    );
  }
}

class _UserTypeStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _UserTypeStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Which best describes you?',
      subtitle: "We'll shape Aqarati around what you actually do.",
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.userRole != null,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.15,
        children: UserRole.values.map((role) {
          final selected = prefs.userRole == role;
          return _UserRoleCard(
            role: role,
            selected: selected,
            onTap: () {
              prefs.userRole = role;
              onChanged();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _UserRoleCard extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  const _UserRoleCard({required this.role, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              role.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(color: AppColors.sand),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  role.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            if (selected)
              const Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _TransactionStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  static const _copy = {
    TransactionType.buy: 'Find a property to buy.',
    TransactionType.rent: 'Find a property to rent.',
    TransactionType.lease: 'Find a property to lease.',
  };

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'What are you looking for?',
      subtitle: "Choose what you're interested in right now.",
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.transactionType != null,
      child: Column(
        children: TransactionType.values.map((t) {
          final selected = prefs.transactionType == t;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LanguageTile(
              label: '${t.label}\n${_copy[t]}',
              selected: selected,
              onTap: () {
                prefs.transactionType = t;
                onChanged();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PropertyTypeStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _PropertyTypeStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'What kind of property?',
      subtitle: 'You can select more than one.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.propertyTypes.isNotEmpty,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: onboardingPropertyTypes.map((type) {
          final selected = prefs.propertyTypes.contains(type);
          return FilterChip(
            label: Text(type.label),
            selected: selected,
            onSelected: (_) {
              selected ? prefs.propertyTypes.remove(type) : prefs.propertyTypes.add(type);
              onChanged();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ServicesStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _ServicesStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Any services you need?',
      subtitle: "We'll show relevant professionals near you.",
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.services.isNotEmpty,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: BusinessCategory.values.map((category) {
          final selected = prefs.services.contains(category);
          return FilterChip(
            label: Text(category.label),
            selected: selected,
            onSelected: (_) {
              selected ? prefs.services.remove(category) : prefs.services.add(category);
              onChanged();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _LocationStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Where are you looking?',
      subtitle: 'Choose one or more places in Oman.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.locations.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search a city, area or neighbourhood',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('POPULAR LOCATIONS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: omanPopularLocations.map((loc) {
              final selected = prefs.locations.contains(loc);
              return FilterChip(
                label: Text(loc),
                selected: selected,
                onSelected: (_) {
                  selected ? prefs.locations.remove(loc) : prefs.locations.add(loc);
                  onChanged();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BudgetStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onChanged;

  const _BudgetStep({
    required this.prefs,
    required this.onBack,
    required this.onContinue,
    required this.onSkip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Anything else?',
      subtitle: 'These help us show the most relevant results.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.budget != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BUDGET', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: BudgetBucket.values.map((bucket) {
              final selected = prefs.budget == bucket;
              return ChoiceChip(
                label: Text(bucket.label),
                selected: selected,
                onSelected: (_) {
                  prefs.budget = bucket;
                  onChanged();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('BEDROOMS', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [null, 1, 2, 3, 4].map((n) {
              final selected = prefs.bedrooms == n;
              return ChoiceChip(
                label: Text(n == null ? 'Any' : n == 4 ? '4+' : '$n'),
                selected: selected,
                onSelected: (_) {
                  prefs.bedrooms = n;
                  onChanged();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _SummaryStep({required this.prefs, required this.onBack, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded))],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Aqarati', style: Theme.of(context).textTheme.headlineMedium),
                Text(
                  "Here's a summary of what you're looking for.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (prefs.fullName != null && prefs.fullName!.isNotEmpty)
                  _SummaryRow(label: 'NAME', value: prefs.fullName!),
                if (prefs.email != null) _SummaryRow(label: 'EMAIL', value: prefs.email!),
                if (prefs.phone != null) _SummaryRow(label: 'PHONE', value: prefs.phone!),
                if (prefs.userRole != null)
                  _SummaryRow(label: 'I AM A', value: prefs.userRole!.label),
                if (prefs.transactionType != null)
                  _SummaryRow(label: 'LOOKING TO', value: prefs.transactionType!.label),
                if (prefs.propertyTypes.isNotEmpty)
                  _SummaryRow(
                    label: 'PROPERTY TYPES',
                    value: prefs.propertyTypes.map((t) => t.label).join(', '),
                  ),
                if (prefs.services.isNotEmpty)
                  _SummaryRow(
                    label: 'SERVICES',
                    value: prefs.services.map((s) => s.label).join(', '),
                  ),
                if (prefs.locations.isNotEmpty)
                  _SummaryRow(label: 'LOCATIONS', value: prefs.locations.join(', ')),
                if (prefs.budget != null) _SummaryRow(label: 'BUDGET', value: prefs.budget!.label),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AqaratiButton(label: "Explore Aqarati", fullWidth: true, onPressed: onConfirm),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  final bool skippedEarly;
  final VoidCallback onDone;

  const _SuccessStep({required this.skippedEarly, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            skippedEarly ? Icons.info_outline_rounded : Icons.check_circle_rounded,
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            skippedEarly ? 'No problem.' : "You're all set.",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            skippedEarly
                ? 'You can personalize Aqarati anytime from your profile.'
                : "We'll use your preferences to make Aqarati more relevant.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AqaratiButton(label: 'Explore Aqarati', fullWidth: true, onPressed: onDone),
        ],
      ),
    );
  }
}

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class _EmailStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _EmailStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  late final _controller = TextEditingController(text: widget.prefs.email ?? '');
  bool _loading = false;
  String? _error;

  bool get _isValid => _emailRegex.hasMatch(_controller.text.trim());

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.prefs.email = _controller.text.trim();
    widget.onContinue();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: "Let's get your details",
      subtitle: 'A few details help us keep your account secure and make Aqarati more useful.',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onContinue: _submit,
      continueEnabled: !_loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email address', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(hintText: 'you@example.com', errorText: _error),
          ),
          if (_loading) ...[
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ],
        ],
      ),
    );
  }
}

class _EmailOtpStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _EmailOtpStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_EmailOtpStep> createState() => _EmailOtpStepState();
}

class _EmailOtpStepState extends State<_EmailOtpStep> {
  bool _verifying = false;
  final bool _error = false;
  int _cooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _onCompleted(String code) async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _verifying = false);
    widget.prefs.emailVerified = true;
    widget.onContinue();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a 6-digit code to ${widget.prefs.email ?? 'your email'}.',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onContinue: () {},
      continueEnabled: false,
      continueLabel: _verifying ? 'Verifying...' : 'Enter the code above',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AqaratiOtpField(onCompleted: _onCompleted, hasError: _error),
          const SizedBox(height: AppSpacing.lg),
          if (_verifying) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _cooldown <= 0 ? _startCooldown : null,
                child: Text(_cooldown > 0 ? 'Resend code in ${_cooldown}s' : 'Resend code'),
              ),
              TextButton(onPressed: widget.onBack, child: const Text('Change email')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhoneStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _PhoneStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  late final _controller = TextEditingController(text: widget.prefs.phone ?? '');
  bool _loading = false;
  String? _error;

  bool get _isValid => RegExp(r'^\d{8}$').hasMatch(_controller.text.trim());

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _error = 'Enter a valid 8-digit Oman mobile number.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.prefs.phone = '+968 ${_controller.text.trim()}';
    widget.onContinue();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: "What's your mobile number?",
      subtitle: "We'll use this for important account and property updates.",
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onContinue: _submit,
      continueEnabled: !_loading,
      continueLabel: 'Send code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mobile number', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text('+968'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(hintText: '9XXXXXXX', errorText: _error),
                ),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ],
        ],
      ),
    );
  }
}

class _PhoneOtpStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _PhoneOtpStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_PhoneOtpStep> createState() => _PhoneOtpStepState();
}

class _PhoneOtpStepState extends State<_PhoneOtpStep> {
  bool _verifying = false;
  final bool _error = false;
  int _cooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _onCompleted(String code) async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _verifying = false);
    widget.prefs.phoneVerified = true;
    widget.onContinue();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Verify your number',
      subtitle: 'Enter the 6-digit code sent to ${widget.prefs.phone ?? 'your number'}.',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onContinue: () {},
      continueEnabled: false,
      continueLabel: _verifying ? 'Verifying...' : 'Enter the code above',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AqaratiOtpField(onCompleted: _onCompleted, hasError: _error),
          const SizedBox(height: AppSpacing.lg),
          if (_verifying) const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _cooldown <= 0 ? _startCooldown : null,
                child: Text(_cooldown > 0 ? 'Resend code in ${_cooldown}s' : 'Resend code'),
              ),
              TextButton(onPressed: widget.onBack, child: const Text('Change number')),
            ],
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _NameStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final _controller = TextEditingController(text: widget.prefs.fullName ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'What should we call you?',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      continueEnabled: _controller.text.trim().isNotEmpty,
      onContinue: () {
        widget.prefs.fullName = _controller.text.trim();
        widget.onContinue();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full name', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Ameen Syed'),
          ),
        ],
      ),
    );
  }
}

/// Generic single-choice list row shared by Owner Journey, Citizenship
/// Status, and Key Handover Method — one large tappable card per option.
class _ChoiceListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceListTile({required this.title, this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
                  ],
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _ServiceModeStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip, onChanged;

  const _ServiceModeStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'How do you want Aqarati to help?',
      subtitle: 'Choose how involved you want us to be.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.serviceMode != null,
      child: Column(
        children: [
          _ServiceModeCard(
            title: 'Let Aqarati handle it',
            subtitle:
                'Tell us what you want to buy, sell, rent or find. We\'ll take care of the journey for you — matching opportunities, handling enquiries, coordinating viewings and helping move the process forward.',
            chips: const ['Property search', 'Buyer / seller matching', 'Enquiries', 'Viewings', 'Process coordination'],
            selected: prefs.serviceMode == ServiceMode.broker,
            onTap: () {
              prefs.serviceMode = ServiceMode.broker;
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _ServiceModeCard(
            title: 'You stay in control',
            subtitle:
                'Search, contact, arrange viewings and manage your property journey yourself. Aqarati provides the platform and tools, while you handle the process.',
            chips: [formatServiceFeeRate(), 'Aqarati service / convenience fee applies to a completed transaction'],
            selected: prefs.serviceMode == ServiceMode.selfManaged,
            onTap: () {
              prefs.serviceMode = ServiceMode.selfManaged;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> chips;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceModeCard({required this.title, required this.subtitle, required this.chips, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: chips
                  .map((c) => Chip(label: Text(c, style: theme.textTheme.labelSmall), backgroundColor: AppColors.sand))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceModeExplanationStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _ServiceModeExplanationStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final broker = prefs.serviceMode == ServiceMode.broker;
    return _OnboardingScaffold(
      title: broker ? 'Let Aqarati do the heavy lifting.' : 'Your property journey. Your way.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueLabel: broker ? 'Continue with Aqarati Broker' : 'Continue',
      child: broker
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _NumberedStep(number: 1, text: 'Tell us what you need'),
                _NumberedStep(number: 2, text: 'We find the right opportunities'),
                _NumberedStep(number: 3, text: 'We handle enquiries'),
                _NumberedStep(number: 4, text: 'We coordinate viewings'),
                _NumberedStep(number: 5, text: 'We help move the transaction forward'),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You'll search and manage the process yourself using Aqarati.", style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: ['Search', 'Contact', 'Viewings', 'Enquiries', 'Offers / process', 'Completion']
                      .map((c) => Chip(label: Text(c), backgroundColor: AppColors.sand))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AqaratiFeeCard(),
              ],
            ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, backgroundColor: AppColors.primary, child: Text('$number', style: const TextStyle(color: Colors.white))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _OwnerJourneyStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip, onChanged;

  const _OwnerJourneyStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Tell us about your property journey',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.ownerJourney != null,
      child: Column(
        children: OwnerJourneyChoice.values
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChoiceListTile(
                    title: c.label,
                    selected: prefs.ownerJourney == c,
                    onTap: () {
                      prefs.ownerJourney = c;
                      onChanged();
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _KeyDepositIntroStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _KeyDepositIntroStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Let Aqarati manage the viewings',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: () {
        prefs.keyDepositOptedIn = true;
        onContinue();
      },
      continueLabel: 'Set up key deposit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You can optionally leave a spare set of keys with Aqarati so approved viewings can be coordinated without you being present every time.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final b in ['Fewer interruptions', 'Coordinated viewings', 'Recorded key handover', 'Return tracking'])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.verified, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Text(b, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () {
                prefs.keyDepositOptedIn = false;
                onContinue();
              },
              child: const Text("I'll keep the keys"),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyDepositConsentStep extends StatelessWidget {
  final VoidCallback onBack, onContinue, onSkip;

  const _KeyDepositConsentStep({required this.onBack, required this.onContinue, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Your keys stay accounted for.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in ['Key handover', 'Secure custody', 'Approved access', 'Viewing', 'Return'])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('•  $step', style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: AppSpacing.md),
          Text('Key deposit is optional.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Only Aqarati-authorized personnel should access deposited keys.',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}

class _KeySetDetailsStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip;

  const _KeySetDetailsStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip});

  @override
  State<_KeySetDetailsStep> createState() => _KeySetDetailsStepState();
}

class _KeySetDetailsStepState extends State<_KeySetDetailsStep> {
  late final _propertyController = TextEditingController(text: widget.prefs.keySetPropertyName ?? '');
  late final _nameController = TextEditingController(text: widget.prefs.keySetName ?? '');
  late final _countController = TextEditingController(text: widget.prefs.keySetCount?.toString() ?? '');
  late final _notesController = TextEditingController(text: widget.prefs.keySetNotes ?? '');

  @override
  void dispose() {
    _propertyController.dispose();
    _nameController.dispose();
    _countController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Key set details',
      onBack: widget.onBack,
      onSkip: widget.onSkip,
      onContinue: () {
        widget.prefs.keySetPropertyName = _propertyController.text.trim();
        widget.prefs.keySetName = _nameController.text.trim();
        widget.prefs.keySetCount = int.tryParse(_countController.text.trim());
        widget.prefs.keySetNotes = _notesController.text.trim();
        widget.onContinue();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property name / address', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _propertyController, decoration: const InputDecoration(hintText: 'Villa 12, Al Mouj')),
          const SizedBox(height: AppSpacing.lg),
          Text('Key set name', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Villa main key set')),
          const SizedBox(height: AppSpacing.lg),
          Text('Number of keys', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: '2'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Notes', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: _notesController, decoration: const InputDecoration(hintText: 'Main entrance + gate')),
        ],
      ),
    );
  }
}

class _KeyHandoverMethodStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip, onChanged;

  const _KeyHandoverMethodStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'How would you like to hand over your keys?',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.keyHandoverMethod != null,
      child: Column(
        children: KeyHandoverMethod.values
            .map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChoiceListTile(
                    title: m.label,
                    subtitle: m == KeyHandoverMethod.dropOff || m == KeyHandoverMethod.collection ? 'Demo option — no real Aqarati location wired yet' : null,
                    selected: prefs.keyHandoverMethod == m,
                    onTap: () {
                      prefs.keyHandoverMethod = m;
                      onChanged();
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _KeyHandoverConfirmationStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue;

  const _KeyHandoverConfirmationStep({required this.prefs, required this.onBack, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Key deposit request created',
      onBack: onBack,
      onSkip: onContinue,
      onContinue: onContinue,
      continueLabel: 'Done',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'PROPERTY', value: prefs.keySetPropertyName ?? '—'),
          _SummaryRow(label: 'KEY SET', value: prefs.keySetName ?? '—'),
          _SummaryRow(label: 'HANDOVER METHOD', value: prefs.keyHandoverMethod?.label ?? '—'),
          _SummaryRow(label: 'STATUS', value: KeyCustodyState.awaitingHandover.label),
          const SizedBox(height: AppSpacing.md),
          Text('You can view and manage key status anytime from My Home.', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate)),
        ],
      ),
    );
  }
}

class _CitizenshipStatusStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip, onChanged;

  const _CitizenshipStatusStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Tell us about your status',
      subtitle: 'This helps us show the right verification requirements.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: onContinue,
      continueEnabled: prefs.citizenshipStatus != null,
      child: Column(
        children: CitizenshipStatus.values
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChoiceListTile(
                    title: s.label,
                    selected: prefs.citizenshipStatus == s,
                    onTap: () {
                      prefs.citizenshipStatus = s;
                      onChanged();
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PassportIntroStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onSkip, onChanged;

  const _PassportIntroStep({required this.prefs, required this.onBack, required this.onContinue, required this.onSkip, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Verify your identity',
      subtitle: 'Use your passport so we can confirm your identity.',
      onBack: onBack,
      onSkip: onSkip,
      onContinue: () {
        prefs.passportState = PassportVerificationState.uploading;
        onChanged();
        onContinue();
      },
      continueLabel: 'Verify passport',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.badge_outlined, size: 56, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text('Your document is used only for verification.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () {
                prefs.passportState = PassportVerificationState.notStarted;
                onChanged();
                onContinue();
              },
              child: const Text('Do this later'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportCaptureStep extends StatefulWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onChanged;

  const _PassportCaptureStep({required this.prefs, required this.onBack, required this.onContinue, required this.onChanged});

  @override
  State<_PassportCaptureStep> createState() => _PassportCaptureStepState();
}

class _PassportCaptureStepState extends State<_PassportCaptureStep> {
  bool _captured = false;

  void _pick() => setState(() => _captured = true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Place your passport inside the frame',
      onBack: widget.onBack,
      onSkip: widget.onContinue,
      onContinue: widget.onContinue,
      continueEnabled: _captured,
      continueLabel: 'Continue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.line, width: 2),
              color: AppColors.surface,
            ),
            alignment: Alignment.center,
            child: _captured
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_rounded, color: AppColors.verified, size: 40),
                      SizedBox(height: AppSpacing.sm),
                      Text('Document selected'),
                    ],
                  )
                : Icon(Icons.crop_free_rounded, size: 56, color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Make sure all four corners are visible.', style: theme.textTheme.bodySmall),
          Text('Avoid glare and shadows.', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: _pick, child: const Text('Take photo'))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: OutlinedButton(onPressed: _pick, child: const Text('Upload from phone'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassportReviewStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onBack, onContinue, onChanged;

  const _PassportReviewStep({required this.prefs, required this.onBack, required this.onContinue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _OnboardingScaffold(
      title: 'Check your passport',
      onBack: onBack,
      onSkip: onContinue,
      onContinue: () {
        prefs.passportState = PassportVerificationState.submitted;
        onChanged();
        onContinue();
      },
      continueLabel: 'Submit for verification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), color: AppColors.surface),
            alignment: Alignment.center,
            child: Icon(Icons.badge_outlined, size: 48, color: AppColors.mist),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in ['Photo page visible', 'Text readable', 'Corners visible'])
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, color: AppColors.verified, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VerificationPendingStep extends StatelessWidget {
  final OnboardingPreferences prefs;
  final VoidCallback onContinue;

  const _VerificationPendingStep({required this.prefs, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_top_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          Text('Your verification is in progress.', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll update you when your identity has been reviewed.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AqaratiButton(label: 'Continue', fullWidth: true, onPressed: onContinue),
        ],
      ),
    );
  }
}
