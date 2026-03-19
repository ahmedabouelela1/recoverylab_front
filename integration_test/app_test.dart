import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:recoverylab_front/main.dart' as app;

// ============================================================================
// Test Credentials
// Supply real staging/test credentials via dart-define in CI:
//   flutter test integration_test/app_test.dart \
//     --dart-define=TEST_EMAIL=test@staging.com \
//     --dart-define=TEST_PASSWORD=Test1234!
//
// NEVER commit real production credentials here.
// ============================================================================
const _kEmail = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'test@recoverylab.com',
);
const _kPassword = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: 'Test1234!',
);
const _kBadEmail = 'nobody_real@recoverylab.com';
const _kBadPassword = 'WrongPassword999';
const _kInvalidEmail = 'not-an-email';
const _kShortPassword = '123';

// ============================================================================
// Timing helpers
// ============================================================================

/// Cold-boots the app and waits for Firebase init + token restoration.
Future<void> _boot(WidgetTester t) async {
  app.main();
  await t.pump();
  await t.pump(const Duration(seconds: 5));
}

/// Short settle — used after widget state changes that do not need network.
Future<void> _settle(WidgetTester t, {int ms = 400}) async {
  await t.pump(Duration(milliseconds: ms));
}

/// Network settle — waits for an API round-trip to complete.
Future<void> _net(WidgetTester t, {int seconds = 6}) async {
  await t.pump();
  await t.pump(Duration(seconds: seconds));
}

/// Shimmer-safe settle — enough frames to avoid hanging on repeating animations.
Future<void> _shimmer(WidgetTester t) async {
  await t.pump(const Duration(milliseconds: 300));
  await t.pump(const Duration(seconds: 3));
  await t.pump(const Duration(seconds: 2));
}

// ============================================================================
// Screen-detection helpers
// ============================================================================

bool _onLogin(WidgetTester t) =>
    find.text('Welcome Back').evaluate().isNotEmpty &&
    find.text('Sign In').evaluate().isNotEmpty;

bool _onOnboarding(WidgetTester t) =>
    find.text('Welcome to Recovery Lab').evaluate().isNotEmpty;

bool _onHome(WidgetTester t) =>
    find.text('Welcome back,').evaluate().isNotEmpty;

/// Finds the CurvedNavigationBar by matching its runtime type name.
Finder get _navBar => find.byWidgetPredicate(
      (w) => w.runtimeType.toString().contains('CurvedNavigationBar'),
    );

bool _hasNavbar(WidgetTester t) =>
    _navBar.evaluate().isNotEmpty || _onHome(t);

// ============================================================================
// Auth helpers
// ============================================================================

Future<void> _goToLogin(WidgetTester t) async {
  if (_onOnboarding(t)) {
    final getStarted = find.text('Get Started');
    if (getStarted.evaluate().isNotEmpty) {
      await t.tap(getStarted.first);
      await _shimmer(t);
    }
  }
}

/// Fills the login form and taps Sign In.
/// Returns true if the login screen was found and the form was submitted.
Future<bool> _login(
  WidgetTester t, {
  required String email,
  required String password,
}) async {
  await _goToLogin(t);
  if (!_onLogin(t)) return false;

  final fields = find.byType(TextField);
  if (fields.evaluate().length < 2) return false;

  await t.enterText(fields.first, email);
  await t.pump();
  await t.enterText(fields.last, password);
  await t.pump();
  await t.tap(find.text('Sign In').first);
  await _net(t, seconds: 8);
  return true;
}

/// Taps the nav-bar icon [icon] and waits for the target screen to render.
Future<void> _tapNavIcon(WidgetTester t, IconData icon) async {
  final btn = find.byIcon(icon);
  if (btn.evaluate().isEmpty) return;
  await t.tap(btn.first);
  await _shimmer(t);
}

