import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';

class ApiRoutes {
  static const String login = '/login';
  static const String users = '/users';
  static const String tokenValidation = '/validate-token';
  static const String branch = '/branches';
  static const String home = '/home';
}

// const apiUrl = 'https://recoverylab.thecodehaus.co/api';
const apiUrl = 'http://localhost:8000/api';

enum UserState { none, loading, active }

final headersProvider = Provider<HeadersProvider>(
  (ref) => HeadersProvider(ref),
);

class HeadersProvider {
  final Ref ref;

  HeadersProvider(this.ref);

  Map<String, String> get basic => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<Map<String, String>> get token async {
    final token = ref.read(userSessionProvider).token;

    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
