import 'package:flutter_test/flutter_test.dart';
import 'package:jet_dodge/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const JetDodgeApp());
    await tester.pump();
    expect(find.text('JET DODGE'), findsOneWidget);
  });
}
