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
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(vm.today),
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _summary(
          'Steps walked',
          totals.steps,
          'steps',
          Icons.directions_walk_rounded,
          AppColors.steps,
        ),
        const SizedBox(height: 14),
        _summary(
          'Calories burned',
          totals.calories,
          'kcal',
          Icons.local_fire_department_rounded,
          AppColors.calories,
        ),
        const SizedBox(height: 14),
        _summary(
          'Water intake',
          totals.water,
          'ml',
          Icons.water_drop_rounded,
          AppColors.water,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'record' : 'records'} today',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Entries on the same date are added together.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        if (vm.hasDemo)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Sample records are included in the totals.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: number(value),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -.5,
                    ),
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.muted,
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
