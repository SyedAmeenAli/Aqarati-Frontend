import '../../data/models/enums.dart';

enum BudgetBucket { under50k, from50to150k, from150to300k, custom }

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
