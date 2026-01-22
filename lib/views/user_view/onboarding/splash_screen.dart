import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/models/User/auth/login_response.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final String? userJson = await _storage.read(key: 'user');
    final String? token = await _storage.read(key: 'auth_token');

    AuthResponse? user;

    if (userJson != null) {
      try {
        user = AuthResponse.fromJson(jsonDecode(userJson));
        ref.read(userSessionProvider.notifier).login(user);
      } catch (e, s) {
        Navigator.pushNamed(context, Routes.onboardingScreen);
      }
    }

    Future.delayed(const Duration(seconds: 2), () async {
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, Routes.onboardingScreen);
      } else {
        final response = await ref.read(apiProvider).validateToken(token);

        if (response['success'] == false) {
          Navigator.pushReplacementNamed(context, Routes.onboardingScreen);
          return;
        }
        final AuthResponse? updatedUser = response['data'] != null
            ? AuthResponse.fromJson(response)
            : null;
        if (updatedUser != null) {
          ref.read(userSessionProvider.notifier).login(updatedUser);
        }

        Navigator.pushReplacementNamed(context, Routes.mainScreen);
      }
    });
  }

  @override
  void dispose() {
    // ✅ Cancel timer to prevent leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/images/logo1.png', width: 200, height: 200),
          ],
        ),
      ),
    );
  }
}
