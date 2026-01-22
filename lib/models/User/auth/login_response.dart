import 'dart:convert';

import 'package:recoverylab_front/models/User/user.dart';

AuthResponse emptyFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String emptyToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  bool success;
  Data data;
  String message;

  AuthResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  AuthResponse copyWith({bool? success, Data? data, String? message}) =>
      AuthResponse(
        success: success ?? this.success,
        data: data ?? this.data,
        message: message ?? this.message,
      );

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json["success"] ?? true,
    data: Data.fromJson(json["data"]),
    message: json["message"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  String token;
  User user;

  Data({required this.token, required this.user});

  Data copyWith({String? token, User? user}) =>
      Data(token: token ?? this.token, user: user ?? this.user);

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(token: json["token"], user: User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}
