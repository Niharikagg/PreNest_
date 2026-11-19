import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prenest/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Records'), findsWidgets);
    expect(find.text('Verify'), findsWidgets);
    expect(find.text('Trends'), findsWidgets);
  });
}
