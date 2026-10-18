import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../../records/domain/health_record.dart';
import '../../records/presentation/health_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _goals(BuildContext context, HealthViewModel vm) async {
    final form = GlobalKey<FormState>();
    final fields = [
      TextEditingController(text: '${vm.settings.stepsGoal}'),
      TextEditingController(text: '${vm.settings.caloriesGoal}'),
      TextEditingController(text: '${vm.settings.waterGoal}'),
    ];
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your daily goals'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose targets that suit you. These are personal tracking goals, not medical recommendations.',
                ),
                const SizedBox(height: 20),
                ...List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: fields[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: [
                          'Steps',
                          'Calories (kcal)',
                          'Water (ml)',
                        ][i],
                      ),
                      validator: (value) {
                        final error = RecordRules.number(
                          value,
                          'goal',
                          [200000, 30000, 20000][i],
                        );
                        return error ??
                            (int.parse(value!.trim()) == 0
                                ? 'Goal must be above zero.'
                                : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save goals'),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) {
      final success = await vm.updateSettings(
        vm.settings.copyWith(
          stepsGoal: int.parse(fields[0].text.trim()),
          caloriesGoal: int.parse(fields[1].text.trim()),
          waterGoal: int.parse(fields[2].text.trim()),
        ),
      );
      if (context.mounted) {
        feedbackMessage(
          context,
          success ? 'Your goals are updated.' : vm.error!,
        );
      }
    }
    // Dialog route animations may still be using the controllers until disposed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final field in fields) {
      field.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const SectionTitle(
          'Make it yours',
          subtitle: 'Small habits, on your terms.',
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Icon(Icons.flag_outlined),
                title: const Text(
                  'Daily goals',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${number(vm.settings.stepsGoal)} steps · ${number(vm.settings.caloriesGoal)} kcal · ${number(vm.settings.waterGoal)} ml',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: vm.busy ? null : () => _goals(context, vm),
              ),
              const Divider(height: 1, indent: 18, endIndent: 18),
              SwitchListTile(
                contentPadding: const EdgeInsets.all(18),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark appearance'),
                value: vm.settings.darkMode,
                onChanged: vm.busy
                    ? null
                    : (value) async {
                        final success = await vm.updateSettings(
                          vm.settings.copyWith(darkMode: value),
                        );
                        if (!success && context.mounted) {
                          feedbackMessage(context, vm.error!);
                        }
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          'Explore with sample data',
          subtitle: 'Try the dashboard and insights with 14 demo days.',
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Icon(Icons.science_outlined),
                title: Text(
                  vm.hasDemo ? 'Refresh demo records' : 'Load demo records',
                ),
                subtitle: const Text(
                  'Clearly labelled samples. Personal records stay safe.',
                ),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: vm.busy
                    ? null
                    : () async {
                        if (!await confirm(
                          context,
                          title: 'Load demo data?',
                          message:
                              'Add 14 sample daily records. They will appear in your totals and charts, and can be removed separately.',
                          action: 'Load demo',
                        )) {
                          return;
                        }
                        final success = await vm.loadDemo();
                        if (context.mounted) {
                          feedbackMessage(
                            context,
                            success ? '14 demo records loaded.' : vm.error!,
                          );
                        }
                      },
              ),
              if (vm.hasDemo) ...[
                const Divider(height: 1, indent: 18, endIndent: 18),
                ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('Remove demo records'),
                  subtitle: const Text(
                    'Only labelled demo entries will be deleted.',
                  ),
                  onTap: vm.busy
                      ? null
                      : () async {
                          if (!await confirm(
                            context,
                            title: 'Remove demo records?',
                            message:
                                'Your personal records and goals will be kept.',
                            action: 'Remove demo',
                          )) {
                            return;
                          }
                          final success = await vm.removeDemo();
                          if (context.mounted) {
                            feedbackMessage(
                              context,
                              success ? 'Demo records removed.' : vm.error!,
                            );
                          }
                        },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('About HealthMate'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.spa_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'HealthMate 1.0.0',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'A personal health & wellness journal. Log steps, calories burned and water intake, then look back on your progress.',
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your data stays on this device. No account, ads or cloud service. Uninstalling the app removes its local records. Keep your device secure.',
                ),
                const SizedBox(height: 14),
                const Text(
                  'Activities are entered manually. This app does not measure health data or provide medical advice.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'HealthMate',
                    applicationVersion: '1.0.0',
                  ),
                  child: const Text('Open-source licences'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
