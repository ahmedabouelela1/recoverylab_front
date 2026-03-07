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
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      branchId: (json['branch_id'] is int) ? json['branch_id'] as int : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      serviceId: (json['service_id'] is int) ? json['service_id'] as int : int.tryParse(json['service_id']?.toString() ?? '0') ?? 0,
      isOffered: json['is_offered'] == true,
      defaultCapacity: (json['default_capacity'] is int) ? json['default_capacity'] as int : int.tryParse(json['default_capacity']?.toString() ?? '1') ?? 1,
      specificInstructions: json['specific_instructions']?.toString() ?? '',
      branchPricing: json['branch_pricing'] != null
          ? (json['branch_pricing'] as List)
                .map((e) => e != null ? ServiceDuration.fromJson(e as Map<String, dynamic>) : null)
                .toList()
          : [],
    );
  }
}
