import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// Income vs expense classifier.
enum TransactionType { income, expense }

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = HiveTypeIds.transactionType;

  @override
  TransactionType read(BinaryReader reader) {
    final i = reader.readByte();
    return i == 0 ? TransactionType.income : TransactionType.expense;
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj == TransactionType.income ? 0 : 1);
  }
}

extension TransactionTypeX on TransactionType {
  String get label => this == TransactionType.income ? 'Income' : 'Expense';
  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}
