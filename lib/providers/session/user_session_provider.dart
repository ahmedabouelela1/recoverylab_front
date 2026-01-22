import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:recoverylab_front/configurations/constants.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/models/User/user.dart';

final userSessionProvider = ChangeNotifierProvider<UserSession>(
  (ref) => UserSession(ref),
);

class UserSession extends ChangeNotifier {
  final Ref ref; // ✅ Corrected Ref

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
    } else {
      _state = UserState.none;
      notifyListeners();
    }
  }

  void setState(UserState newState) {
    _state = newState;
    notifyListeners(); // ✅ Fix
  }

  void logout() {
    user = null;
    token = null;
    _state = UserState.none;
    notifyListeners();
  }

  // void changeProfilePic(String newProfilePic) {
  //   user?.update(profilePic: newProfilePic);
  //   _state = UserState.active;
  //   notifyListeners();
  // }

  void updateUser({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    user?.update(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
    _state = UserState.active;
    notifyListeners();
  }
}
