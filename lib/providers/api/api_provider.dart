import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:recoverylab_front/configurations/constants.dart';
import 'package:recoverylab_front/models/Branch/branch.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/providers/exception/exception_handling.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';

final apiProvider = Provider<ApiProvider>((ref) => ApiProvider(ref));

class ApiProvider {
  final Ref ref;
  ApiProvider(this.ref);

  Future<http.Response> basePost(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await ref.read(headersProvider).token;
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> baseGet(String endpoint) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await ref.read(headersProvider).token;
    final response = await http.get(url, headers: headers);
    return response;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['message'] ?? 'Server error');
    }
    if (decoded['success'] != true) {
      throw ApiException(decoded['message'] ?? 'Request failed');
    }
    return decoded;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await basePost(ApiRoutes.login, {
      'email': email,
      'password': password,
    });

    final decoded = _handleResponse(response);

    final authResponse = AuthResponse.fromJson(decoded);
    ref.read(userSessionProvider.notifier).login(authResponse);

    return authResponse;
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    final url = Uri.parse('$apiUrl${ApiRoutes.tokenValidation}');
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      return {'success': false, 'message': 'Invalid token'};
    }
  }

  Future<AuthResponse> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String gender,
    String password,
    String confirmPassword,
    String dateOfBirth,
    int branchId,
  ) async {
    final response = await basePost(ApiRoutes.users, {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'password': password,
      'password_confirmation': confirmPassword,
      'birth_date': dateOfBirth,
      'branch_id': branchId,
    });
    final decoded = _handleResponse(response);
    final authResponse = AuthResponse.fromJson(decoded);
    ref.read(userSessionProvider.notifier).login(authResponse);
    return authResponse;
  }

  Future<List<Branch>> getBranches() async {
    final response = await baseGet(ApiRoutes.branch);
    final decoded = _handleResponse(response);

    final branches = (decoded['data'] as List)
        .map((branchJson) => Branch.fromJson(branchJson))
        .toList();

    return branches;
  }
}
