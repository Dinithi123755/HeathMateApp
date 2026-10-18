import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/app.dart';
import 'package:healthmate/features/records/presentation/health_view_model.dart';
import 'support/memory_repository.dart';

void main() {
  testWidgets(
    'TC11 form validates, saves, edits and deletes via visible controls',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryRepository();
      final vm = HealthViewModel(repository);
      await vm.initialize();
      await tester.pumpWidget(HealthMateApp(viewModel: vm));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-record')));
      await tester.pumpAndSettle();
      expect(
        find.text('Add at least one activity above zero.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Steps walked'),
        '1200',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Water intake'),
        '500',
      );
      await tester.tap(find.byKey(const Key('save-record')));
      await tester.pumpAndSettle();
      expect(repository.rows.single.steps, 1200);
      await tester.tap(find.text('History').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Record actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit record'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Water intake'),
        '750',
      );
      await tester.tap(find.byKey(const Key('save-record')));
      await tester.pumpAndSettle();
      expect(repository.rows.single.water, 750);
      await tester.tap(find.byTooltip('Record actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete record'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.rows, hasLength(1));
      await tester.tap(find.byTooltip('Record actions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete record'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(repository.rows, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      vm.dispose();
    },
  );

  testWidgets('TC12 navigation fits a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final vm = HealthViewModel(MemoryRepository());
    await vm.initialize();
    await tester.pumpWidget(HealthMateApp(viewModel: vm));
    for (final tab in ['History', 'Insights', 'Settings', 'Today']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      if (tab == 'Insights') {
        await tester.tap(find.text('30 days'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });
}
