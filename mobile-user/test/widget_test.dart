import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:frontend/main.dart';

void main() {
  // BirdFeApp initializes DatabaseService/SpeciesRepository on build, which
  // needs a real SQLite backend even under test — plain sqflite has no
  // implementation for the `flutter test` host environment. Without this,
  // pumping the widget tree throws `Bad state: databaseFactory not
  // initialized` before the app ever renders.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App renders successfully test', (WidgetTester tester) async {
    await tester.pumpWidget(const BirdFeApp());
    expect(find.byType(BirdFeApp), findsOneWidget);
  });
}
