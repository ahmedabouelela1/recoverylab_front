import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/branch_provider.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Read auth token, cached user, and onboarding flag concurrently.
    final results = await Future.wait([
      _storage.read(key: 'auth_token'),
      _storage.read(key: 'user'),
      SharedPreferences.getInstance(),
      ref.read(branchesProvider.notifier).fetchBranches().then((_) => null).catchError((_) => null),
    ]);

    final token = results[0] as String?;
    final userJson = results[1] as String?;
    final prefs = results[2] as SharedPreferences;
    final bool showOnboarding = !(prefs.getBool('onboarding_seen') ?? false);

    // Restore in-memory session from cache so the UI is ready immediately.
    if (userJson != null) {
      try {
        final cached = AuthResponse.fromJson(jsonDecode(userJson));
        ref.read(userSessionProvider.notifier).login(cached);
      } catch (_) {}
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // No token stored — send to onboarding or login.
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(
        context,
        showOnboarding ? Routes.onboardingScreen : Routes.loginPage,
      );
      return;
    }

    // Validate the token with the server.
    final response = await ref.read(apiProvider).validateToken(token);
    if (!mounted) return;

    if (response['success'] == false) {
      Navigator.pushReplacementNamed(
        context,
        showOnboarding ? Routes.onboardingScreen : Routes.loginPage,
      );
      return;
    }

    Navigator.pushReplacementNamed(context, Routes.navbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset('lib/assets/images/logo1.png', width: 200, height: 200),
      ),
    );
  }
}
