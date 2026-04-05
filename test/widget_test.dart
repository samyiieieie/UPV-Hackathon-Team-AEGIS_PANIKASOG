import 'package:flutter_test/flutter_test.dart';
import 'package:panikasog/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PanikasogApp());
    await tester.pumpAndSettle();
    expect(find.text('PANIKASOG'), findsOneWidget);
  });
}