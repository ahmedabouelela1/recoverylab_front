class ServiceCategory {
  final int id;
  final String name;
  final String description;
  final String image;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'image': image};
  }
}
