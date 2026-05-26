import 'package:flutter_test/flutter_test.dart';
import 'package:appf/main.dart';

void main() {
  testWidgets('Smoke test opens login page', (WidgetTester tester) async {
    await tester.pumpWidget(const ReportPlusApp());

    expect(find.text('Report+'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
