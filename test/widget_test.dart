import 'package:flutter_test/flutter_test.dart';
import 'package:temple_dash/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TempleDashApp());
    expect(find.byType(TempleDashApp), findsOneWidget);
  });
}
