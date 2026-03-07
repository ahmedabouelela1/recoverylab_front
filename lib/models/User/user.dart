import 'package:recoverylab_front/models/Branch/branch/branch.dart';

class User {
  final int id;
  String firstName;
  String lastName;
  String gender;
  String email;
  String phone;
  DateTime dateOfBirth;
  int? branchId;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parseBirthDate(dynamic v) {
      if (v == null) return DateTime(1990, 1, 1);
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime(1990, 1, 1);
      }
    }
    return User(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: parseBirthDate(json['birth_date']),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      branchId: json['branch_id'] != null ? (json['branch_id'] is int ? json['branch_id'] as int : int.tryParse(json['branch_id']?.toString() ?? '') ?? 0) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'email': email,
      'phone': phone,
      'birth_date': dateOfBirth?.toIso8601String(),
      'branch_id': branchId,
    };
  }

  void update({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    int? branchId,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.phone = phone ?? this.phone;
    this.dateOfBirth = dateOfBirth ?? this.dateOfBirth;
    this.gender = gender ?? this.gender;
    this.email = email ?? this.email;
    this.branchId = branchId ?? this.branchId;
  }
}
