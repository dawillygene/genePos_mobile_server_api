// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: (json['id'] as num).toInt(),
      transactionNumber: json['transaction_number'] as String,
      userId: (json['user_id'] as num).toInt(),
      customerId: (json['customer_id'] as num?)?.toInt(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      amountTendered: (json['amount_tendered'] as num?)?.toDouble(),
      changeAmount: (json['change_amount'] as num?)?.toDouble(),
      paymentMethod:
          $enumDecode(_$PaymentMethodEnumMap, json['payment_method']),
      isCredit: json['is_credit'] as bool? ?? false,
      shopId: (json['shop_id'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_number': instance.transactionNumber,
      'user_id': instance.userId,
      'customer_id': instance.customerId,
      'subtotal': instance.subtotal,
      'tax_amount': instance.taxAmount,
      'discount_amount': instance.discountAmount,
      'total': instance.total,
      'amount_tendered': instance.amountTendered,
      'change_amount': instance.changeAmount,
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'is_credit': instance.isCredit,
      'shop_id': instance.shopId,
      'timestamp': instance.timestamp.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.credit: 'credit',
  PaymentMethod.transfer: 'transfer',
};
