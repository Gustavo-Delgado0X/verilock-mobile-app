import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verilock_mobile_v2/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Initialize Shared Preferences with mock values to prevent errors in PinUtils
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const VeriLockApp());
    
    // Wait for any animations or async init methods (like checking PIN)
    await tester.pumpAndSettle();

    // Verify that the app widget is present
    expect(find.byType(VeriLockApp), findsOneWidget);
  });
}
