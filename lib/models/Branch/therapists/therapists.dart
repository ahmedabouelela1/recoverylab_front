class Therapist {
  final String id;
  final String name;
  final String role;
  final String image;
  final bool isFeatured;

  Therapist({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
    this.isFeatured = false,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'SPECIALIST',
      image: json['image'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}
