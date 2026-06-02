import 'package_rule.dart';

class OfferPackage {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String type; // 'PACKAGE' | 'COMBO'
  final num price;
  final num? discountPercentage;
  final int? totalCredits;
  final int? validityDays;
  final bool isActive;
  final List<PackageRule> rules;
  /// When set, this session-credit package only applies to this service + duration.
  final int? serviceId;
  final int? durationMinutes;
  final String? serviceName;
  /// COMBO only: services the user cannot choose for category-based slots.
  final List<int> excludedServiceIds;
  /// COMBO only: if true, hidden from the public combos catalog — only reachable via a special offer CTA.
  final bool isOfferOnly;

  OfferPackage({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.type,
    required this.price,
    this.discountPercentage,
    this.totalCredits,
    this.validityDays,
    required this.isActive,
    required this.rules,
    this.serviceId,
    this.durationMinutes,
    this.serviceName,
    this.excludedServiceIds = const [],
    this.isOfferOnly = false,
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
        image: json['image'] as String?,
        type: json['type'] as String,
        price: json['price'] as num,
        discountPercentage: json['discount_percentage'] as num?,
        totalCredits: json['total_credits'] as int?,
        validityDays: json['validity_days'] as int?,
        isActive: (json['is_active'] as bool?) ?? true,
        rules: (json['rules'] as List<dynamic>? ?? [])
            .map((r) => PackageRule.fromJson(r as Map<String, dynamic>))
            .toList(),
        serviceId: json['service_id'] as int?,
        durationMinutes: json['duration_minutes'] as int?,
        serviceName: json['service_name'] as String?,
        excludedServiceIds: (json['excluded_service_ids'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [],
        isOfferOnly: json['is_offer_only'] == true || json['is_offer_only'] == 1,
      );
}
