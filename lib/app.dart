import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/insights/presentation/insights_screen.dart';
import 'features/records/domain/health_record.dart';
import 'features/records/presentation/health_view_model.dart';
import 'features/records/presentation/history_screen.dart';
import 'features/records/presentation/record_form.dart';
import 'features/settings/presentation/settings_screen.dart';

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({required this.viewModel, super.key});
  final HealthViewModel viewModel;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: viewModel,
    child: Consumer<HealthViewModel>(
      builder: (context, vm, child) => MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: vm.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        home: const _HomeShell(),
      ),
    ),
  );
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> with WidgetsBindingObserver {
  int _tab = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) context.read<HealthViewModel>().refreshDate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HealthViewModel>().refreshDate();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _edit([HealthRecord? row]) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => RecordForm(record: row)),
  );
  Future<void> _delete(HealthRecord row) async {
    final vm = context.read<HealthViewModel>();
    if (vm.busy) return;
    if (!await confirm(
      context,
      title: 'Delete this record?',
      message:
          'This entry will be permanently removed and your summaries will update.',
      action: 'Delete',
    )) {
      return;
    }
    final success = await vm.delete(row);
    if (mounted) {
      feedbackMessage(context, success ? 'Record deleted.' : vm.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final pages = [
      DashboardScreen(
        onAdd: _edit,
        onHistory: () => setState(() => _tab = 1),
        onEdit: _edit,
        onDelete: _delete,
      ),
      HistoryScreen(onAdd: _edit, onEdit: _edit, onDelete: _delete),
      const InsightsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 9),
            const Flexible(
              child: Text(
                'healthmate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Tooltip(
              message: 'Saved locally on your device',
              child: Icon(
                Icons.verified_user_outlined,
                size: 21,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : !vm.ready
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  title: 'Let’s try again',
                  message: vm.error!,
                  action: FilledButton(
                    onPressed: vm.initialize,
                    child: const Text('Retry'),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: IndexedStack(index: _tab, children: pages),
                ),
              ),
      ),
      floatingActionButton: _tab < 2 && !vm.loading
          ? FloatingActionButton.extended(
              onPressed: vm.busy ? null : _edit,
              icon: const Icon(Icons.add),
              label: const Text('Log activity'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
