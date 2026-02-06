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
      employeeId: json['employee_id'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      branchId: json['branch_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: User.fromJson(json['user']),
    );
  }
}
