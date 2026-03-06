import 'package_rule.dart';

class OfferPackage {
  final int id;
  final String name;
  final String? description;
  final String type; // 'PACKAGE' | 'COMBO'
  final num price;
  final num? discountPercentage;
  final int? totalCredits;
  final int? validityDays;
  final bool isActive;
  final List<PackageRule> rules;

  OfferPackage({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.price,
    this.discountPercentage,
    this.totalCredits,
    this.validityDays,
    required this.isActive,
    required this.rules,
  });

  bool get isCombo => type == 'COMBO';
  bool get isPackage => type == 'PACKAGE';

  /// Total duration across all combo rules (minutes).
  int get totalDurationMinutes =>
      rules.fold(0, (sum, r) => sum + r.durationMinutes);

  factory OfferPackage.fromJson(Map<String, dynamic> json) => OfferPackage(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        type: json['type'] as String,
        price: json['price'] as num,
        discountPercentage: json['discount_percentage'] as num?,
        totalCredits: json['total_credits'] as int?,
        validityDays: json['validity_days'] as int?,
        isActive: (json['is_active'] as bool?) ?? true,
        rules: (json['rules'] as List<dynamic>? ?? [])
            .map((r) => PackageRule.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
