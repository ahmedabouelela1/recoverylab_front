import 'package:recoverylab_front/models/Branch/services/service_category.dart';

class Service {
  final int id;
  final ServiceCategory category;
  final String name;
  final String description;
  final String image;
  final List<String?> includedIn;

  Service({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.image,
    this.includedIn = const [],
  });

  @override
  String toString() => name;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      category: ServiceCategory.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      includedIn:
          (json['included_in'] as List<dynamic>?)
              ?.map((item) => item as String?)
              .toList() ??
          [],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'category': category.toJson(),
  //     'name': name,
  //     'description': description,
  //     'image': image,
  //   };
  // }
}
