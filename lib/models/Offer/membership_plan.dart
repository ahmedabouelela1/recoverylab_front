import 'membership_benefit.dart';

class MembershipPlan {
  final int id;
  final String name;
  final String? description;
  final int durationMonths;
  final num price;
  final bool isActive;
  final num? freezeWeeks;
  final List<MembershipBenefit> benefits;

  MembershipPlan({
    required this.id,
    required this.name,
    this.description,
    required this.durationMonths,
    required this.price,
    required this.isActive,
    this.freezeWeeks,
    required this.benefits,
  });

  /// Best discount benefit value (%), or null if none.
  num? get bestDiscountPercent {
    final discounts = benefits
        .where((b) => b.benefitType == 'DISCOUNT' && b.value != null)
        .map((b) => b.value!);
    if (discounts.isEmpty) return null;
    return discounts.reduce((a, b) => a > b ? a : b);
  }

  bool get hasUnlimitedAccess =>
      benefits.any((b) => b.benefitType == 'UNLIMITED_ACCESS');

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }
    int parseInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }
    return MembershipPlan(
        id: parseInt(json['id'], 0),
        name: (json['name']?.toString()) ?? '',
        description: json['description']?.toString(),
        durationMonths: parseInt(json['duration_months'], 12),
        price: parseNum(json['price']) ?? 0,
        isActive: json['is_active'] == true || json['is_active'] == 1,
        freezeWeeks: parseNum(json['freeze_weeks']),
        benefits: (json['benefits'] as List<dynamic>? ?? [])
            .map((b) => MembershipBenefit.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
  }
}
