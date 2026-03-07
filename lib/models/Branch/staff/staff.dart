import 'package:recoverylab_front/models/User/user.dart';

class Staff {
  final String employeeId;
  final String bio;
  final String profilePicture;
  final int branchId;
  final String createdAt;
  final String updatedAt;
  final User user;

  Staff({
    required this.employeeId,
    required this.bio,
    required this.profilePicture,
    required this.branchId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      employeeId: json['employee_id']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      branchId: (json['branch_id'] is int) ? json['branch_id'] as int : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
