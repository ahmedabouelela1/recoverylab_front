/// Config for integration tests (booking flow).
/// Pass credentials via --dart-define when running on emulator with real API:
///
///   flutter test integration_test/booking_flow_test.dart -d "iPhone Air" \
///     --dart-define=INTEGRATION_TEST_EMAIL=test@example.com \
///     --dart-define=INTEGRATION_TEST_PASSWORD=yourpassword
///
/// If not set, tests that require login will skip or only run UI steps that don't need auth.
const String integrationTestEmail = String.fromEnvironment(
  'INTEGRATION_TEST_EMAIL',
  defaultValue: '',
);

const String integrationTestPassword = String.fromEnvironment(
  'INTEGRATION_TEST_PASSWORD',
  defaultValue: '',
);

bool get hasIntegrationTestCredentials =>
    integrationTestEmail.isNotEmpty && integrationTestPassword.isNotEmpty;
