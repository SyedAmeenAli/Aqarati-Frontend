import '../../data/models/enums.dart';
import '../../data/models/verification_models.dart';

enum BudgetBucket { under50k, from50to150k, from150to300k, custom }

/// The very first choice, before auth — "How will you use Aqarati?".
/// Routes into the existing role/onboarding logic rather than a
/// separate auth system: buyer/seller both resolve to [UserRole.buyerTenant]
/// (the seller path continues into the existing owner-journey question),
/// professional still picks a specific business type via the existing
/// [UserRole] step.
enum EntryRole { buyer, seller, professional }

extension EntryRoleLabel on EntryRole {
  String get title {
    switch (this) {
      case EntryRole.buyer:
        return 'Find a property';
      case EntryRole.seller:
        return 'Sell or rent my property';
      case EntryRole.professional:
        return 'Upload & manage properties';
    }
  }

  String get subtitle {
    switch (this) {
      case EntryRole.buyer:
        return 'Buy, rent or explore homes.';
      case EntryRole.seller:
        return 'List your property and find the right people.';
      case EntryRole.professional:
        return 'For agents and property professionals.';
    }
  }

  String get image {
    switch (this) {
      case EntryRole.buyer:
        return 'assets/properties/p1/07_Waterfront_villa_with_infinity_pool.jpg';
      case EntryRole.seller:
        return 'assets/properties/p4/01_Contemporary_family_villa_comple.jpg';
      case EntryRole.professional:
        return 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg';
    }
  }
}

enum OwnerJourneyChoice { selling, rentingOut, leasingOut, buying, renting, exploring }

extension OwnerJourneyChoiceLabel on OwnerJourneyChoice {
  String get label {
    switch (this) {
      case OwnerJourneyChoice.selling:
        return "I'm selling a property";
      case OwnerJourneyChoice.rentingOut:
        return "I'm renting out a property";
      case OwnerJourneyChoice.leasingOut:
        return "I'm leasing out a property";
      case OwnerJourneyChoice.buying:
        return "I'm looking to buy";
      case OwnerJourneyChoice.renting:
        return "I'm looking to rent";
      case OwnerJourneyChoice.exploring:
        return "I'm exploring";
    }
  }

  bool get isOwnerSide => this == OwnerJourneyChoice.selling || this == OwnerJourneyChoice.rentingOut || this == OwnerJourneyChoice.leasingOut;
}

enum KeyHandoverMethod { dropOff, collection, arrangeLater }

extension KeyHandoverMethodLabel on KeyHandoverMethod {
  String get label {
    switch (this) {
      case KeyHandoverMethod.dropOff:
        return 'Drop them at an Aqarati location';
      case KeyHandoverMethod.collection:
        return 'Aqarati collection';
      case KeyHandoverMethod.arrangeLater:
        return 'Arrange later';
    }
  }
}

/// Who the user is, asked once during onboarding (or later, if skipped, when
/// they attempt identity verification) — drives which experience they land in downstream.
enum UserRole { buyerTenant, realEstateAgent, constructionCompany, propertyDeveloper, architectureFirm, interiorDesignStudio }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.buyerTenant:
        return 'Buyer / Tenant';
      case UserRole.realEstateAgent:
        return 'Real Estate Agent';
      case UserRole.constructionCompany:
        return 'Construction Company';
      case UserRole.propertyDeveloper:
        return 'Property Development';
      case UserRole.architectureFirm:
        return 'Building & Architecture';
      case UserRole.interiorDesignStudio:
        return 'Interior Design';
    }
  }

  String get image {
    switch (this) {
      case UserRole.buyerTenant:
        return 'assets/properties/p1/07_Waterfront_villa_with_infinity_pool.jpg';
      case UserRole.realEstateAgent:
        return 'assets/businesses/b1/13_30_Modern_office_lobby_interior.jpg';
      case UserRole.constructionCompany:
        return 'assets/businesses/b2/05_Construction_site_with_tower_crane.jpg';
      case UserRole.propertyDeveloper:
        return 'assets/businesses/b2/09_41_Residential_development_architec.jpg';
      case UserRole.architectureFirm:
        return 'assets/businesses/b1/05_Contemporary_architectural_facad.jpg';
      case UserRole.interiorDesignStudio:
        return 'assets/businesses/b3/06_Styled_bedroom_interior_photography.jpg';
    }
  }
}

/// Local-only draft of onboarding answers. Persisted nowhere yet — wire to
/// a real preferences repository once the backend exists.
class OnboardingPreferences {
  EntryRole? entryRole;
  UserRole? userRole;
  TransactionType? transactionType;
  final Set<PropertyType> propertyTypes = {};
  final Set<BusinessCategory> services = {};
  final Set<String> locations = {};
  BudgetBucket? budget;
  int? bedrooms; // null = "Any"

  String? email;
  bool emailVerified = false;
  String? phone;
  bool phoneVerified = false;
  String? fullName;

  ServiceMode? serviceMode;
  OwnerJourneyChoice? ownerJourney;

  bool keyDepositOptedIn = false;
  String? keySetPropertyName;
  String? keySetName;
  int? keySetCount;
  String? keySetNotes;
  KeyHandoverMethod? keyHandoverMethod;

  CitizenshipStatus? citizenshipStatus;
  PassportVerificationState passportState = PassportVerificationState.notStarted;

  /// The consumer-facing extended flow (service mode, owner journey, key
  /// deposit, citizenship/passport) only applies to buyers/tenants — a
  /// professional (agent, construction, developer, architecture, interior
  /// design) role goes straight from Services to Location/Budget/Summary,
  /// matching how those roles already worked before this rework.
  bool get isConsumerFlow => userRole == null || userRole == UserRole.buyerTenant;

  bool get hasAnyAnswer =>
      userRole != null ||
      transactionType != null ||
      propertyTypes.isNotEmpty ||
      services.isNotEmpty ||
      locations.isNotEmpty ||
      budget != null ||
      email != null ||
      phone != null ||
      (fullName != null && fullName!.isNotEmpty);
}

const List<String> omanPopularLocations = [
  'Muscat',
  'Seeb',
  'Bawshar',
  'Qurum',
  'Al Mouj',
  'Sohar',
  'Salalah',
  'Nizwa',
];

const List<PropertyType> onboardingPropertyTypes = [
  PropertyType.villa,
  PropertyType.apartment,
  PropertyType.townhouse,
  PropertyType.residentialLand,
  PropertyType.penthouse,
  PropertyType.commercialBuilding,
];

extension BudgetBucketLabel on BudgetBucket {
  String get label {
    switch (this) {
      case BudgetBucket.under50k:
        return 'Under OMR 50,000';
      case BudgetBucket.from50to150k:
        return 'OMR 50,000 - 150,000';
      case BudgetBucket.from150to300k:
        return 'OMR 150,000 - 300,000+';
      case BudgetBucket.custom:
        return 'Custom';
    }
  }
}
