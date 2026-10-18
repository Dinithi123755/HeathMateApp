import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../records/domain/health_record.dart';
import '../../records/presentation/health_view_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _period = 7;
  int _metric = 0;
  int _value(DailyTotals totals) => switch (_metric) {
    0 => totals.steps,
    1 => totals.calories,
    _ => totals.water,
  };
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final days = vm.days(_period);
    final values = days.map((day) => _value(vm.totalsOn(day))).toList();
    final total = vm.periodTotals(_period);
    final colors = [AppColors.steps, AppColors.calories, AppColors.water];
    final units = ['steps', 'kcal', 'ml'];
    final highest = values.fold<int>(0, math.max);
    final best = highest > 0 ? days[values.indexOf(highest)] : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const SectionTitle(
          'See your rhythm',
          subtitle: 'A clearer view of your everyday habits.',
        ),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('7 days')),
            ButtonSegment(value: 30, label: Text('30 days')),
          ],
          selected: {_period},
          onSelectionChanged: (value) => setState(() => _period = value.first),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          children: List.generate(
            3,
            (index) => ChoiceChip(
              selected: _metric == index,
              label: Text(['Steps', 'Calories', 'Water'][index]),
              onSelected: (_) => setState(() => _metric = index),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY ${['STEPS', 'CALORIES', 'WATER'][_metric]}',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${number(_value(total))} ${units[_metric]}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat.MMMd().format(days.first)} – ${DateFormat.MMMd().format(days.last)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(days.length, (index) {
                      final value = values[index];
                      final height = highest == 0
                          ? 3.0
                          : math.max(3.0, value / highest * 142);
                      return Expanded(
                        child: Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          message:
                              '${DateFormat.MMMd().format(days[index])}: ${number(value)} ${units[_metric]}',
                          child: Semantics(
                            label:
                                '${DateFormat.yMMMd().format(days[index])}: $value ${units[_metric]}',
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _period == 7 ? 5 : 2,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Container(
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: colors[_metric].withValues(
                                          alpha: value == 0
                                              ? .12
                                              : (index == days.length - 1
                                                    ? 1
                                                    : .6),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 18,
                                    child: Text(
                                      _period == 7
                                          ? DateFormat.E()
                                                .format(days[index])
                                                .substring(0, 1)
                                          : (index == 0 ||
                                                    index == days.length - 1 ||
                                                    index % 7 == 0
                                                ? '${days[index].day}'
                                                : ''),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tap a bar for its date and value.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _stat(
                  context,
                  'Daily average',
                  '${number((_value(total) / _period).round())} ${units[_metric]}',
                  Icons.insights,
                ),
                const Divider(height: 30),
                _stat(
                  context,
                  'Days with an entry',
                  '${vm.activeDays(_period)} / $_period',
                  Icons.event_available,
                ),
                const Divider(height: 30),
                _stat(
                  context,
                  'Highest day',
                  best == null ? 'No data yet' : DateFormat.MMMd().format(best),
                  Icons.emoji_events_outlined,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Averages include all $_period calendar days, including days without entries. Values are manually logged, not sensor measurements.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (vm.hasDemo)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Demo records are included. You can remove them in Settings.',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Text(label)),
      Flexible(
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
