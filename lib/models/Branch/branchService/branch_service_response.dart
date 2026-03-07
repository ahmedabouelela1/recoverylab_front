// branch_service_model.dart

import 'package:recoverylab_front/models/Branch/branchService/branch_service.dart';
import 'package:recoverylab_front/models/Branch/staff/staff.dart';

class BranchServiceResponse {
  final bool success;
  final String message;
  final List<BranchService> data;
  final List<Staff?> staff;

  BranchServiceResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.staff,
  });

  factory BranchServiceResponse.fromJson(Map<String, dynamic> json) {
    return BranchServiceResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: (json['data'] is List)
          ? (json['data'] as List)
              .map((e) => BranchService.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      staff: json['staff_qualified_for_service'] != null
          ? (json['staff_qualified_for_service'] as List)
                .map<Staff?>((e) => e != null ? Staff.fromJson(e as Map<String, dynamic>) : null)
                .toList()
          : <Staff?>[],
    );
  }
}
