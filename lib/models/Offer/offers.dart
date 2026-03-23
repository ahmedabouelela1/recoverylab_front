class Offers {
  final int id;
  final String title;
  final String description;
  final String image;
  String? discount;
  final int? branchId;
  /// Long copy for the full-screen offer detail only (not sent on home carousel).
  final String? bigDescription;

  Offers({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.discount,
    this.branchId,
    this.bigDescription,
  });

  factory Offers.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    int? parseOpt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Offers(
      id: parseId(json['id']),
      title: json['title'] as String? ?? '',
      description: (json['description'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      discount: json['discount'] as String?,
      branchId: parseOpt(json['branch_id']),
      bigDescription: json['big_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'discount': discount,
      'branch_id': branchId,
      'big_description': bigDescription,
    };
  }
}
