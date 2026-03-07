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

  factory MembershipBenefit.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    num? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }
    return MembershipBenefit(
        id: parseInt(json['id']) ?? 0,
        membershipPlanId: parseInt(json['membership_plan_id']) ?? 0,
        benefitType: (json['benefit_type']?.toString()) ?? 'DISCOUNT',
        targetType: (json['target_type']?.toString()) ?? 'GLOBAL',
        targetId: parseInt(json['target_id']),
        value: parseNum(json['value']),
        freeSessionsPerMonth: parseInt(json['free_sessions_per_month']),
        requiresBooking: json['requires_booking'] == true || json['requires_booking'] == 1,
      );
  }

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
