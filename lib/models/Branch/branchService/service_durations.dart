class ServiceDuration {
  final int minutes;
  final String price;
  final String? description;

  ServiceDuration({
    required this.minutes,
    required this.price,
    this.description,
  });

  factory ServiceDuration.fromJson(Map<String, dynamic> json) {
    return ServiceDuration(
      minutes: json['duration_minutes'] ?? 0,
      price: json['price'] ?? '0',
      description: json['description'],
    );
  }
}
