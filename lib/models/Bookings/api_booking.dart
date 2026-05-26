import 'package:recoverylab_front/models/Bookings/api_appointment.dart';

enum ApiBookingStatus {
  draft,
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled,
  noShow,
}

class ApiBooking {
  final int id;
  final int userId;
  final int branchId;
  final int? comboId;
  final DateTime bookingDate;
  final ApiBookingStatus status;
  final String paymentStatus;
  final double originalTotal;
  final double finalTotal;
  final String discountSource;
  final String? notes;
  final int pointsRedeemed;
  final double pointsDiscountAmount;
  final List<ApiAppointment> appointments;
  final String? branchName;
  final String? branchAddress;
  final String? branchImage;

  const ApiBooking({
    required this.id,
    required this.userId,
    required this.branchId,
    this.comboId,
    required this.bookingDate,
    required this.status,
    required this.paymentStatus,
    required this.originalTotal,
    required this.finalTotal,
    required this.discountSource,
    this.notes,
    this.pointsRedeemed = 0,
    this.pointsDiscountAmount = 0.0,
    required this.appointments,
    this.branchName,
    this.branchAddress,
    this.branchImage,
  });

  static ApiBookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'DRAFT':
        return ApiBookingStatus.draft;
      case 'PENDING':
        return ApiBookingStatus.pending;
      case 'CONFIRMED':
        return ApiBookingStatus.confirmed;
      case 'CHECKED_IN':
        return ApiBookingStatus.checkedIn;
      case 'COMPLETED':
        return ApiBookingStatus.completed;
      case 'CANCELLED':
        return ApiBookingStatus.cancelled;
      case 'NO_SHOW':
        return ApiBookingStatus.noShow;
      default:
        return ApiBookingStatus.pending;
    }
  }

  /// Latest `scheduled_end` across all appointments (null if none).
  DateTime? get latestScheduledEnd {
    if (appointments.isEmpty) return null;
    return appointments
        .map((a) => a.scheduledEnd)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Earliest `scheduled_start` — used for sorting upcoming bookings.
  DateTime? get earliestScheduledStart {
    if (appointments.isEmpty) return null;
    return appointments
        .map((a) => a.scheduledStart)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// True when every appointment is finished (scheduled_end < now). Bookings
  /// without appointments fall back to false (we cannot infer time).
  bool get isPastByTime {
    final end = latestScheduledEnd;
    return end != null && end.isBefore(DateTime.now());
  }

  bool _isActiveStatus() =>
      status == ApiBookingStatus.draft ||
      status == ApiBookingStatus.pending ||
      status == ApiBookingStatus.confirmed ||
      status == ApiBookingStatus.checkedIn;

  /// Upcoming = active status AND session is still in the future.
  /// This auto-removes "stale" bookings whose status was never closed by reception.
  bool get isUpcoming => _isActiveStatus() && !isPastByTime;

  /// Completed = explicit COMPLETED status OR an active-status booking whose
  /// session time has already passed (treated as effectively done client-side).
  bool get isCompleted =>
      status == ApiBookingStatus.completed ||
      (_isActiveStatus() && isPastByTime);

  bool get isCancelled =>
      status == ApiBookingStatus.cancelled ||
      status == ApiBookingStatus.noShow;

  /// True when the session time has passed but reception never closed it.
  /// Use this to badge the booking visually instead of pretending it's COMPLETED.
  bool get isUnclosedPast => _isActiveStatus() && isPastByTime;

  String get statusLabel {
    if (isUnclosedPast) return 'PAST SESSION';
    switch (status) {
      case ApiBookingStatus.draft:
        return 'DRAFT';
      case ApiBookingStatus.pending:
        return 'PENDING';
      case ApiBookingStatus.confirmed:
        return 'CONFIRMED';
      case ApiBookingStatus.checkedIn:
        return 'CHECKED IN';
      case ApiBookingStatus.completed:
        return 'COMPLETED';
      case ApiBookingStatus.cancelled:
        return 'CANCELLED';
      case ApiBookingStatus.noShow:
        return 'NO SHOW';
    }
  }

  ApiAppointment? get firstAppointment =>
      appointments.isNotEmpty ? appointments.first : null;

  bool get isCombo => comboId != null;

  String get displayTitle => isCombo
      ? 'Combo Session'
      : (firstAppointment?.serviceName ?? 'Recovery Session');

  String get displayLocation => branchName ?? '—';

  String? get displayImage => firstAppointment?.serviceImage;

  /// True when total is 0 due to membership or package (not a bug).
  bool get isFreeByMembershipOrPackage =>
      finalTotal == 0 &&
      (discountSource == 'MEMBERSHIP' || discountSource == 'PACKAGE');

  /// Display string for final total: "Free" when 0 with membership/package, else "EGP X".
  String get displayFinalTotal {
    if (isFreeByMembershipOrPackage) return 'Free';
    return 'EGP ${finalTotal.toStringAsFixed(0)}';
  }

  /// Short label when booking is free due to discount (e.g. "Included in your membership").
  String? get freeReasonLabel {
    if (finalTotal != 0) return null;
    switch (discountSource) {
      case 'MEMBERSHIP':
        return 'Included in your membership';
      case 'PACKAGE':
        return 'Included with package';
      default:
        return null;
    }
  }

  /// Format any charged amount in booking context: "Free" when 0 and membership/package, else "EGP X".
  String formatChargedAmount(double amount) {
    if (amount == 0 && (discountSource == 'MEMBERSHIP' || discountSource == 'PACKAGE')) {
      return 'Free';
    }
    return 'EGP ${amount.toStringAsFixed(0)}';
  }

  factory ApiBooking.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>?;
    final apptsRaw = json['appointments'];
    final List<ApiAppointment> appts = apptsRaw is List
        ? (apptsRaw)
            .map((a) => ApiAppointment.fromJson(a as Map<String, dynamic>))
            .toList()
        : <ApiAppointment>[];

    DateTime parseBookingDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return ApiBooking(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: (json['user_id'] is int) ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      branchId: (json['branch_id'] is int) ? json['branch_id'] as int : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      comboId: json['combo_id'] != null ? ((json['combo_id'] is int) ? json['combo_id'] as int : int.tryParse(json['combo_id']?.toString() ?? '')) : null,
      bookingDate: parseBookingDate(json['booking_date']),
      status: _parseStatus(json['status']?.toString()),
      paymentStatus: json['payment_status']?.toString() ?? 'PENDING',
      originalTotal: double.tryParse(json['original_total']?.toString() ?? '0') ?? 0.0,
      finalTotal: double.tryParse(json['final_total']?.toString() ?? '0') ?? 0.0,
      discountSource: json['discount_source']?.toString() ?? 'NONE',
      notes: json['notes']?.toString(),
      pointsRedeemed: int.tryParse(json['points_redeemed']?.toString() ?? '0') ?? 0,
      pointsDiscountAmount: double.tryParse(json['points_discount_amount']?.toString() ?? '0') ?? 0.0,
      appointments: appts,
      branchName: branch?['name']?.toString(),
      branchAddress: branch?['address']?.toString(),
      branchImage: branch?['image']?.toString(),
    );
  }
}
