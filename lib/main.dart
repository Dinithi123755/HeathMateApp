import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/health_database.dart';
import 'features/records/data/health_repository.dart';
import 'features/records/presentation/health_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final viewModel = HealthViewModel(SqliteHealthRepository(HealthDatabase()));
  runApp(HealthMateApp(viewModel: viewModel));
  viewModel.initialize();
}
