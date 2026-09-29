import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../models/money.dart';
import '../models/saved.dart';
import '../models/identity_verification.dart';
import '../models/verification_models.dart';
import '../../features/onboarding/onboarding_preferences.dart';

/// The signed-in user — guest until identity verification succeeds.
/// Persisted so a completed verification survives app restarts
/// instead of asking again every launch.
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User>((ref) => CurrentUserNotifier());

class CurrentUserNotifier extends StateNotifier<User> {
  CurrentUserNotifier() : super(User.guest) {
    _load();
  }

  static const _verifiedKey = 'aqarati_user_verified';
  static const _nameKey = 'aqarati_user_name';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_verifiedKey) == true) {
      state = User(
        id: 'u1',
        name: prefs.getString(_nameKey) ?? 'Faisal Al-Said',
        identity: const IdentityVerification(status: VerificationStatus.verified, method: 'qr'),
      );
    }
  }

  Future<void> signIn(User user) async {
    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_verifiedKey, true);
    await prefs.setString(_nameKey, user.name);
  }

  Future<void> signOut() async {
    state = User.guest;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_verifiedKey, false);
  }
}

/// Answers collected during onboarding — set once at `_finish` in
/// OnboardingFlow, read by Home/Explore to make the intake actually change
/// what those screens show. Null until onboarding is completed at least once.
final onboardingPreferencesProvider = StateProvider<OnboardingPreferences?>((ref) => null);

/// Key custody status for the property deposited during onboarding (if any).
/// Derived from [onboardingPreferencesProvider] at first read, then owned
/// here so the Return flow can advance it independently.
final keyCustodyStateProvider = StateProvider<KeyCustodyState>((ref) {
  final prefs = ref.watch(onboardingPreferencesProvider);
  return prefs?.keyDepositOptedIn == true ? KeyCustodyState.awaitingHandover : KeyCustodyState.notRequested;
});

/// Session-scoped app state — in-memory only (no backend yet). Actions taken
/// in one screen (save, book, offer) show up in another (Saved, My Home,
/// My Enquiries) within the same session.

final savedPropertyIdsProvider = StateProvider<Set<String>>((ref) => {});

final savedSearchesProvider = StateProvider<List<SavedSearch>>((ref) => []);
final recentSearchesProvider = StateProvider<List<String>>((ref) => ['3 Bedroom Villas', 'Muscat', 'Interior Design', 'Al Mouj']);

class PropertyOffer {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final Money offerPrice;
  final QuoteStatus status;
  final Money? counterPrice;
  final DateTime createdAt;

  const PropertyOffer({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.offerPrice,
    required this.status,
    this.counterPrice,
    required this.createdAt,
  });

  PropertyOffer copyWith({QuoteStatus? status, Money? counterPrice}) => PropertyOffer(
        id: id,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        offerPrice: offerPrice,
        status: status ?? this.status,
        counterPrice: counterPrice ?? this.counterPrice,
        createdAt: createdAt,
      );
}

class SentEnquiry {
  final String id;
  final String propertyTitle;
  final String message;
  final DateTime sentAt;
  final bool replied;

  const SentEnquiry({
    required this.id,
    required this.propertyTitle,
    required this.message,
    required this.sentAt,
    this.replied = false,
  });
}

final enquiriesProvider = StateProvider<List<SentEnquiry>>((ref) => []);
final offersProvider = StateProvider<List<PropertyOffer>>((ref) => []);
final bookingsProvider = StateProvider<List<Booking>>((ref) => []);
