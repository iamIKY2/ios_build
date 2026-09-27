import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enigma/main.dart';
import 'package:enigma/repositories/finance_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Enigma Finance app loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await FinanceRepository.create();

    await tester.pumpWidget(EnigmaFinanceApp(repository: repository));
    await tester.pumpAndSettle();

    // Verify that the title or brand is displayed
    expect(find.text('Enigma Finance'), findsOneWidget);
    expect(find.text('Tổng quan'), findsOneWidget);
  });
}
