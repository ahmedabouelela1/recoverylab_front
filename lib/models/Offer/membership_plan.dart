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

  factory MembershipPlan.fromJson(Map<String, dynamic> json) => MembershipPlan(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        durationMonths: json['duration_months'] as int,
        price: json['price'] as num,
        isActive: (json['is_active'] as bool?) ?? true,
        freezeWeeks: json['freeze_weeks'] as num?,
        benefits: (json['benefits'] as List<dynamic>? ?? [])
            .map((b) => MembershipBenefit.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
