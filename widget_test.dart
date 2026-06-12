import 'package:flutter_test/flutter_test.dart';
import 'package:report_plus/main.dart';

void main() {
  testWidgets('Smoke test opens login page', (WidgetTester tester) async {
    await tester.pumpWidget(const ReportPlusApp());

    expect(find.text('Report+'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
