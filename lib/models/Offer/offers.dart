class Offers {
  final int id;
  final String title;
  final String description;
  final String image;
  String? discount;

  Offers({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.discount,
  });

  factory Offers.fromJson(Map<String, dynamic> json) {
    return Offers(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      discount: json['discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'discount': discount,
    };
  }
}
