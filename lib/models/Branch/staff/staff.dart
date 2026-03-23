class Staff {
  /// Backend staff primary key (therapists are not linked to app users).
  final int id;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String bio;
  final String profilePicture;
  final int branchId;
  final String createdAt;
  final String updatedAt;

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.bio,
    required this.profilePicture,
    required this.branchId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  factory Staff.fromJson(Map<String, dynamic> json) {
    final staffId = (json['id'] is int)
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    return Staff(
      id: staffId,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? '',
      branchId: (json['branch_id'] is int)
          ? json['branch_id'] as int
          : int.tryParse(json['branch_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
