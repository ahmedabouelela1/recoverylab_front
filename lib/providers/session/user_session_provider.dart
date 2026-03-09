import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recoverylab_front/configurations/constants.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/models/User/user.dart';

final userSessionProvider = ChangeNotifierProvider<UserSession>(
  (ref) => UserSession(ref),
);

class UserSession extends ChangeNotifier {
  final Ref ref;
  static const _storage = FlutterSecureStorage();

  UserState _state = UserState.loading;

  User? user;
  String? token;

  bool get isActive => _state == UserState.active;

  UserSession(this.ref);

  UserState get state => _state;

  void login(AuthResponse response) {
    if (response.data.user != null && response.data.token != null) {
      user = response.data.user;
      token = response.data.token;
      _state = UserState.active;
      notifyListeners();

      // Persist session so the user stays logged in across restarts.
      _storage.write(key: 'auth_token', value: token);
      _storage.write(key: 'user', value: jsonEncode(response.toJson()));
    } else {
      _state = UserState.none;
      notifyListeners();
    }
  }

  void setState(UserState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    token = null;
    _state = UserState.none;
    notifyListeners();

    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user'),
    ]);
  }

  void updateUser({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    int? branchId,
  }) {
    user?.update(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
      branchId: branchId,
    );
    _state = UserState.active;
    notifyListeners();
  }

  /// Replace session user with the one from API (e.g. after profile update).
  void setUser(User newUser) {
    user = newUser;
    _state = UserState.active;
    notifyListeners();
  }
}
