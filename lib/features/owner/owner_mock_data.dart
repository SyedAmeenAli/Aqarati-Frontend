import '../../data/datasources/mock_property_data.dart';
import '../../data/models/booking.dart';
import '../../data/models/enums.dart';
import '../../data/models/money.dart';
import '../../data/repositories/app_state_providers.dart';

/// Demo seed data for the Owner Dashboard — three of this owner's own
/// listings plus a week of enquiry/viewing activity, so the dashboard shows
/// a working product on first open instead of three empty states.
final ownerMockListings = [
  mockProperties.firstWhere((p) => p.id == 'p1'),
  mockProperties.firstWhere((p) => p.id == 'p2'),
  mockProperties.firstWhere((p) => p.id == 'p4'),
];

final ownerMockEnquiries = [
  SentEnquiry(
    id: 'e1',
    propertyTitle: ownerMockListings[0].title,
    message: 'Is the marina villa still available for a viewing this weekend?',
    sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    replied: true,
  ),
  SentEnquiry(
    id: 'e2',
    propertyTitle: ownerMockListings[1].title,
    message: 'Would you consider a 12-month lease instead of monthly?',
    sentAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
  ),
  SentEnquiry(
    id: 'e3',
    propertyTitle: ownerMockListings[2].title,
    message: 'Can you share the floor plan and title deed copy?',
    sentAt: DateTime.now().subtract(const Duration(days: 4)),
    replied: true,
  ),
];

final ownerMockBookings = [
  Booking(
    id: 'bk1',
    context: BookingContext.propertyViewing,
    contextTitle: ownerMockListings[0].title,
    date: DateTime.now().add(const Duration(days: 2)),
    timeSlotLabel: '4:00 PM',
    locationLabel: ownerMockListings[0].locationLabel,
    price: const Money(0),
    status: BookingStatus.confirmed,
  ),
  Booking(
    id: 'bk2',
    context: BookingContext.propertyViewing,
    contextTitle: ownerMockListings[2].title,
    date: DateTime.now().add(const Duration(days: 5)),
    timeSlotLabel: '11:30 AM',
    locationLabel: ownerMockListings[2].locationLabel,
    price: const Money(0),
    status: BookingStatus.pending,
  ),
];

/// Views-per-day over the last 7 days, for the Overview trend chart. Real
/// numbers once analytics exist — shaped realistically for the demo.
final ownerMockDailyViews = [42.0, 58.0, 51.0, 73.0, 65.0, 89.0, 96.0];
