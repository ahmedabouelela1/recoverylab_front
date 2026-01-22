class Branch {
  final int id;
  final String name;
  final String address;
  final String mapsUrl;
  final String image;
  final String phone;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.mapsUrl,
    required this.image,
    required this.phone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      mapsUrl: json['maps_url'],
      image: json['image'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'maps_url': mapsUrl,
      'image': image,
      'phone': phone,
    };
  }
}
