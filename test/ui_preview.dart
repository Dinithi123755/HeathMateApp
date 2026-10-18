// Run explicitly on a Windows development host to regenerate UI evidence.
// These images are Flutter widget renders, not Android device screenshots.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/app.dart';
import 'package:healthmate/features/records/domain/health_record.dart';
import 'package:healthmate/features/records/presentation/health_view_model.dart';
import 'support/memory_repository.dart';

void main() {
  testWidgets('Render mobile screens for visual review', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final regular = File('C:/Windows/Fonts/segoeui.ttf');
      final bold = File('C:/Windows/Fonts/segoeuib.ttf');
      final loader = FontLoader('Roboto');
      loader.addFont(
        Future.value(ByteData.sublistView(await regular.readAsBytes())),
      );
      loader.addFont(
        Future.value(ByteData.sublistView(await bold.readAsBytes())),
      );
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      debugDisableShadows = false;
    });
    final repository = MemoryRepository();
    final today = calendarDay(DateTime.now());
    for (var day = 0; day < 3; day++) {
      await repository.save(
        HealthRecord(
          date: DateTime(today.year, today.month, today.day - day),
          steps: 3800 + ((day * 1297 + 4050) % 7200),
          calories: 190 + ((day * 53 + 230) % 410),
          water: 1000 + ((day * 3 + 4) % 7) * 250,
          isDemo: false,
        ),
      );
    }
    final vm = HealthViewModel(repository);
    await vm.initialize();
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: HealthMateApp(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('docs/previews');
        await directory.create(recursive: true);
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('01_today');
    await tester.tap(find.byTooltip('Switch to dark mode'));
    await capture('06_dark_dashboard');
    await tester.tap(find.byTooltip('Switch to light mode'));
    for (final item in [('History', '02_history')]) {
      await tester.tap(find.text(item.$1).last);
      await capture(item.$2);
    }
    await tester.tap(find.text('Dashboard').last);
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
    await capture('05_log_activity');
    await tester.tap(find.byKey(const Key('save-record')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    debugDisableShadows = true;
    vm.dispose();
  });
}
