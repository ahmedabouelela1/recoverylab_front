import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final int bookingId;

  const PaymentScreen({
    super.key,
    required this.checkoutUrl,
    required this.bookingId,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final WebViewController _controller;
  Timer? _pollTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) => _onUrl(url),
        onUrlChange: (change) {
          if (change.url != null) _onUrl(change.url!);
        },
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollBookingStatus());
  }

  Future<void> _pollBookingStatus() async {
    if (_navigated || !mounted) return;
    try {
      final booking = await ref.read(apiProvider).getBooking(widget.bookingId);
      if (!mounted || _navigated) return;
      if (booking.paymentStatus == 'PAID') {
        _finish(success: true);
      }
    } catch (_) {}
  }

  void _onUrl(String url) {
    if (_navigated) return;
    if (url.contains('success=true')) {
      _finish(success: true);
    } else if (url.contains('success=false')) {
      _finish(success: false);
    }
  }

  void _finish({required bool success}) {
    if (_navigated) return;
    _navigated = true;
    _pollTimer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      Routes.paymentStatus,
      arguments: {'isSuccess': success, 'bookingId': widget.bookingId},
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
