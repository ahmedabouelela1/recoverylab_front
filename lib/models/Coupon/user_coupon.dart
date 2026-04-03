class Coupon {
  final int id;
  final String code;
  final String type; // DISCOUNT_PERCENTAGE | DISCOUNT_AMOUNT | GIFT_CARD | GIFT_SESSION
  final double value;
  final double? percentage;
  final double? maxDiscountAmount;
  final int? serviceId;
  final int? durationMinutes;
  final String? expiresAt;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.percentage,
    this.maxDiscountAmount,
    this.serviceId,
    this.durationMinutes,
    this.expiresAt,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json['id'] as int,
        code: json['code'] as String,
        type: json['type'] as String,
        value: (json['value'] as num).toDouble(),
        percentage: json['percentage'] != null
            ? (json['percentage'] as num).toDouble()
            : null,
        maxDiscountAmount: json['max_discount_amount'] != null
            ? (json['max_discount_amount'] as num).toDouble()
            : null,
        serviceId: json['service_id'] as int?,
        durationMinutes: json['duration_minutes'] as int?,
        expiresAt: json['expires_at'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  /// Human-readable discount label for UI display
  String get discountLabel {
    switch (type) {
      case 'DISCOUNT_PERCENTAGE':
        final pct = percentage?.toStringAsFixed(0) ?? '?';
        return '$pct% off';
      case 'DISCOUNT_AMOUNT':
        return 'E£${value.toStringAsFixed(0)} off';
      case 'GIFT_CARD':
        return 'E£${value.toStringAsFixed(0)} gift card';
      case 'GIFT_SESSION':
        return 'Free session';
      default:
        return 'Discount';
    }
  }
}

class UserCoupon {
  final int id;
  final String status; // ACTIVE | USED | EXPIRED
  final Coupon coupon;
  final String? usedAt;
  final int? giftedByUserId;

  const UserCoupon({
    required this.id,
    required this.status,
    required this.coupon,
    this.usedAt,
    this.giftedByUserId,
  });

  factory UserCoupon.fromJson(Map<String, dynamic> json) => UserCoupon(
        id: json['id'] as int,
        status: json['status'] as String,
        coupon: Coupon.fromJson(json['coupon'] as Map<String, dynamic>),
        usedAt: json['used_at'] as String?,
        giftedByUserId: json['gifted_by_user_id'] as int?,
      );
}
