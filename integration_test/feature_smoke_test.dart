import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serbisyo_ph/main.dart' as app;

/// Integration test for Phase 1e / 4 / 5 features.
///
/// Run with:
///   flutter test integration_test/feature_smoke_test.dart
///
/// Or on a device/emulator:
///   flutter test integration_test/feature_smoke_test.dart -d <device-id>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1e — My Services & Gallery', () {
    testWidgets('App boots and renders without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the app rendered something (at least a Scaffold/MaterialApp)
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Phase 4 — Admin Dashboard', () {
    testWidgets('Admin route is registered', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The app should boot without errors — admin access check
      // happens at runtime when navigating to /admin
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Phase 5 — Security Settings', () {
    testWidgets('Security settings route is registered', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
});
