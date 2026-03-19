class PackageRule {
  final int id;
  final int packageId;
  final int? serviceCategoryId;
  final String? serviceCategoryName;
  final int? serviceId;
  final String? serviceName;
  final int? numberOfSessions;
  final int durationMinutes;

  PackageRule({
    required this.id,
    required this.packageId,
    this.serviceCategoryId,
    this.serviceCategoryName,
    this.serviceId,
    this.serviceName,
    this.numberOfSessions,
    this.durationMinutes = 60,
  });

  /// True when user must pick a specific service from the category at booking time.
  bool get isCategoryChoice => serviceCategoryId != null && serviceId == null;

  factory PackageRule.fromJson(Map<String, dynamic> json) => PackageRule(
        id: json['id'] as int,
        packageId: json['package_id'] as int,
        serviceCategoryId: json['service_category_id'] as int?,
        serviceCategoryName: json['service_category_name'] as String?,
        serviceId: json['service_id'] as int?,
        serviceName: json['service_name'] as String?,
        numberOfSessions: json['number_of_sessions'] as int?,
        durationMinutes: json['duration_minutes'] as int? ?? 60,
      );
}
