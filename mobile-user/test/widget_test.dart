import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App renders successfully test', (WidgetTester tester) async {
    await tester.pumpWidget(const BirdFeApp());
    expect(find.byType(BirdFeApp), findsOneWidget);
  });
}
