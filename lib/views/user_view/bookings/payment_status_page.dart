import 'package:flutter/material.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';

class PaymentStatusPage extends StatelessWidget {
  final bool isSuccess;

  const PaymentStatusPage({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isSuccess ? AppColors.primary : Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  color: isSuccess ? AppColors.textPrimary : Colors.red,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? 'Payment Successful!' : 'Payment Failed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? AppColors.textPrimary : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isSuccess
                      ? 'Your booking has been confirmed and payment received.'
                      : 'Something went wrong. Please try again or pay at the branch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSuccess ? AppColors.textPrimary : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.navbar,
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSuccess ? AppColors.textPrimary : Colors.red,
                    foregroundColor:
                        isSuccess ? AppColors.primary : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
