import 'membership_plan.dart';

class UserMembership {
  final int id;
  final int userId;
  final MembershipPlan? plan;
  final String startDate;
  final String endDate;
  final String status;
  final num freezeWeeksUsed;
  final String? freezeStartDate;
  final String? freezeEndDate;
  final bool autoRenew;

  UserMembership({
    required this.id,
    required this.userId,
    this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.freezeWeeksUsed,
    this.freezeStartDate,
    this.freezeEndDate,
    required this.autoRenew,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isFrozen => status == 'FROZEN';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';

  num? get freezeWeeksAllowed => plan?.freezeWeeks;
  num get freezeWeeksRemaining =>
      freezeWeeksAllowed != null ? freezeWeeksAllowed! - freezeWeeksUsed : 0;

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }
    num parseNum(dynamic v, num fallback) {
      if (v == null) return fallback;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? fallback;
    }
    String dateStr(dynamic v) {
      if (v == null) return '';
      if (v is DateTime) return v.toIso8601String().split('T').first;
      final s = v.toString();
      if (s.contains('T')) return s.split('T').first;
      return s;
    }
    return UserMembership(
        id: parseInt(json['id'], 0),
        userId: parseInt(json['user_id'], 0),
        plan: json['plan'] != null
            ? MembershipPlan.fromJson(json['plan'] as Map<String, dynamic>)
            : null,
        startDate: dateStr(json['start_date']),
        endDate: dateStr(json['end_date']),
        status: (json['status']?.toString()) ?? 'ACTIVE',
        freezeWeeksUsed: parseNum(json['freeze_weeks_used'], 0),
        freezeStartDate: json['freeze_start_date'] != null ? dateStr(json['freeze_start_date']) : null,
        freezeEndDate: json['freeze_end_date'] != null ? dateStr(json['freeze_end_date']) : null,
        autoRenew: json['auto_renew'] == true || json['auto_renew'] == 1,
      );
  }
}
