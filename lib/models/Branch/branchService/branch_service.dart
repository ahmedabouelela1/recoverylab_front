import 'package:recoverylab_front/models/Branch/branchService/service_durations.dart';

class BranchService {
  final int id;
  final int branchId;
  final int serviceId;
  final bool isOffered;
  final int defaultCapacity;
  final String specificInstructions;
  final List<ServiceDuration?> branchPricing;

  BranchService({
    required this.id,
    required this.branchId,
    required this.serviceId,
    required this.isOffered,
    required this.defaultCapacity,
    required this.specificInstructions,
    required this.branchPricing,
  });

  factory BranchService.fromJson(Map<String, dynamic> json) {
    return BranchService(
      id: json['id'],
      branchId: json['branch_id'],
      serviceId: json['service_id'],
      isOffered: json['is_offered'],
      defaultCapacity: json['default_capacity'],
      specificInstructions: json['specific_instructions'],
      branchPricing: json['branch_pricing'] != null
          ? (json['branch_pricing'] as List)
                .map((e) => e != null ? ServiceDuration.fromJson(e) : null)
                .toList()
          : [],
    );
  }
}
