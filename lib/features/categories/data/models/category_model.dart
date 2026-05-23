import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../transactions/domain/entities/transaction_type.dart';

/// User-defined or seeded transaction category.
class CategoryModel extends HiveObject {
  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  final String id;
  String name;

  /// Material icon codepoint, stored as int so it survives Hive serialization.
  int icon;

  /// ARGB color value.
  int colorValue;

  TransactionType type;
  bool isDefault;

  CategoryModel copyWith({
    String? name,
    int? icon,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = HiveTypeIds.categoryModel;

  @override
  CategoryModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as int,
      colorValue: fields[3] as int,
      type: fields[4] as TransactionType,
      isDefault: (fields[5] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isDefault);
  }
}
