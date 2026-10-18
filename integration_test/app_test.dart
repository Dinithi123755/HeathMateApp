import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:healthmate/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android SQLite workflow and screen evidence', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    final demo = find.text('Load demo records');
    final refresh = find.text('Refresh demo records');
    await tester.ensureVisible(demo.evaluate().isNotEmpty ? demo : refresh);
    await tester.tap(demo.evaluate().isNotEmpty ? demo : refresh);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Load demo'));
    await tester.pumpAndSettle();
    expect(find.text('Remove demo records'), findsOneWidget);
    await binding.takeScreenshot('04_settings');
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_dashboard');
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02_history');
    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03_insights');
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Steps walked'),
      '1500',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Calories burned'),
      '120',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Water intake'),
      '500',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05_log_activity');
    await tester.ensureVisible(find.byKey(const Key('save-record')));
    await tester.tap(find.byKey(const Key('save-record')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('1,500 steps'), findsOneWidget);
    await tester.tap(find.byTooltip('Record actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete record'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('1,500 steps'), findsNothing);
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle();
  });
}
