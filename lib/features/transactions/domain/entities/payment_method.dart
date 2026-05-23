import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// How a transaction was paid.
enum PaymentMethod { cash, card, bankTransfer, mobileMoney, other }

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = HiveTypeIds.paymentMethod;

  @override
  PaymentMethod read(BinaryReader reader) {
    final i = reader.readByte();
    return PaymentMethod.values[i.clamp(0, PaymentMethod.values.length - 1)];
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    writer.writeByte(obj.index);
  }
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.card => 'Card',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.mobileMoney => 'Mobile Money',
        PaymentMethod.other => 'Other',
      };

  String get icon => switch (this) {
        PaymentMethod.cash => '💵',
        PaymentMethod.card => '💳',
        PaymentMethod.bankTransfer => '🏦',
        PaymentMethod.mobileMoney => '📱',
        PaymentMethod.other => '•',
      };
}
