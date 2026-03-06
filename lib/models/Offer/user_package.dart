import 'offer_package.dart';

class UserPackage {
  final int id;
  final int userId;
  final OfferPackage? package;
  final int creditsRemaining;
  final String? expiryDate;
  final String status;

  UserPackage({
    required this.id,
    required this.userId,
    this.package,
    required this.creditsRemaining,
    this.expiryDate,
    required this.status,
  });

  factory UserPackage.fromJson(Map<String, dynamic> json) {
    return UserPackage(
      id: json['id'],
      userId: json['user_id'],
      package: json['package'] != null
          ? OfferPackage.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      creditsRemaining: json['credits_remaining'] ?? 0,
      expiryDate: json['expiry_date'],
      status: json['status'] ?? 'ACTIVE',
    );
  }
}
