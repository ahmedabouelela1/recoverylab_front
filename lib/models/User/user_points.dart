class PointTransaction {
  final int id;
  final int points;
  final String type; // EARN | REDEEM
  final String? referenceType;
  final int? referenceId;
  final String? description;
  final String createdAt;

  PointTransaction({
    required this.id,
    required this.points,
    required this.type,
    this.referenceType,
    this.referenceId,
    this.description,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as int,
      points: json['points'] as int,
      type: json['type'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class UserPoints {
  final int pointsBalance;
  final int redeemableNow;
  final List<PointTransaction> transactions;

  UserPoints({
    required this.pointsBalance,
    required this.redeemableNow,
    required this.transactions,
  });

  factory UserPoints.fromJson(Map<String, dynamic> json) {
    final txList = (json['transactions'] as List<dynamic>? ?? [])
        .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
    return UserPoints(
      pointsBalance: json['points_balance'] as int? ?? 0,
      redeemableNow: json['redeemable_now'] as int? ?? 0,
      transactions: txList,
    );
  }

  double get redeemableEgp => redeemableNow / 100.0;
}
