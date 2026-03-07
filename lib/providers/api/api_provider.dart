import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:recoverylab_front/configurations/constants.dart';
import 'package:recoverylab_front/models/Bookings/api_booking.dart';
import 'package:recoverylab_front/models/Branch/branch/branch.dart';
import 'package:recoverylab_front/models/Branch/branchService/branch_service_response.dart';
import 'package:recoverylab_front/models/Branch/services/service.dart';
import 'package:recoverylab_front/models/Branch/services/service_category.dart';
import 'package:recoverylab_front/models/Branch/branch/branch_schedule.dart';
import 'package:recoverylab_front/models/Offer/offer_package.dart';
import 'package:recoverylab_front/models/Offer/membership_plan.dart';
import 'package:recoverylab_front/models/Offer/user_membership.dart';
import 'package:recoverylab_front/models/Offer/user_package.dart';
import 'package:recoverylab_front/models/Offer/offers.dart';
import 'package:recoverylab_front/models/Offer/recommended.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/models/User/user.dart';
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

  Future<http.Response> basePatch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await ref.read(headersProvider).token;
    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> basePut(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiUrl$endpoint');
    final headers = await ref.read(headersProvider).token;
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
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

  /// GET /branches/{id}/schedule — public, returns weekly hours + special dates.
  Future<BranchSchedule> getBranchSchedule(int branchId) async {
    final url = Uri.parse('$apiUrl${ApiRoutes.branch}/$branchId/schedule');
    final headers = ref.read(headersProvider).basic;
    final response = await http.get(url, headers: headers);
    final decoded = _handleResponse(response);
    return BranchSchedule.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<List<Branch>> getBranches() async {
    final response = await baseGet(ApiRoutes.branch);
    final decoded = _handleResponse(response);

    final branches = (decoded['data'] as List)
        .map((branchJson) => Branch.fromJson(branchJson))
        .toList();

    return branches;
  }

  Future<Map<String, dynamic>> gethome() async {
    final response = await baseGet(ApiRoutes.home);
    final decoded = _handleResponse(response);

    final data = decoded['data'] as Map<String, dynamic>? ?? {};

    // Parse Offers
    final offersJson = data['offers'] as List<dynamic>? ?? [];
    final List<Offers> offers = offersJson
        .map((json) => Offers.fromJson(json))
        .toList();

    // Parse Categories
    final categoriesJson = data['categories'] as List<dynamic>? ?? [];
    final List<ServiceCategory> categories = categoriesJson
        .map((json) => ServiceCategory.fromJson(json))
        .toList();

    // Parse Recommended
    final recommendedJson = data['recommended'] as List<dynamic>? ?? [];
    final List<Recommended> recommended = recommendedJson
        .map((json) => Recommended.fromJson(json))
        .toList();

    // Replace raw lists with typed objects
    data['offers'] = offers;
    data['categories'] = categories;
    data['recommended'] = recommended;

    // Return same structure, but with typed objects
    decoded['data'] = data;
    return decoded;
  }

  Future<List<Service?>> getServicesByCategory(int categoryId) async {
    final response = await baseGet('${ApiRoutes.categoryServices}/$categoryId');
    final decoded = _handleResponse(response);

    final services = (decoded['data'] as List)
        .map((serviceJson) => Service.fromJson(serviceJson))
        .toList();

    return services;
  }

  Future<BranchServiceResponse?> getBranchService({
    required int branchId,
    required int serviceId,
  }) async {
    final response = await baseGet(
      '${ApiRoutes.branchServices}/$branchId/$serviceId',
    );
    final decoded = _handleResponse(response);

    return BranchServiceResponse.fromJson(decoded);
  }

  Future<List<ApiBooking>> getBookings() async {
    final response = await baseGet(ApiRoutes.booking);
    final decoded = _handleResponse(response);

    // Handle both plain list and paginated { data: [...] } shapes
    final raw = decoded['data'];
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((j) => ApiBooking.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelAppointment(int appointmentId) async {
    final response = await basePatch(
      '${ApiRoutes.appointments}/$appointmentId/status',
      {'status': 'CANCELLED'},
    );
    _handleResponse(response);
  }

  /// PUT /users — update current user profile. Updates session with returned user.
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    final response = await basePut(ApiRoutes.users, {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
    });
    final decoded = _handleResponse(response);
    final userData = decoded['data'] as Map<String, dynamic>?;
    if (userData != null) {
      ref.read(userSessionProvider.notifier).setUser(User.fromJson(userData));
    }
  }

  /// GET /packages — optionally filter by type ('PACKAGE' or 'COMBO').
  Future<List<OfferPackage>> getPackages({String? type}) async {
    final endpoint = type != null
        ? '${ApiRoutes.packages}?type=$type'
        : ApiRoutes.packages;
    final response = await baseGet(endpoint);
    final decoded = _handleResponse(response);

    final raw = decoded['data'];
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((j) => OfferPackage.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// GET /membership-plans
  Future<List<MembershipPlan>> getMembershipPlans() async {
    final response = await baseGet(ApiRoutes.membershipPlans);
    final decoded = _handleResponse(response);

    final raw = decoded['data'];
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((j) => MembershipPlan.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// POST /user-packages — purchase a PACKAGE type bundle.
  Future<Map<String, dynamic>> purchasePackage({
    required int userId,
    required int packageId,
  }) async {
    final response = await basePost(ApiRoutes.userPackages, {
      'user_id': userId,
      'package_id': packageId,
      'purchased_via': 'SELF_SERVICE',
    });
    return _handleResponse(response);
  }

  /// POST /user-memberships — subscribe to a membership plan.
  Future<Map<String, dynamic>> purchaseMembership({
    required int userId,
    required int membershipPlanId,
    required String startDate, // 'YYYY-MM-DD'
  }) async {
    final response = await basePost(ApiRoutes.userMemberships, {
      'user_id': userId,
      'membership_plan_id': membershipPlanId,
      'start_date': startDate,
    });
    return _handleResponse(response);
  }

  /// GET /user-packages — returns active packages with remaining credits.
  Future<List<UserPackage>> getMyPackages() async {
    final response = await baseGet(ApiRoutes.userPackages);
    final decoded = _handleResponse(response);

    final raw = decoded['data'];
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }

    return list
        .map((j) => UserPackage.fromJson(j as Map<String, dynamic>))
        .where((p) => p.status == 'ACTIVE' && p.creditsRemaining > 0)
        .toList();
  }

  Future<Map<String, dynamic>> storeBooking({
    required int userId,
    required int branchId,
    required int serviceId,
    required String formattedDateTime,
    required int durationMinutes,
    required int participantCount,
    int? staffId,
    String? notes,
    required String paymentMethod,
    int? usePackageId,
  }) async {
    final Map<String, dynamic> body = {
      'user_id': userId,
      'branch_id': branchId,
      'notes': notes?.isEmpty ?? true ? null : notes,
      'appointments': [
        {
          'service_id': serviceId,
          'duration_minutes': durationMinutes,
          'scheduled_start': formattedDateTime,
          'participant_count': participantCount,
          'staff_id': staffId,
        },
      ],
      'payment_method': paymentMethod,
    };

    if (usePackageId != null) {
      body['use_package_id'] = usePackageId;
    }

    final response = await basePost(ApiRoutes.booking, body);
    return _handleResponse(response);
  }

  /// GET /user-memberships — returns memberships for the current user.
  Future<List<UserMembership>> getMyMemberships() async {
    final userId = ref.read(userSessionProvider).user?.id;
    final endpoint = userId != null
        ? '${ApiRoutes.userMemberships}?user_id=$userId'
        : ApiRoutes.userMemberships;
    final response = await baseGet(endpoint);
    final decoded = _handleResponse(response);
    final raw = decoded['data'];
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw.containsKey('data')) {
      list = raw['data'] as List<dynamic>;
    } else {
      list = [];
    }
    return list
        .map((j) => UserMembership.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /user-memberships/{id}/freeze
  Future<void> freezeMembership(int id, int weeks) async {
    final response = await basePatch(
      '${ApiRoutes.userMemberships}/$id/freeze',
      {'freeze_weeks': weeks},
    );
    _handleResponse(response);
  }

  /// PATCH /user-memberships/{id}/unfreeze
  Future<void> unfreezeMembership(int id) async {
    final response = await basePatch(
      '${ApiRoutes.userMemberships}/$id/unfreeze',
      {},
    );
    _handleResponse(response);
  }

  /// GET /bookings/{id} — fetch a single booking with latest appointment statuses.
  Future<ApiBooking> getBooking(int id) async {
    final response = await baseGet('${ApiRoutes.booking}/$id');
    final decoded = _handleResponse(response);
    return ApiBooking.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  /// GET /user-answers/{userId} — returns existing answers grouped by question_id.
  Future<Map<int, List<Map<String, dynamic>>>> getUserAnswers(int userId) async {
    final response = await baseGet('${ApiRoutes.userAnswers}/$userId');
    final decoded = _handleResponse(response);
    final raw = decoded['data'] as Map<String, dynamic>? ?? {};
    return raw.map((key, value) => MapEntry(
          int.parse(key),
          (value as List).cast<Map<String, dynamic>>(),
        ));
  }

  /// PUT /user-answers/bulk — replace all answers (health survey edit).
  Future<void> replaceAnswersBulk(List<Map<String, dynamic>> answers) async {
    final url = Uri.parse('$apiUrl${ApiRoutes.userAnswersBulk}');
    final headers = await ref.read(headersProvider).token;
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'answers': answers}),
    );
    _handleResponse(response);
  }

  /// GET /questions — public endpoint, no auth needed.
  Future<List<Map<String, dynamic>>> getQuestions() async {
    final url = Uri.parse('$apiUrl${ApiRoutes.questions}');
    final headers = ref.read(headersProvider).basic;
    final response = await http.get(url, headers: headers);
    final decoded = _handleResponse(response);
    final raw = decoded['data'];
    final List<dynamic> list = raw is List ? raw : [];
    return list.cast<Map<String, dynamic>>();
  }

  /// POST /user-answers/bulk — submit all questionnaire answers at once.
  Future<void> submitAnswersBulk(List<Map<String, dynamic>> answers) async {
    final response = await basePost(
      ApiRoutes.userAnswersBulk,
      {'answers': answers},
    );
    _handleResponse(response);
  }

  Future<Map<String, dynamic>> storeComboBooking({
    required int comboId,
    required int userId,
    required int branchId,
    required String scheduledStart,
    int participantCount = 1,
    String? notes,
  }) async {
    final response = await basePost(ApiRoutes.comboBooking, {
      'combo_id': comboId,
      'user_id': userId,
      'branch_id': branchId,
      'scheduled_start': scheduledStart,
      'participant_count': participantCount,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return _handleResponse(response);
  }
}
