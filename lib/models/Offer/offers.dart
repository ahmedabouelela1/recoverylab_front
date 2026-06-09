class Offers {
  final int id;
  final String title;
  final String description;
  final String image;
  String? discount;
  final int? branchId;
  /// Long copy for the full-screen offer detail only (not sent on home carousel).
  final String? bigDescription;

  // Structured promotional offer fields
  final String? startDate;      // YYYY-MM-DD
  final String? endDate;        // YYYY-MM-DD
  final bool isActive;
  final String? discountType;   // PERCENTAGE | FIXED
  final num? discountValue;
  final String? targetType;     // ALL | SERVICE | SERVICE_CATEGORY | PACKAGE
  final int? targetId;
  final String? ctaLabel;

  Offers({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.discount,
    this.branchId,
    this.bigDescription,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.discountType,
    this.discountValue,
    this.targetType,
    this.targetId,
    this.ctaLabel,
  });

  factory Offers.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    int? parseOpt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    num? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    return Offers(
      id: parseId(json['id']),
      title: json['title'] as String? ?? '',
      description: (json['description'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      discount: json['discount'] as String?,
      branchId: parseOpt(json['branch_id']),
      bigDescription: json['big_description'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1'),
      discountType: json['discount_type'] as String?,
      discountValue: parseNum(json['discount_value']),
      targetType: json['target_type'] as String?,
      targetId: parseOpt(json['target_id']),
      ctaLabel: json['cta_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'discount': discount,
      'branch_id': branchId,
      'big_description': bigDescription,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'discount_type': discountType,
      'discount_value': discountValue,
      'target_type': targetType,
      'target_id': targetId,
      'cta_label': ctaLabel,
    };
  }

  /// Returns a human-readable discount label like "10% OFF" or "50 EGP OFF".
  String? get discountBadge {
    if (discountValue == null || discountValue == 0) {
      // Fall back to legacy string field
      return discount?.isNotEmpty == true ? discount : null;
    }
    if (discountType == 'FIXED') {
      return '${discountValue!.toStringAsFixed(discountValue! % 1 == 0 ? 0 : 2)} EGP OFF';
    }
    final pct = discountValue!.toStringAsFixed(discountValue! % 1 == 0 ? 0 : 1);
    return '$pct% OFF';
  }

  bool matchesBranch(int? branchId) {
    if (this.branchId == null || branchId == null) return true;
    return this.branchId == branchId;
  }

  /// Whether the offer is active and today falls within its start/end window.
  /// Mirrors the backend gating in `resolveActiveOffer()` so the app never
  /// shows or applies an expired, not-yet-started, or inactive offer.
  bool get isCurrentlyValid {
    if (!isActive) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final start = startDate != null ? DateTime.tryParse(startDate!) : null;
    if (start != null) {
      final s = DateTime(start.year, start.month, start.day);
      if (today.isBefore(s)) return false;
    }

    final end = endDate != null ? DateTime.tryParse(endDate!) : null;
    if (end != null) {
      final e = DateTime(end.year, end.month, end.day);
      if (today.isAfter(e)) return false;
    }

    return true;
  }

  /// Whether this offer applies to a single-service booking.
  bool appliesToService({
    required int serviceId,
    required int categoryId,
    int? branchId,
  }) {
    if (!isCurrentlyValid) return false;
    if (!matchesBranch(branchId)) return false;
    final target = targetType ?? 'ALL';
    switch (target) {
      case 'SERVICE':
        return targetId == serviceId;
      case 'SERVICE_CATEGORY':
        return targetId == categoryId;
      case 'PACKAGE':
        return false;
      default:
        return true;
    }
  }

  /// Whether this offer applies to a combo (PACKAGE) booking.
  bool appliesToCombo({required int comboId, int? branchId}) {
    if (!isCurrentlyValid) return false;
    if (!matchesBranch(branchId)) return false;
    final target = targetType ?? 'ALL';
    switch (target) {
      case 'ALL':
        return true;
      case 'PACKAGE':
        return targetId == null || targetId == comboId;
      default:
        return false;
    }
  }

  /// Discount percentage (0–100) for a unit price (matches backend offer logic).
  double discountPercentForUnitPrice(double unitPrice) {
    if (discountValue == null || discountValue! <= 0) return 0;
    if (discountType == 'FIXED') {
      if (unitPrice <= 0) return 0;
      final pct = discountValue! / unitPrice * 100;
      return pct > 100 ? 100 : pct.toDouble();
    }
    final pct = discountValue!.toDouble();
    return pct > 100 ? 100 : pct;
  }

  double applyDiscountToAmount(double amount) {
    if (amount <= 0) return amount;
    final pct = discountPercentForUnitPrice(amount);
    if (discountType == 'FIXED' && discountValue != null) {
      return (amount - discountValue!.toDouble()).clamp(0, amount).toDouble();
    }
    return amount * (1 - pct / 100);
  }

  /// Returns "Valid until May 15" or null if no end date.
  String? get validityLabel {
    if (endDate == null) return null;
    try {
      final parts = endDate!.split('-');
      if (parts.length != 3) return null;
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final month = int.tryParse(parts[1]) ?? 0;
      final day = int.tryParse(parts[2]) ?? 0;
      if (month < 1 || month > 12) return null;
      return 'Valid until ${months[month]} $day';
    } catch (_) {
      return null;
    }
  }
}
