// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      transactionId: (json['transaction_id'] as num?)?.toInt(),
      paymentType:
          $enumDecodeNullable(_$PaymentTypeEnumMap, json['payment_type']) ??
              PaymentType.loanRepayment,
      shopId: (json['shop_id'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'notes': instance.notes,
      'transaction_id': instance.transactionId,
      'payment_type': _$PaymentTypeEnumMap[instance.paymentType]!,
      'shop_id': instance.shopId,
      'timestamp': instance.timestamp.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PaymentTypeEnumMap = {
  PaymentType.loanRepayment: 'loan_repayment',
  PaymentType.advancePayment: 'advance_payment',
  PaymentType.creditPayment: 'credit_payment',
};
