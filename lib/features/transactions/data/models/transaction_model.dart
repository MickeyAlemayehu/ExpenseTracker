import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/transaction_type.dart';

/// A single income or expense entry. Persisted in Hive.
///
/// Hive typeId is centralized in [HiveTypeIds.transactionModel]. Never reuse.
class TransactionModel extends HiveObject {
  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.notes,
    this.receiptPath,
  });

  final String id;
  String title;
  double amount;
  TransactionType type;
  String categoryId;
  DateTime date;
  PaymentMethod paymentMethod;
  String? notes;
  String? receiptPath;

  TransactionModel copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? notes,
    String? receiptPath,
  }) {
    return TransactionModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  /// Signed amount: positive for income, negative for expense.
  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = HiveTypeIds.transactionModel;

  @override
  TransactionModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as TransactionType,
      categoryId: fields[4] as String,
      date: fields[5] as DateTime,
      paymentMethod: fields[6] as PaymentMethod,
      notes: fields[7] as String?,
      receiptPath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.receiptPath);
  }
}
