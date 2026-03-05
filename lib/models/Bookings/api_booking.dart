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
  final DateTime bookingDate;
  final ApiBookingStatus status;
  final String paymentStatus;
  final double originalTotal;
  final double finalTotal;
  final String discountSource;
  final String? notes;
  final List<ApiAppointment> appointments;
  final String? branchName;
  final String? branchAddress;
  final String? branchImage;

  const ApiBooking({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.bookingDate,
    required this.status,
    required this.paymentStatus,
    required this.originalTotal,
    required this.finalTotal,
    required this.discountSource,
    this.notes,
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

  bool get isUpcoming =>
      status == ApiBookingStatus.draft ||
      status == ApiBookingStatus.pending ||
      status == ApiBookingStatus.confirmed ||
      status == ApiBookingStatus.checkedIn;

  bool get isCompleted => status == ApiBookingStatus.completed;

  bool get isCancelled =>
      status == ApiBookingStatus.cancelled ||
      status == ApiBookingStatus.noShow;

  String get statusLabel {
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

  String get displayTitle =>
      firstAppointment?.serviceName ?? 'Recovery Session';

  String get displayLocation => branchName ?? '—';

  String? get displayImage => firstAppointment?.serviceImage;

  factory ApiBooking.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>?;
    final appts = (json['appointments'] as List<dynamic>? ?? [])
        .map((a) => ApiAppointment.fromJson(a as Map<String, dynamic>))
        .toList();

    return ApiBooking(
      id: json['id'],
      userId: json['user_id'],
      branchId: json['branch_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      status: _parseStatus(json['status']),
      paymentStatus: json['payment_status'] ?? 'PENDING',
      originalTotal:
          double.tryParse(json['original_total']?.toString() ?? '0') ?? 0.0,
      finalTotal:
          double.tryParse(json['final_total']?.toString() ?? '0') ?? 0.0,
      discountSource: json['discount_source'] ?? 'NONE',
      notes: json['notes'],
      appointments: appts,
      branchName: branch?['name'],
      branchAddress: branch?['address'],
      branchImage: branch?['image'],
    );
  }
}
