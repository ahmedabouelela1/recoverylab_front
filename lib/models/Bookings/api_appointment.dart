class ApiAppointment {
  final int id;
  final int bookingId;
  final int? serviceId;
  final int? duration; // minutes
  final double basePrice;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final int participantCount;
  final int? staffId;
  final String status;
  final double finalPrice;
  final String? serviceName;
  final String? serviceImage;
  final String? staffFirstName;
  final String? staffLastName;
  final String? staffProfilePicture;

  const ApiAppointment({
    required this.id,
    required this.bookingId,
    this.serviceId,
    this.duration,
    required this.basePrice,
    required this.finalPrice,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.participantCount,
    this.staffId,
    required this.status,
    this.serviceName,
    this.serviceImage,
    this.staffFirstName,
    this.staffLastName,
    this.staffProfilePicture,
  });

  factory ApiAppointment.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>?;
    final staff = json['staff'] as Map<String, dynamic>?;

    DateTime parseDateTime(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return ApiAppointment(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingId: (json['booking_id'] is int) ? json['booking_id'] as int : int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      serviceId: json['service_id'] != null ? ((json['service_id'] is int) ? json['service_id'] as int : int.tryParse(json['service_id']?.toString() ?? '')) : null,
      duration: json['duration'] != null ? ((json['duration'] is int) ? json['duration'] as int : int.tryParse(json['duration']?.toString() ?? '')) : null,
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      finalPrice: double.tryParse(json['final_price']?.toString() ?? '0') ?? 0.0,
      scheduledStart: parseDateTime(json['scheduled_start']),
      scheduledEnd: parseDateTime(json['scheduled_end']),
      participantCount: (json['participant_count'] is int) ? json['participant_count'] as int : int.tryParse(json['participant_count']?.toString() ?? '1') ?? 1,
      staffId: json['staff_id'] != null ? ((json['staff_id'] is int) ? json['staff_id'] as int : int.tryParse(json['staff_id']?.toString() ?? '')) : null,
      status: json['status']?.toString() ?? 'SCHEDULED',
      serviceName: service?['name']?.toString(),
      serviceImage: service?['image']?.toString(),
      staffFirstName: staff?['first_name']?.toString(),
      staffLastName: staff?['last_name']?.toString(),
      staffProfilePicture: staff?['profile_picture']?.toString(),
    );
  }

  String get staffFullName {
    if (staffFirstName == null && staffLastName == null) return 'Any Available';
    return '${staffFirstName ?? ''} ${staffLastName ?? ''}'.trim();
  }

  String get durationLabel {
    if (duration == null) return '—';
    final h = duration! ~/ 60;
    final m = duration! % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  String get scheduledDateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[scheduledStart.month - 1]} ${scheduledStart.day}, ${scheduledStart.year}';
  }

  String get scheduledTimeLabel {
    final h = scheduledStart.hour;
    final m = scheduledStart.minute;
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final displayM = m.toString().padLeft(2, '0');
    return '$displayH:$displayM $period';
  }

  bool get isActive =>
      status == 'SCHEDULED' ||
      status == 'CHECKED_IN' ||
      status == 'IN_PROGRESS';

  bool get isDone => status == 'COMPLETED';

  bool get isCancelled => status == 'CANCELLED' || status == 'NO_SHOW';
}