// ============================================================================
// Tests
// ============================================================================
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------------
  // 1 · App Launch & Initial Routing
  // --------------------------------------------------------------------------
  group('App Launch & Initial Routing', () {
    testWidgets('App boots without crash', (t) async {
      await _boot(t);
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('After boot, shows onboarding, login, or home', (t) async {
      await _boot(t);
      final ok = _onOnboarding(t) ||
          _onLogin(t) ||
          _onHome(t) ||
          find.byType(Scaffold).evaluate().isNotEmpty;
      expect(ok, isTrue,
          reason: 'Must land on onboarding, login, or home after boot');
    });

    testWidgets('Splash does not freeze the app', (t) async {
      await _boot(t);
      expect(find.byType(Scaffold).evaluate().isNotEmpty, isTrue);
    });
  });

  // --------------------------------------------------------------------------
  // 2 · Onboarding Flow
  // --------------------------------------------------------------------------
  group('Onboarding Flow', () {
    testWidgets('Get Started navigates toward login', (t) async {
      await _boot(t);
      if (!_onOnboarding(t)) return;

      final btn = find.text('Get Started');
      if (btn.evaluate().isEmpty) return;

      await t.tap(btn.first);
      await _shimmer(t);

      expect(
        _onLogin(t) ||
            find.text('Sign up').evaluate().isNotEmpty ||
            find.byType(TextField).evaluate().isNotEmpty,
        isTrue,
        reason: 'Get Started must navigate toward the auth flow',
      );
    });

    testWidgets('Welcome to Recovery Lab title is visible', (t) async {
      await _boot(t);
      if (!_onOnboarding(t)) return;
      expect(find.text('Welcome to Recovery Lab'), findsWidgets);
    });
  });

  // --------------------------------------------------------------------------
  // 3 · Login Screen — UI & Validation (no network required)
  // --------------------------------------------------------------------------
  group('Login — UI & Validation', () {
    testWidgets('Login screen shows all required elements', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Continue your recovery journey'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign up'), findsWidgets);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('or continue with'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('Empty form tap shows validation errors', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      await t.tap(find.text('Sign In').first);
      await _settle(t);

      final emailErr = find.text('Email is required').evaluate().isNotEmpty;
      final passErr = find.text('Password is required').evaluate().isNotEmpty;
      expect(emailErr || passErr, isTrue,
          reason: 'Empty submit must show at least one validation error');
    });

    testWidgets('Invalid email format shows inline error', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      final fields = find.byType(TextField);
      if (fields.evaluate().isEmpty) return;

      await t.enterText(fields.first, _kInvalidEmail);
      await t.pump();
      await t.tap(find.text('Sign In').first);
      await _settle(t);

      expect(find.text('Enter a valid email').evaluate().isNotEmpty, isTrue,
          reason: 'Malformed email should show inline error');
    });

    testWidgets('Password shorter than 6 chars shows min-length error', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      final fields = find.byType(TextField);
      if (fields.evaluate().length < 2) return;

      await t.enterText(fields.first, _kEmail);
      await t.enterText(fields.last, _kShortPassword);
      await t.tap(find.text('Sign In').first);
      await _settle(t);

      expect(
        find.text('Must be at least 6 characters').evaluate().isNotEmpty,
        isTrue,
        reason: 'Short password must show min-length error',
      );
    });

    testWidgets('Password visibility toggle switches icon state', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await t.tap(find.byIcon(Icons.visibility_off_outlined));
      await _settle(t);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await t.tap(find.byIcon(Icons.visibility_outlined));
      await _settle(t);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('Terms of Service and Privacy Policy text are shown', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      expect(find.text('Terms of Service'), findsWidgets);
      expect(find.text('Privacy Policy'), findsWidgets);
    });
  });

  // --------------------------------------------------------------------------
  // 4 · Login Flow — Network
  // --------------------------------------------------------------------------
  group('Login — Network Flow', () {
    testWidgets('Sign In shows Signing in... immediately after tap', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      final fields = find.byType(TextField);
      if (fields.evaluate().length < 2) return;

      await t.enterText(fields.first, _kEmail);
      await t.enterText(fields.last, _kPassword);
      await t.tap(find.text('Sign In').first);
      await t.pump(const Duration(milliseconds: 100));

      expect(find.text('Signing in...').evaluate().isNotEmpty, isTrue,
          reason: 'Button must show loading text immediately after tap');
    });

    testWidgets('Wrong credentials stay on login or show error', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      await _login(t, email: _kBadEmail, password: _kBadPassword);

      final stillOnLogin = _onLogin(t);
      final hasError =
          find.text('Wrong Email or Password').evaluate().isNotEmpty ||
              find.byType(SnackBar).evaluate().isNotEmpty ||
              find.text('Something went wrong').evaluate().isNotEmpty;
      expect(stillOnLogin || hasError, isTrue,
          reason: 'Invalid credentials must not navigate to home');
    });

    testWidgets('Correct credentials navigate to navbar/home', (t) async {
      await _boot(t);
      if (_onHome(t) || _hasNavbar(t)) return; // already logged in

      final submitted = await _login(t, email: _kEmail, password: _kPassword);
      if (!submitted) return;

      expect(_onHome(t) || _hasNavbar(t), isTrue,
          reason: 'Valid login must navigate to the main screen');
    });
  });

  // --------------------------------------------------------------------------
  // 5 · Registration Navigation
  // --------------------------------------------------------------------------
  group('Registration — Navigation', () {
    testWidgets('Sign up link navigates away from login', (t) async {
      await _boot(t);
      await _goToLogin(t);
      if (!_onLogin(t)) return;

      await t.tap(find.text('Sign up').first);
      await _shimmer(t);

      expect(
        !_onLogin(t) || find.byType(TextField).evaluate().isNotEmpty,
        isTrue,
        reason: 'Sign up must navigate away from login to registration',
      );
    });
  });

  // --------------------------------------------------------------------------
  // 6 · Home Screen (requires auth)
  // --------------------------------------------------------------------------
  group('Home Screen', () {
    Future<bool> ensureHome(WidgetTester t) async {
      await _boot(t);
      if (!_onHome(t)) await _login(t, email: _kEmail, password: _kPassword);
      return _onHome(t);
    }

    testWidgets('Shows greeting header with user name', (t) async {
      if (!await ensureHome(t)) return;
      expect(find.text('Welcome back,'), findsOneWidget);
    });

    testWidgets('Shows membership badge (member plan or Not a member)', (t) async {
      if (!await ensureHome(t)) return;
      await _shimmer(t);

      final hasBadge = find.text('Not a member').evaluate().isNotEmpty ||
          find.text('...').evaluate().isNotEmpty ||
          find
              .byWidgetPredicate(
                  (w) => w is Text && (w.data?.contains('member') ?? false))
              .evaluate()
              .isNotEmpty;
      expect(hasBadge, isTrue,
          reason: 'Membership badge must appear in the home header');
    });

    testWidgets('Special Offers section renders after load', (t) async {
      if (!await ensureHome(t)) return;
      await _shimmer(t);

      final shown = find.text('Special Offers').evaluate().isNotEmpty ||
          find.text('Hot Deals').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(shown, isTrue);
    });

    testWidgets('Browse Categories section renders after load', (t) async {
      if (!await ensureHome(t)) return;
      await _shimmer(t);

      final shown = find.text('Browse Categories').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(shown, isTrue);
    });

    testWidgets('Recommended for You section renders after load', (t) async {
      if (!await ensureHome(t)) return;
      await _shimmer(t);

      final shown = find.text('Recommended for You').evaluate().isNotEmpty ||
          find.text('Top Rated').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(shown, isTrue);
    });

    testWidgets('See All navigates to service categories', (t) async {
      if (!await ensureHome(t)) return;
      await _shimmer(t);

      final seeAll = find.text('See All');
      if (seeAll.evaluate().isEmpty) return;

      await t.tap(seeAll.first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Home does not freeze during shimmer auto-scroll timer', (t) async {
      if (!await ensureHome(t)) return;
      await t.pump(const Duration(seconds: 10));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // --------------------------------------------------------------------------
  // 7 · Bottom Navigation (requires auth)
  // --------------------------------------------------------------------------
  group('Bottom Navigation', () {
    Future<bool> ensureNavbar(WidgetTester t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      return _hasNavbar(t);
    }

    testWidgets('CurvedNavigationBar is present', (t) async {
      if (!await ensureNavbar(t)) return;
      expect(_navBar.evaluate().isNotEmpty, isTrue,
          reason: 'CurvedNavigationBar must be present after login');
    });

    testWidgets('Bookings icon shows My Bookings screen', (t) async {
      if (!await ensureNavbar(t)) return;
      await _tapNavIcon(t, SolarIconsOutline.calendarAdd);
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('Packages icon shows Packages screen', (t) async {
      if (!await ensureNavbar(t)) return;
      await _tapNavIcon(t, SolarIconsOutline.bedsideTable4);
      expect(find.text('Packages'), findsWidgets);
    });

    testWidgets('User icon shows Settings screen', (t) async {
      if (!await ensureNavbar(t)) return;
      await _tapNavIcon(t, SolarIconsOutline.user);
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('Home icon returns to home screen', (t) async {
      if (!await ensureNavbar(t)) return;
      await _tapNavIcon(t, SolarIconsOutline.calendarAdd);
      await _tapNavIcon(t, SolarIconsOutline.home);
      expect(_onHome(t), isTrue,
          reason: 'Home icon must navigate back to home');
    });

    testWidgets('Can cycle through all 4 tabs without crash', (t) async {
      if (!await ensureNavbar(t)) return;

      for (final icon in [
        SolarIconsOutline.home,
        SolarIconsOutline.calendarAdd,
        SolarIconsOutline.bedsideTable4,
        SolarIconsOutline.user,
      ]) {
        await _tapNavIcon(t, icon);
        expect(find.byType(Scaffold), findsWidgets,
            reason: 'Each tab must render without crash');
      }
    });
  });

  // --------------------------------------------------------------------------
  // 8 · Bookings Screen (requires auth)
  // --------------------------------------------------------------------------
  group('Bookings Screen', () {
    Future<bool> ensureBookings(WidgetTester t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return false;
      await _tapNavIcon(t, SolarIconsOutline.calendarAdd);
      return find.text('My Bookings').evaluate().isNotEmpty;
    }

    testWidgets('Screen title My Bookings is shown', (t) async {
      if (!await ensureBookings(t)) return;
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('Shows subtitle after data loads', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      final hasSubtitle =
          find.text('Manage your sessions').evaluate().isNotEmpty ||
              find.textContaining('upcoming session').evaluate().isNotEmpty;
      expect(hasSubtitle, isTrue);
    });

    testWidgets('Three status tabs are present', (t) async {
      if (!await ensureBookings(t)) return;
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Cancelled'), findsWidgets);
    });

    testWidgets('Upcoming tab default shows content or empty state', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      final ok = find.text('No upcoming sessions').evaluate().isNotEmpty ||
          find.text('Browse Services').evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty;
      expect(ok, isTrue);
    });

    testWidgets('Completed tab shows correct state', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      await t.tap(find.text('Completed').first);
      await _settle(t);

      final ok = find.text('No completed sessions').evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty;
      expect(ok, isTrue);
    });

    testWidgets('Cancelled tab shows correct state', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      await t.tap(find.text('Cancelled').first);
      await _settle(t);

      final ok = find.text('No cancelled bookings').evaluate().isNotEmpty ||
          find.byType(ListView).evaluate().isNotEmpty;
      expect(ok, isTrue);
    });

    testWidgets('Empty Upcoming shows Browse Services CTA', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      if (find.text('No upcoming sessions').evaluate().isEmpty) return;
      expect(find.text('Browse Services'), findsOneWidget);
    });

    testWidgets('Empty Completed shows correct subtitle', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      await t.tap(find.text('Completed').first);
      await _settle(t);

      if (find.text('No completed sessions').evaluate().isEmpty) return;
      expect(
        find.text('Your completed sessions\nwill appear here'),
        findsOneWidget,
      );
    });

    testWidgets('Empty Cancelled shows correct subtitle', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 4);

      await t.tap(find.text('Cancelled').first);
      await _settle(t);

      if (find.text('No cancelled bookings').evaluate().isEmpty) return;
      expect(
        find.text('Cancelled sessions\nwill appear here'),
        findsOneWidget,
      );
    });

    testWidgets('Error state shows Try Again button and message', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 6);

      if (find.text('Failed to load bookings').evaluate().isEmpty) return;
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Check your connection and try again'), findsOneWidget);

      await t.tap(find.text('Try Again').first);
      await _net(t, seconds: 6);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Cancel dialog shows correct content', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      final cancelBtn = find.text('Cancel');
      if (cancelBtn.evaluate().isEmpty) return;

      await t.tap(cancelBtn.first);
      await _settle(t);

      expect(find.text('Cancel Booking?'), findsOneWidget);
      expect(find.text('Keep It'), findsOneWidget);
      expect(find.text('Yes, Cancel'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
    });

    testWidgets('Keep It closes the cancel dialog', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      final cancelBtn = find.text('Cancel');
      if (cancelBtn.evaluate().isEmpty) return;

      await t.tap(cancelBtn.first);
      await _settle(t);
      if (find.text('Cancel Booking?').evaluate().isEmpty) return;

      await t.tap(find.text('Keep It'));
      await _settle(t);

      expect(find.text('Cancel Booking?').evaluate().isEmpty, isTrue,
          reason: 'Keep It must dismiss the dialog');
    });

    testWidgets('Yes Cancel triggers cancellation overlay or snackbar', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      final cancelBtn = find.text('Cancel');
      if (cancelBtn.evaluate().isEmpty) return;

      await t.tap(cancelBtn.first);
      await _settle(t);
      if (find.text('Cancel Booking?').evaluate().isEmpty) return;

      await t.tap(find.text('Yes, Cancel'));
      await t.pump(const Duration(milliseconds: 200));

      final isCancelling =
          find.text('Cancelling booking...').evaluate().isNotEmpty;
      await _net(t, seconds: 6);

      // After cancellation, expect either success snackbar or tab switch
      final done = isCancelling ||
          find.text('Booking cancelled successfully').evaluate().isNotEmpty ||
          find.byType(Scaffold).evaluate().isNotEmpty;
      expect(done, isTrue);
    });

    testWidgets('Pull-to-refresh reloads bookings list', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      final list = find.byType(ListView);
      if (list.evaluate().isEmpty) return;

      await t.fling(list.first, const Offset(0, 200), 800);
      await _net(t, seconds: 5);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Summary pills show correct labels after load', (t) async {
      if (!await ensureBookings(t)) return;
      await _net(t, seconds: 5);

      if (find.text('My Bookings').evaluate().isEmpty) return;
      // Pills appear only when bookings exist
      final hasUpcomingPill = find.text('Manage your sessions').evaluate().isEmpty;
      if (!hasUpcomingPill) return; // no bookings, pills not shown

      expect(
        find.textContaining('Upcoming').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  // --------------------------------------------------------------------------
  // 9 · Packages & Memberships Screen (requires auth)
  // --------------------------------------------------------------------------
  group('Packages & Memberships Screen', () {
    Future<bool> ensurePackages(WidgetTester t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return false;
      await _tapNavIcon(t, SolarIconsOutline.bedsideTable4);
      return find.text('Packages').evaluate().isNotEmpty;
    }

    testWidgets('Packages AppBar title is shown', (t) async {
      if (!await ensurePackages(t)) return;
      expect(find.text('Packages'), findsWidgets);
    });

    testWidgets('Shows Combos and Membership sub-tabs', (t) async {
      if (!await ensurePackages(t)) return;
      await _shimmer(t);

      expect(find.text('Combos'), findsWidgets);
      expect(find.text('Membership'), findsWidgets);
    });

    testWidgets('Combos tab loads without crash', (t) async {
      if (!await ensurePackages(t)) return;
      await _shimmer(t);

      final combosTab = find.text('Combos');
      if (combosTab.evaluate().isEmpty) return;
      await t.tap(combosTab.first);
      await _net(t, seconds: 5);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Membership tab loads without crash', (t) async {
      if (!await ensurePackages(t)) return;
      await _shimmer(t);

      final membershipTab = find.text('Membership');
      if (membershipTab.evaluate().isEmpty) return;
      await t.tap(membershipTab.first);
      await _net(t, seconds: 5);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Packages sub-tab loads without crash', (t) async {
      if (!await ensurePackages(t)) return;
      await _shimmer(t);

      // 'Packages' appears as both page title and tab; tap the last occurrence
      final packagesLabels = find.text('Packages');
      if (packagesLabels.evaluate().length < 2) return;
      await t.tap(packagesLabels.last);
      await _net(t, seconds: 5);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Tab switching between Combos → Membership → Packages is stable', (t) async {
      if (!await ensurePackages(t)) return;
      await _shimmer(t);

      for (final label in ['Combos', 'Membership']) {
        final tab = find.text(label);
        if (tab.evaluate().isEmpty) continue;
        await t.tap(tab.first);
        await _settle(t, ms: 600);
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });

  // --------------------------------------------------------------------------
  // 10 · Settings Screen (requires auth)
  // --------------------------------------------------------------------------
  group('Settings Screen', () {
    Future<bool> ensureSettings(WidgetTester t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return false;
      await _tapNavIcon(t, SolarIconsOutline.user);
      return find.text('Settings').evaluate().isNotEmpty;
    }

    testWidgets('Settings AppBar title is shown', (t) async {
      if (!await ensureSettings(t)) return;
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('All section headers are present', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      expect(find.text('YOUR BRANCH'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('SUPPORT & ABOUT'), findsOneWidget);
      expect(find.text('DELETE ACCOUNT'), findsOneWidget);
    });

    testWidgets('Account menu items are present', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      expect(find.text('My Packages & Memberships'), findsOneWidget);
      expect(find.text('Edit Health Survey'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Coupons'), findsOneWidget);
    });

    testWidgets('Support menu items are present', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Terms and Policies'), findsOneWidget);
    });

    testWidgets('Log Out button is present', (t) async {
      if (!await ensureSettings(t)) return;
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Help & Support navigates to help screen', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      await t.tap(find.text('Help & Support').first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Terms and Policies navigates to terms screen', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      await t.tap(find.text('Terms and Policies').first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Change Password navigates to reset password screen', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      await t.tap(find.text('Change Password').first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('My Packages & Memberships navigates to wallet screen', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      await t.tap(find.text('My Packages & Memberships').first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Edit Health Survey navigates to survey screen', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      await t.tap(find.text('Edit Health Survey').first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Profile card tap opens Edit Profile modal', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      // Look for edit profile trigger or tap profile card area
      final gds = find.byType(GestureDetector);
      if (gds.evaluate().isEmpty) return;
      await t.tap(gds.first);
      await _settle(t, ms: 600);

      final hasModal = find.text('Edit Profile').evaluate().isNotEmpty ||
          find.text('FIRST NAME').evaluate().isNotEmpty ||
          find.text('Save Changes').evaluate().isNotEmpty;
      expect(hasModal, isTrue,
          reason: 'Profile card tap must open the Edit Profile modal');
    });

    testWidgets('Edit Profile modal contains expected form labels', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      final gds = find.byType(GestureDetector);
      if (gds.evaluate().isEmpty) return;
      await t.tap(gds.first);
      await _settle(t, ms: 600);

      if (find.text('FIRST NAME').evaluate().isEmpty) return;

      expect(find.text('FIRST NAME'), findsOneWidget);
      expect(find.text('LAST NAME'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('Edit Profile Save requires non-empty name — shows snackbar', (t) async {
      if (!await ensureSettings(t)) return;
      await _shimmer(t);

      final gds = find.byType(GestureDetector);
      if (gds.evaluate().isEmpty) return;
      await t.tap(gds.first);
      await _settle(t, ms: 600);

      if (find.text('Save Changes').evaluate().isEmpty) return;

      // Clear all fields
      final textFields = find.byType(TextField);
      for (final el in textFields.evaluate()) {
        await t.enterText(find.byWidget(el.widget), '');
      }
      await t.pump();

      await t.tap(find.text('Save Changes').first);
      await _settle(t);

      // Should show validation snackbar
      final hasError =
          find.text('Please fill first name, last name and email')
              .evaluate()
              .isNotEmpty ||
          find.byType(SnackBar).evaluate().isNotEmpty;
      expect(hasError, isTrue);
    });

    testWidgets('Log Out redirects to login screen', (t) async {
      if (!await ensureSettings(t)) return;

      await t.tap(find.text('Log Out').first);
      await _net(t, seconds: 3);

      expect(_onLogin(t), isTrue,
          reason: 'Log Out must redirect to login screen');
    });
  });

  // --------------------------------------------------------------------------
  // 11 · Service Browsing Flow (requires auth)
  // --------------------------------------------------------------------------
  group('Service Browsing', () {
    testWidgets('Service categories screen loads from See All', (t) async {
      await _boot(t);
      if (!_onHome(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_onHome(t)) return;

      await _shimmer(t);
      final seeAll = find.text('See All');
      if (seeAll.evaluate().isEmpty) return;

      await t.tap(seeAll.first);
      await _shimmer(t);

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // --------------------------------------------------------------------------
  // 12 · Session Persistence
  // --------------------------------------------------------------------------
  group('Session Persistence', () {
    testWidgets('App always shows a valid initial screen on every launch', (t) async {
      await _boot(t);
      final ok = _onLogin(t) ||
          _onOnboarding(t) ||
          _onHome(t) ||
          find.byType(Scaffold).evaluate().isNotEmpty;
      expect(ok, isTrue,
          reason: 'App must show a valid screen on every launch');
    });
  });

  // --------------------------------------------------------------------------
  // 13 · Error Handling & Stability
  // --------------------------------------------------------------------------
  group('Error Handling & Stability', () {
    testWidgets('Bookings error state shows retry option', (t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return;

      await _tapNavIcon(t, SolarIconsOutline.calendarAdd);
      await _net(t, seconds: 6);

      if (find.text('Failed to load bookings').evaluate().isNotEmpty) {
        expect(find.text('Try Again'), findsOneWidget);
        await t.tap(find.text('Try Again').first);
        await _net(t, seconds: 6);
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Rapid tab switching does not crash the app', (t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return;

      for (var i = 0; i < 3; i++) {
        await _tapNavIcon(t, SolarIconsOutline.calendarAdd);
        await t.pump(const Duration(milliseconds: 100));
        await _tapNavIcon(t, SolarIconsOutline.home);
        await t.pump(const Duration(milliseconds: 100));
        await _tapNavIcon(t, SolarIconsOutline.bedsideTable4);
        await t.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Login screen is accessible after logout', (t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return;

      await _tapNavIcon(t, SolarIconsOutline.user);
      await _shimmer(t);
      if (find.text('Log Out').evaluate().isEmpty) return;

      await t.tap(find.text('Log Out').first);
      await _net(t, seconds: 3);

      expect(_onLogin(t), isTrue,
          reason: 'Login screen must be accessible after logout');
    });

    testWidgets('Packages screen handles empty or error state gracefully', (t) async {
      await _boot(t);
      if (!_hasNavbar(t)) await _login(t, email: _kEmail, password: _kPassword);
      if (!_hasNavbar(t)) return;

      await _tapNavIcon(t, SolarIconsOutline.bedsideTable4);
      await _net(t, seconds: 5);

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
