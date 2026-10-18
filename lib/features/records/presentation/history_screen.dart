import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../domain/health_record.dart';
import 'health_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final VoidCallback onAdd;
  final ValueChanged<HealthRecord> onEdit;
  final ValueChanged<HealthRecord> onDelete;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final rows = vm.filtered;
    final filtered = vm.filterStart != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const SectionTitle(
          'Your health journal',
          subtitle: 'Every small effort has a place here.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All records'),
              selected: !filtered,
              onSelected: (_) => vm.filter(null, null),
            ),
            ActionChip(
              avatar: const Icon(Icons.today, size: 18),
              label: const Text('Today'),
              onPressed: () => vm.filter(vm.today, vm.today),
            ),
            ActionChip(
              avatar: const Icon(Icons.search, size: 18),
              label: const Text('By date'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: vm.filterStart ?? vm.today,
                  firstDate: DateTime(2000),
                  lastDate: vm.today,
                );
                if (date != null) vm.filter(date, date);
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: const Text('Date range'),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: vm.today,
                  initialDateRange: filtered
                      ? DateTimeRange(
                          start: vm.filterStart!,
                          end: vm.filterEnd!,
                        )
                      : null,
                );
                if (range != null) vm.filter(range.start, range.end);
              },
            ),
          ],
        ),
        if (filtered)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${DateFormat.yMMMd().format(vm.filterStart!)} – ${DateFormat.yMMMd().format(vm.filterEnd!)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear date filter',
                  onPressed: () => vm.filter(null, null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(
          '${rows.length} ${rows.length == 1 ? 'record' : 'records'} · Newest first',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (rows.isEmpty)
          EmptyState(
            title: filtered
                ? 'No entries for these dates'
                : 'Your journal starts here',
            message: filtered
                ? 'Try another date or clear the filter to see all entries.'
                : 'Log your first activity to build a picture of your progress.',
            action: TextButton(
              onPressed: filtered ? () => vm.filter(null, null) : onAdd,
              child: Text(filtered ? 'Clear filter' : 'Log activity'),
            ),
          )
        else
          ...rows.map(
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
