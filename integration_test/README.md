# Recovery Lab — Integration tests

Run on a **device or simulator** (integration tests are not supported on web).  
The app uses Google Fonts and (for booking flow) the real API — ensure the device has **network** access.

---

## Test files

| File | Description |
|------|-------------|
| `app_test.dart` | App launch, login/onboarding, empty-form validation |
| `booking_flow_test.dart` | Single flow: login → Massage category → Swedish Massage → branch availability (or “not here”) → date → time → staff → Book Now → Confirm & Book → success or error |

---

## iPhone simulator (recommended)

```bash
# List devices
flutter devices

# App smoke + login validation
flutter test integration_test/app_test.dart -d "iPhone Air"

# Full booking flow (UI only if no credentials)
flutter test integration_test/booking_flow_test.dart -d "iPhone Air"

# Full booking flow with real API (create booking)
flutter test integration_test/booking_flow_test.dart -d "iPhone Air" \
  --dart-define=INTEGRATION_TEST_EMAIL=your-test@example.com \
  --dart-define=INTEGRATION_TEST_PASSWORD=yourpassword
```

## Android emulator

```bash
flutter test integration_test/app_test.dart -d emulator-5554
flutter test integration_test/booking_flow_test.dart -d emulator-5554
# With credentials:
# flutter test integration_test/booking_flow_test.dart -d emulator-5554 \
#   --dart-define=INTEGRATION_TEST_EMAIL=... --dart-define=INTEGRATION_TEST_PASSWORD=...
```

## macOS desktop

```bash
flutter test integration_test/app_test.dart -d macos
flutter test integration_test/booking_flow_test.dart -d macos
```

---

## Booking flow (single test)

1. **Login** — If needed, with credentials; then home.
2. **Categories** — Tap "See All", find "Massage" (or first category), open it.
3. **Service** — Find "Swedish Massage" (text containing "Swedish") or first "view details".
4. **Branch** — If "NOT AVAILABLE HERE" or "Service not available at this branch", test passes.
5. **Date** — Tap "Date", pick a day.
6. **Time** — Tap "Time", pick time, tap OK.
7. **Staff** — Staff section present; optional selection.
8. **Book Now** — Tap "Book Now"; "Please select date and time" validates correctly.
9. **Confirm** — Tap "Confirm & Book"; pass on success, "View Bookings", or expected error.

Without credentials, tests that need a logged-in user still run the UI steps that don’t require auth (e.g. onboarding, categories if already on home).
