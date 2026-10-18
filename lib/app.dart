import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/common.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/records/domain/health_record.dart';
import 'features/records/presentation/health_view_model.dart';
import 'features/records/presentation/history_screen.dart';
import 'features/records/presentation/record_form.dart';

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({required this.viewModel, super.key});
  final HealthViewModel viewModel;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: viewModel,
    child: MaterialApp(
      title: 'HealthMate',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const _HomeScreen(),
    ),
  );
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();
  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> with WidgetsBindingObserver {
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

  void _edit([HealthRecord? record]) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => RecordForm(record: record)),
  );
  Future<void> _delete(HealthRecord record) async {
    final vm = context.read<HealthViewModel>();
    if (vm.busy) return;
    if (!await confirm(
      context,
      title: 'Delete record?',
      message: 'This record will be permanently deleted.',
      action: 'Delete',
    )) {
      return;
    }
    final success = await vm.delete(record);
    if (mounted) {
      feedbackMessage(context, success ? 'Record deleted.' : vm.error!);
    }
  }

  Future<void> _samples(String action) async {
    final vm = context.read<HealthViewModel>();
    if (!await confirm(
      context,
      title: action == 'load'
          ? 'Load sample records?'
          : 'Remove sample records?',
      message: action == 'load'
          ? 'Add sample data for testing. Sample entries are labelled and included in totals.'
          : 'Only labelled sample records will be removed. Personal records will be kept.',
      action: action == 'load' ? 'Load samples' : 'Remove samples',
    )) {
      return;
    }
    final success = action == 'load'
        ? await vm.loadDemo()
        : await vm.removeDemo();
    if (mounted) {
      feedbackMessage(context, success ? 'Sample records updated.' : vm.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 11),
            const Flexible(
              child: Text(
                'HealthMate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sample data for testing',
            enabled: vm.ready && !vm.busy,
            onSelected: _samples,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'load',
                child: Text('Load sample records'),
              ),
              if (vm.hasDemo)
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove sample records'),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : !vm.ready
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: EmptyState(
                  title: 'Unable to load records',
                  message: vm.error ?? 'Please try again.',
                  action: FilledButton(
                    onPressed: vm.initialize,
                    child: const Text('Retry'),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: IndexedStack(
                    index: _tab,
                    children: [
                      const DashboardScreen(),
                      HistoryScreen(
                        onAdd: _edit,
                        onEdit: _edit,
                        onDelete: _delete,
                      ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: vm.ready
          ? FloatingActionButton.extended(
              onPressed: vm.busy ? null : _edit,
              icon: const Icon(Icons.add),
              label: const Text('Add record'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
