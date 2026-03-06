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

    return ApiAppointment(
      id: json['id'],
      bookingId: json['booking_id'],
      serviceId: json['service_id'],
      duration: json['duration'],
      basePrice:
          double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      finalPrice:
          double.tryParse(json['final_price']?.toString() ?? '0') ?? 0.0,
      scheduledStart: DateTime.parse(json['scheduled_start']),
      scheduledEnd: DateTime.parse(json['scheduled_end']),
      participantCount: json['participant_count'] ?? 1,
      staffId: json['staff_id'],
      status: json['status'] ?? 'SCHEDULED',
      serviceName: service?['name'],
      serviceImage: service?['image'],
      staffFirstName: staff?['first_name'],
      staffLastName: staff?['last_name'],
      staffProfilePicture: staff?['profile_picture'],
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
