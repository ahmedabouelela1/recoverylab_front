class PackageRule {
  final int id;
  final int packageId;
  final int serviceId;
  final String? serviceName;
  final int? numberOfSessions;
  final int durationMinutes;

  PackageRule({
    required this.id,
    required this.packageId,
    required this.serviceId,
    this.serviceName,
    this.numberOfSessions,
    required this.durationMinutes,
  });

  factory PackageRule.fromJson(Map<String, dynamic> json) => PackageRule(
        id: json['id'] as int,
        packageId: json['package_id'] as int,
        serviceId: json['service_id'] as int,
        serviceName: json['service_name'] as String?,
        numberOfSessions: json['number_of_sessions'] as int?,
        durationMinutes: json['duration_minutes'] as int,
      );
}
