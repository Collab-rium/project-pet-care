// Basic widget test for Pet Care app

import 'package:flutter_test/flutter_test.dart';

import 'package:project_pet_care_frontend/main.dart';
import 'package:project_pet_care_frontend/services/auth_service.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    // Create auth service
    final authService = AuthService();
    await authService.initialize();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(authService: authService));
    await tester.pumpAndSettle();

    // Verify login screen elements are present
    expect(find.text('Pet Care'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });
}
