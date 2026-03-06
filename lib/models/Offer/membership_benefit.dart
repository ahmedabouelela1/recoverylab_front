class MembershipBenefit {
  final int id;
  final int membershipPlanId;
  final String benefitType; // 'UNLIMITED_ACCESS' | 'DISCOUNT' | 'FREE_SESSIONS'
  final String targetType; // 'SERVICE' | 'CATEGORY' | 'ALL'
  final int? targetId;
  final num? value; // discount percentage for DISCOUNT type
  final int? freeSessionsPerMonth;
  final bool requiresBooking;

  MembershipBenefit({
    required this.id,
    required this.membershipPlanId,
    required this.benefitType,
    required this.targetType,
    this.targetId,
    this.value,
    this.freeSessionsPerMonth,
    required this.requiresBooking,
  });

  factory MembershipBenefit.fromJson(Map<String, dynamic> json) =>
      MembershipBenefit(
        id: json['id'] as int,
        membershipPlanId: json['membership_plan_id'] as int,
        benefitType: json['benefit_type'] as String,
        targetType: json['target_type'] as String,
        targetId: json['target_id'] as int?,
        value: json['value'] as num?,
        freeSessionsPerMonth: json['free_sessions_per_month'] as int?,
        requiresBooking: (json['requires_booking'] as bool?) ?? false,
      );

  String get displayLabel {
    switch (benefitType) {
      case 'UNLIMITED_ACCESS':
        return 'Unlimited Access';
      case 'DISCOUNT':
        return value != null ? '${value!.toInt()}% Off' : 'Discount';
      case 'FREE_SESSIONS':
        return freeSessionsPerMonth != null
            ? '$freeSessionsPerMonth Free Session${freeSessionsPerMonth! > 1 ? 's' : ''}/month'
            : 'Free Sessions';
      default:
        return benefitType;
    }
  }
}
