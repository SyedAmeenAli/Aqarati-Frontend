import 'enums.dart';

/// Aqarati's own identity verification — authentication mechanism only.
/// Never conflate with property or business verification.
class IdentityVerification {
  final VerificationStatus status;
  final String? method;
  final DateTime? confirmedAt;

  const IdentityVerification({
    required this.status,
    this.method,
    this.confirmedAt,
  });

  bool get isConfirmed => status == VerificationStatus.verified;
}

class User {
  final String id;
  final String name;
  final String? avatarUrl;
  final IdentityVerification identity;
  final bool isGuest;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.identity,
    this.isGuest = false,
  });

  static const guest = User(
    id: 'guest',
    name: 'Guest',
    identity: IdentityVerification(status: VerificationStatus.unverified),
    isGuest: true,
  );
}
