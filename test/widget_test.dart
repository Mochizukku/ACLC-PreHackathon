import 'package:flutter_test/flutter_test.dart';
import 'package:q2_app/main.dart';

void main() {
  testWidgets('App loads splash screen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerOrderingApp());
    expect(find.text('OPEN APP'), findsOneWidget);
  });
}
