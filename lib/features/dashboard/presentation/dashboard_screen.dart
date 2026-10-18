import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../records/domain/health_record.dart';
import '../../records/presentation/health_view_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.onAdd,
    required this.onHistory,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final VoidCallback onAdd;
  final VoidCallback onHistory;
  final ValueChanged<HealthRecord> onEdit;
  final ValueChanged<HealthRecord> onDelete;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final totals = vm.todayTotals;
    final goals = vm.settings;
    final rows = vm.onDate(vm.today);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        Text(
          DateFormat('EEEE, d MMMM').format(vm.today).toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.7,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A little better,\nevery day.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF095C50), Color(0xFF168576)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR DAILY MOMENTUM',
                      style: TextStyle(
                        color: Color(0xFFB7DDD1),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${vm.streak} day${vm.streak == 1 ? '' : 's'} in a row',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rows.isEmpty
                          ? 'Your next small win starts here.'
                          : 'You showed up today. That matters.',
                      style: const TextStyle(
                        color: Color(0xFFE0F3EB),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.spa_rounded, color: Color(0xFFA8D9B8), size: 54),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          'Today at a glance',
          subtitle: 'Your activities, all in one place',
        ),
        _GoalCard(
          title: 'Steps walked',
          value: totals.steps,
          goal: goals.stepsGoal,
          unit: 'steps',
          color: AppColors.steps,
          icon: Icons.directions_walk_rounded,
        ),
        const SizedBox(height: 12),
        _GoalCard(
          title: 'Calories burned',
          value: totals.calories,
          goal: goals.caloriesGoal,
          unit: 'kcal',
          color: AppColors.calories,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 12),
        _GoalCard(
          title: 'Water intake',
          value: totals.water,
          goal: goals.waterGoal,
          unit: 'ml',
          color: AppColors.water,
          icon: Icons.water_drop_rounded,
        ),
        const SizedBox(height: 24),
        SectionTitle(
          'Today’s entries',
          subtitle:
              '${rows.length} recorded ${rows.length == 1 ? 'activity' : 'activities'}',
          action: TextButton(
            onPressed: onHistory,
            child: const Text('View all'),
          ),
        ),
        if (vm.hasDemo)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Demo data is included in summaries. Remove it in Settings for personal tracking.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        if (rows.isEmpty)
          EmptyState(
            title: 'Make your first small step',
            message:
                'Add steps, calories or a glass of water to start your day.',
            action: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Log activity'),
            ),
          )
        else
          ...rows
              .take(3)
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecordCard(
                    record: row,
                    onEdit: () => onEdit(row),
                    onDelete: () => onDelete(row),
                  ),
                ),
              ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
    required this.icon,
  });
  final String title;
  final int value;
  final int goal;
  final String unit;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Semantics(
      label:
          '$title: $value $unit. Goal $goal. ${(value / goal * 100).round()} percent.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            text: number(value),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.6,
                            ),
                            children: [
                              TextSpan(
                                text: ' $unit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (value >= goal)
                    Icon(Icons.check_circle_rounded, color: color),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withValues(alpha: .10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal ${number(goal)} $unit',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    '${(value / goal * 100).round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
