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
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      mapsUrl: json['maps_url']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
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
