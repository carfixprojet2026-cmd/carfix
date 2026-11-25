import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:carfix/features/splash/presentation/screens/splash_screen.dart';
import 'package:carfix/core/constants/firebase_constants.dart';

void main() {
  testWidgets('Splash screen loads with app tagline', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    expect(find.text(FirebaseConstants.appTagline), findsOneWidget);
    expect(find.text(FirebaseConstants.appSubtagline), findsOneWidget);
    expect(find.text('VERSION ${FirebaseConstants.appVersion}'), findsOneWidget);
  });
}
