import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../records/presentation/health_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final totals = vm.todayTotals;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text('Today', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(DateFormat('d MMMM yyyy').format(vm.today)),
        const SizedBox(height: 24),
        _summary(
          'Steps walked',
          totals.steps,
          'steps',
          Icons.directions_walk,
          AppColors.steps,
        ),
        const SizedBox(height: 16),
        _summary(
          'Calories burned',
          totals.calories,
          'kcal',
          Icons.local_fire_department,
          AppColors.calories,
        ),
        const SizedBox(height: 16),
        _summary(
          'Water intake',
          totals.water,
          'ml',
          Icons.water_drop,
          AppColors.water,
        ),
        const SizedBox(height: 24),
        Text('${vm.onDate(vm.today).length} records today'),
        const SizedBox(height: 8),
        const Text('Entries on the same date are added together.'),
        if (vm.hasDemo)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Sample records are included in the totals.'),
          ),
      ],
    );
  }

  Widget _summary(
    String label,
    int value,
    String unit,
    IconData icon,
    Color color,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 8),
                Text(
                  '${number(value)} $unit',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
