import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/main.dart';
import 'package:q2_app/screens/splash_screen.dart';

void main() {
  testWidgets('App loads SplashScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Q2App());

    // Verify SplashScreen is loaded
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
