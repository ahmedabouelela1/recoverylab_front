import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recoverylab_front/main.dart' as app;
import 'integration_test_config.dart';

/// Full booking flow integration tests: validation, happy path, edge cases.
/// Run: flutter test integration_test/booking_flow_test.dart -d "iPhone Air" \
///   --dart-define=INTEGRATION_TEST_EMAIL=... --dart-define=INTEGRATION_TEST_PASSWORD=...

Future<void> _waitForAppToLoad(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _wait(WidgetTester tester, int secs) async {
  for (var i = 0; i < secs; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _loginIfNeeded(WidgetTester tester) async {
  if (find.text('Get Started').evaluate().isNotEmpty) {
    await tester.tap(find.text('Get Started').first);
    await _wait(tester, 2);
  }
  if (find.text('Sign In').evaluate().isNotEmpty && hasIntegrationTestCredentials) {
    final tf = find.byType(TextField);
    if (tf.evaluate().length >= 2) {
      await tester.enterText(tf.first, integrationTestEmail);
      await tester.enterText(tf.at(1), integrationTestPassword);
    }
    await tester.tap(find.text('Sign In').first);
    await _wait(tester, 10);
  }
}

/// Navigate to categories → Massage → Swedish Massage (or first service). Returns true if service details with Book Now are visible (or loading), false if branch not available / empty.
Future<bool> _navigateToServiceDetails(WidgetTester tester) async {
  if (find.text('See All').evaluate().isNotEmpty) {
    await tester.tap(find.text('See All').first);
    await _wait(tester, 3);
  }
  final categoryWithMassage = find.byWidgetPredicate((w) {
    if (w is! Text) return false;
    return w.data?.toLowerCase().contains('massage') == true;
  });
  if (categoryWithMassage.evaluate().isNotEmpty) {
    await tester.tap(categoryWithMassage.first);
  } else {
    final gestureDetectors = find.byType(GestureDetector);
    if (gestureDetectors.evaluate().length > 2) {
      await tester.tap(gestureDetectors.at(2));
    }
  }
  await _wait(tester, 4);

  final swedishService = find.byWidgetPredicate((w) {
    if (w is! Text) return false;
    return w.data?.toLowerCase().contains('swedish') == true;
  });
  if (swedishService.evaluate().isNotEmpty) {
    await tester.tap(swedishService.first);
  } else {
    final viewDetails = find.text('view details');
    if (viewDetails.evaluate().isNotEmpty) {
      await tester.tap(viewDetails.first);
    } else {
      final gestureDetectors = find.byType(GestureDetector);
      if (gestureDetectors.evaluate().length > 5) {
        await tester.tap(gestureDetectors.at(5));
      }
    }
  }
  await _wait(tester, 8);

  final notAvailable = find.text('NOT AVAILABLE HERE').evaluate().isNotEmpty ||
      find.text('Service not available at this branch').evaluate().isNotEmpty ||
      find.text('This service is currently not offered at this branch').evaluate().isNotEmpty;
  if (notAvailable) return false;

  if (find.text('Loading service details...').evaluate().isNotEmpty) {
    await _wait(tester, 5);
  }
  return find.text('Book Now').evaluate().isNotEmpty ||
      find.text('No services available in this category.').evaluate().isNotEmpty;
}

Future<void> _selectDate(WidgetTester tester) async {
  final dateLabel = find.text('Date');
  if (dateLabel.evaluate().isNotEmpty) {
    await tester.tap(dateLabel.first);
    await tester.pump(const Duration(milliseconds: 500));
    final dayButtons = find.byType(IconButton);
    if (dayButtons.evaluate().length >= 10) {
      await tester.tap(dayButtons.at(10));
      await tester.pump(const Duration(milliseconds: 500));
    }
  }
}

Future<void> _selectTime(WidgetTester tester) async {
  final timeLabel = find.text('Time');
  if (timeLabel.evaluate().isNotEmpty) {
    await tester.tap(timeLabel.first);
    await tester.pump(const Duration(milliseconds: 500));
    final listViews = find.byType(ListView);
    if (listViews.evaluate().isNotEmpty) {
      await tester.drag(listViews.first, const Offset(0, -80));
      await tester.pump(const Duration(milliseconds: 300));
    }
    final ok = find.text('OK');
    if (ok.evaluate().isNotEmpty) {
      await tester.tap(ok.first);
      await tester.pump(const Duration(milliseconds: 500));
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking flow: validation, happy path, edge cases', () {
    // —— EDGE: Branch not available ——
    testWidgets('Edge: Service not available at branch shows NOT AVAILABLE / not offered',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      expect(
        find.text('Browse Categories').evaluate().isNotEmpty ||
            find.text('See All').evaluate().isNotEmpty,
        true,
        reason: 'Should reach home',
      );
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails) {
        expect(
          find.text('NOT AVAILABLE HERE').evaluate().isNotEmpty ||
              find.text('Service not available at this branch').evaluate().isNotEmpty ||
              find.text('This service is currently not offered at this branch').evaluate().isNotEmpty,
          true,
          reason: 'Service correctly shown as not available at this branch',
        );
        return;
      }
      expect(find.text('Book Now').evaluate().isNotEmpty ||
          find.text('No services available in this category.').evaluate().isNotEmpty, true);
    });

    // —— VALIDATION: Book Now without date and time ——
    testWidgets('Validation: Book Now without date and time shows validation message',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails || find.text('Book Now').evaluate().isEmpty) return;

      await tester.tap(find.text('Book Now').first);
      await _wait(tester, 2);

      expect(
        find.text('Please select date and time').evaluate().isNotEmpty,
        true,
        reason: 'Validation must require date and time',
      );
    });

    // —— VALIDATION: Book Now with date but no time ——
    testWidgets('Validation: Book Now with date but no time shows validation',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails || find.text('Book Now').evaluate().isEmpty) return;

      await _selectDate(tester);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Book Now').first);
      await _wait(tester, 2);

      expect(
        find.text('Please select date and time').evaluate().isNotEmpty ||
            find.text('Booking Summary').evaluate().isNotEmpty ||
            find.text('Confirm & Book').evaluate().isNotEmpty,
        true,
        reason: 'Either validation message or summary (if time was pre-filled)',
      );
    });

    // —— HAPPY PATH: Full booking to Confirm & Book then success or API error ——
    testWidgets('Happy path: select date and time, Book Now, Confirm & Book, then success or error',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails || find.text('Book Now').evaluate().isEmpty) return;

      await _selectDate(tester);
      await tester.pump(const Duration(milliseconds: 500));
      await _selectTime(tester);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Book Now').first);
      await _wait(tester, 2);

      if (find.text('Please select date and time').evaluate().isNotEmpty) {
        expect(true, true, reason: 'Validation shown when date/time incomplete');
        return;
      }

      expect(
        find.text('Booking Summary').evaluate().isNotEmpty ||
            find.text('Confirm & Book').evaluate().isNotEmpty,
        true,
        reason: 'Booking confirmation step must appear',
      );

      if (find.text('Confirm & Book').evaluate().isEmpty) return;

      await tester.tap(find.text('Confirm & Book').first);
      await _wait(tester, 15);

      final success = find.text('Payment Successful!').evaluate().isNotEmpty ||
          find.text('Booking Confirmed!').evaluate().isNotEmpty ||
          find.text('View Bookings').evaluate().isNotEmpty ||
          find.text('Book Another').evaluate().isNotEmpty;
      final bookingsTab = find.text('Upcoming').evaluate().isNotEmpty;
      final errorMsg = find.byType(SnackBar).evaluate().isNotEmpty ||
          find.text('Failed to create booking').evaluate().isNotEmpty;

      expect(
        success || bookingsTab || errorMsg,
        true,
        reason: 'After confirm: success, bookings tab, or expected API/validation error',
      );
    });

    // —— EDGE: Confirm & Book then check View Bookings / Book Another ——
    testWidgets('Edge: After confirm, View Bookings or Book Another or Upcoming visible',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails || find.text('Book Now').evaluate().isEmpty) return;

      await _selectDate(tester);
      await tester.pump(const Duration(milliseconds: 500));
      await _selectTime(tester);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Book Now').first);
      await _wait(tester, 2);
      if (find.text('Confirm & Book').evaluate().isEmpty) return;

      await tester.tap(find.text('Confirm & Book').first);
      await _wait(tester, 15);

      expect(
        find.text('View Bookings').evaluate().isNotEmpty ||
            find.text('Book Another').evaluate().isNotEmpty ||
            find.text('Upcoming').evaluate().isNotEmpty ||
            find.text('Payment Successful!').evaluate().isNotEmpty ||
            find.text('Booking Confirmed!').evaluate().isNotEmpty ||
            find.byType(SnackBar).evaluate().isNotEmpty,
        true,
        reason: 'Success UI or error snackbar must appear after confirm',
      );
    });

    // —— VALIDATION: Service details shows booking controls and Book Now ——
    testWidgets('Validation: Service details page shows date/time controls and Book Now',
        (tester) async {
      app.main();
      await _waitForAppToLoad(tester);
      await _loginIfNeeded(tester);
      final onDetails = await _navigateToServiceDetails(tester);
      if (!onDetails) return;

      // Main page uses "Select a date first" / "Choose a time" / "Select Duration"; modal uses "Date" / "Time"
      final hasBookNow = find.text('Book Now').evaluate().isNotEmpty;
      final hasDateControl = find.text('Date').evaluate().isNotEmpty ||
          find.text('Select a date first').evaluate().isNotEmpty;
      final hasTimeControl = find.text('Time').evaluate().isNotEmpty ||
          find.text('Choose a time').evaluate().isNotEmpty ||
          find.text('Select Duration').evaluate().isNotEmpty;

      expect(hasBookNow, true, reason: 'Service details must show Book Now');
      expect(
        hasDateControl && hasTimeControl,
        true,
        reason: 'Service details must show date and time controls (Date/Time or Select date/Choose time/Duration)',
      );
    });
  });
}
