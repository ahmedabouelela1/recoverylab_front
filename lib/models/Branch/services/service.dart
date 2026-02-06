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

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      category: ServiceCategory.fromJson(json['category']),
      name: json['name'],
      description: json['description'],
      image: json['image'],
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
