import 'package:flutter_riverpod/legacy.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';

class ActiveOfferNotifier extends StateNotifier<Offers?> {
  ActiveOfferNotifier() : super(null);

  void set(Offers offer) => state = offer;
  void clear() => state = null;
}

/// Holds the promotional offer currently active in the booking flow.
/// Set when user taps "Book Now" on an offer detail page.
/// Cleared after successful booking or when leaving service details without booking.
final activeOfferProvider = StateNotifierProvider<ActiveOfferNotifier, Offers?>(
  (ref) => ActiveOfferNotifier(),
);
