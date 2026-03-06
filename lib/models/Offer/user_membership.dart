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

  factory UserMembership.fromJson(Map<String, dynamic> json) => UserMembership(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        plan: json['plan'] != null
            ? MembershipPlan.fromJson(json['plan'] as Map<String, dynamic>)
            : null,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        status: json['status'] as String? ?? 'ACTIVE',
        freezeWeeksUsed: json['freeze_weeks_used'] as num? ?? 0,
        freezeStartDate: json['freeze_start_date'] as String?,
        freezeEndDate: json['freeze_end_date'] as String?,
        autoRenew: json['auto_renew'] as bool? ?? false,
      );
}
