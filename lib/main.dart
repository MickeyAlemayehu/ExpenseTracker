import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/budget/data/datasources/budget_local_datasource.dart';
import 'features/budget/data/models/budget_model.dart';
import 'features/budget/data/repositories/budget_repository_impl.dart';
import 'features/budget/presentation/providers/budget_provider.dart';
import 'features/categories/data/datasources/category_local_datasource.dart';
import 'features/categories/data/models/category_model.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/presentation/providers/categories_provider.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/models/app_settings.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/entities/payment_method.dart';
import 'features/transactions/domain/entities/transaction_type.dart';
import 'features/transactions/presentation/providers/transactions_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive and register all type adapters BEFORE opening boxes.
  await Hive.initFlutter();
  Hive
    ..registerAdapter(TransactionTypeAdapter())
    ..registerAdapter(PaymentMethodAdapter())
    ..registerAdapter(BudgetPeriodAdapter())
    ..registerAdapter(TransactionModelAdapter())
    ..registerAdapter(CategoryModelAdapter())
    ..registerAdapter(BudgetModelAdapter())
    ..registerAdapter(AppSettingsAdapter());

  // 2. Open boxes and construct repositories.
  final transactionDs = await TransactionLocalDataSource.open();
  final categoryDs = await CategoryLocalDataSource.open();
  final budgetDs = await BudgetLocalDataSource.open();
  final settingsDs = await SettingsLocalDataSource.open();

  final transactionRepo = TransactionRepositoryImpl(transactionDs);
  final categoryRepo = CategoryRepositoryImpl(categoryDs);
  final budgetRepo = BudgetRepositoryImpl(budgetDs);
  final settingsRepo = SettingsRepositoryImpl(settingsDs);

  // 3. Seed default categories on first run.
  await categoryRepo.seedDefaultsIfEmpty();

  // 4. Initialize service stubs (notifications, etc.)
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
        budgetRepositoryProvider.overrideWithValue(budgetRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
