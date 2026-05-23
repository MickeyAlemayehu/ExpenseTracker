/// Centralized Hive box names. One source of truth so renames stay safe.
class HiveBoxes {
  HiveBoxes._();

  static const String transactions = 'transactions_box';
  static const String categories = 'categories_box';
  static const String budgets = 'budgets_box';
  static const String settings = 'settings_box';
}

/// Hive typeId registry. NEVER reuse a number — it corrupts on-disk data.
class HiveTypeIds {
  HiveTypeIds._();

  static const int transactionModel = 0;
  static const int categoryModel = 1;
  static const int budgetModel = 2;
  static const int appSettingsModel = 3;
  static const int transactionType = 10;
  static const int paymentMethod = 11;
  static const int budgetPeriod = 12;
}
