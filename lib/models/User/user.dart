class User {
  final int id;
  String firstName;
  String lastName;
  String gender;
  String email;
  String phone;
  DateTime dateOfBirth;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['birth_date']),
      email: json['email'],
      phone: json['phone'],
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
    };
  }

  void update({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    this.firstName = firstName ?? this.firstName;
    this.lastName = lastName ?? this.lastName;
    this.phone = phone ?? this.phone;
    this.dateOfBirth = dateOfBirth ?? this.dateOfBirth;
    this.gender = gender ?? this.gender;
    this.email = email ?? this.email;
  }
}
