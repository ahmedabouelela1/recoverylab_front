class ApiVoucher {
  final int id;
  final int branchId;
  final String? branchName;
  final String name;
  final String? message;
  final String productType;
  final int? serviceId;
  final String? serviceName;
  final int? durationMinutes;
  final int? packageId;
  final String? packageName;
  final double? price;
  final String status;
  final String? recipientEmail;
  final String? recipientPhone;
  final String? confirmedAt;
  final String? paidAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? createdAt;

  const ApiVoucher({
    required this.id,
    required this.branchId,
    this.branchName,
    required this.name,
    this.message,
    required this.productType,
    this.serviceId,
    this.serviceName,
    this.durationMinutes,
    this.packageId,
    this.packageName,
    this.price,
    required this.status,
    this.recipientEmail,
    this.recipientPhone,
    this.confirmedAt,
    this.paidAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
  });

  factory ApiVoucher.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final branch = json['branch'] as Map<String, dynamic>?;
    final pkg = product['package'] as Map<String, dynamic>?;
    final svc = product['service'] as Map<String, dynamic>?;

    return ApiVoucher(
      id: json['id'] as int,
      branchId: json['branch_id'] as int,
      branchName: branch?['name'] as String?,
      name: json['name'] as String,
      message: json['message'] as String?,
      productType: (product['type'] ?? json['product_type'] ?? 'SERVICE').toString(),
      serviceId: (svc?['id'] ?? product['service_id']) as int?,
      serviceName: svc?['name'] as String?,
      durationMinutes: (product['duration_minutes'] as num?)?.toInt(),
      packageId: (pkg?['id'] ?? product['package_id']) as int?,
      packageName: pkg?['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      status: json['status'] as String,
      recipientEmail: json['recipient_email'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      confirmedAt: json['confirmed_at'] as String?,
      paidAt: json['paid_at'] as String?,
      completedAt: json['completed_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'REQUESTED':
        return 'Requested';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PAID':
        return 'Paid';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get productSummary {
    if (productType == 'SERVICE' && serviceId != null) {
      final name = serviceName ?? 'Service';
      final d = durationMinutes != null ? ' · ${durationMinutes}m' : '';
      return '$name$d';
    }
    if (packageName != null && packageName!.isNotEmpty) {
      return packageName!;
    }
    if (packageId != null) {
      return '${productType.toLowerCase()} #$packageId';
    }
    return productType;
  }
}
