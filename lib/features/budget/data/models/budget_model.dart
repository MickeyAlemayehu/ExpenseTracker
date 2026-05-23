import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

enum BudgetPeriod { weekly, monthly, yearly }

class BudgetPeriodAdapter extends TypeAdapter<BudgetPeriod> {
  @override
  final int typeId = HiveTypeIds.budgetPeriod;

  @override
  BudgetPeriod read(BinaryReader reader) {
    final i = reader.readByte();
    return BudgetPeriod.values[i.clamp(0, BudgetPeriod.values.length - 1)];
  }

  @override
  void write(BinaryWriter writer, BudgetPeriod obj) {
    writer.writeByte(obj.index);
  }
}

extension BudgetPeriodX on BudgetPeriod {
  String get label => switch (this) {
        BudgetPeriod.weekly => 'Weekly',
        BudgetPeriod.monthly => 'Monthly',
        BudgetPeriod.yearly => 'Yearly',
      };
}

/// A budget either applies to a specific category or, when [categoryId] is null,
/// represents an overall spending limit.
class BudgetModel extends HiveObject {
  BudgetModel({
    required this.id,
    required this.name,
    required this.limit,
    required this.period,
    this.categoryId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  double limit;
  BudgetPeriod period;
  String? categoryId;
  DateTime createdAt;

  BudgetModel copyWith({
    String? name,
    double? limit,
    BudgetPeriod? period,
    String? categoryId,
  }) {
    return BudgetModel(
      id: id,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      period: period ?? this.period,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
    );
  }
}

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = HiveTypeIds.budgetModel;

  @override
  BudgetModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      limit: fields[2] as double,
      period: fields[3] as BudgetPeriod,
      categoryId: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.limit)
      ..writeByte(3)
      ..write(obj.period)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
