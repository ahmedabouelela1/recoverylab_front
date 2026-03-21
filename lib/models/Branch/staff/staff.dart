import 'package:recoverylab_front/models/User/user.dart';

class Staff {
  /// Backend staff primary key (therapists are not linked to app users).
  final int id;
  final String employeeId;
  final String bio;
  final String profilePicture;
  final int branchId;
  final String createdAt;
  final String updatedAt;
  final User user;

  Staff({
    required this.id,
    required this.employeeId,
    required this.bio,
    required this.profilePicture,
    required this.branchId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    final staffId = (json['id'] is int)
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final userJson = json['user'];
    User user;
    if (userJson is Map<String, dynamic>) {
      user = User.fromJson(userJson);
    } else {
      user = User(
        id: staffId,
        firstName: json['first_name']?.toString() ?? '',
        lastName: json['last_name']?.toString() ?? '',
        gender: json['gender']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        dateOfBirth: DateTime(1990, 1, 1),
      );
    }

    return Staff(
      id: staffId,
      employeeId: json['employee_id']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      branchId: (json['branch_id'] is int)
          ? json['branch_id'] as int
          : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      user: user,
    );
  }
}
