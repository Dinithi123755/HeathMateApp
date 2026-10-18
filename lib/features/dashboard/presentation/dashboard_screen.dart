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
    final count = vm.onDate(vm.today).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 110),
      children: [
        Text(
          'Today’s summary',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(vm.today),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _summary(
          context,
          'Steps walked',
          totals.steps,
          'steps',
          Icons.directions_walk_rounded,
          AppColors.steps,
        ),
        const SizedBox(height: 14),
        _summary(
          context,
          'Calories burned',
          totals.calories,
          'kcal',
          Icons.local_fire_department_rounded,
          AppColors.calories,
        ),
        const SizedBox(height: 14),
        _summary(
          context,
          'Water intake',
          totals.water,
          'ml',
          Icons.water_drop_rounded,
          AppColors.water,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'record' : 'records'} today',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Entries on the same date are added together.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _summary(
    BuildContext context,
    String label,
    int value,
    String unit,
    IconData icon,
    Color color,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.metric(context, color).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppColors.metric(context, color),
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: number(value),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -.5,
                    ),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
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
