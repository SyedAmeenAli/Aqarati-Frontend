import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking.dart';
import '../../data/models/property.dart';
import '../../data/repositories/app_state_providers.dart';
import 'owner_mock_data.dart';

final ownerListingsProvider = StateProvider<List<Property>>((ref) => ownerMockListings);

/// Enquiries buyers have sent this owner about their listings — distinct
/// from [enquiriesProvider], which is the buyer-side "My Enquiries" state
/// for the currently signed-in guest. Conflating the two would show this
/// owner's incoming questions as if the guest had sent them.
final ownerEnquiriesProvider = StateProvider<List<SentEnquiry>>((ref) => ownerMockEnquiries);

/// Viewings booked on this owner's listings — distinct from [bookingsProvider]
/// for the same reason as [ownerEnquiriesProvider] above.
final ownerBookingsProvider = StateProvider<List<Booking>>((ref) => ownerMockBookings);
