// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      status: $enumDecode(_$SaleStatusEnumMap, json['status']),
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      cashierId: json['cashierId'] as String,
      cashierName: json['cashierName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'discount': instance.discount,
      'total': instance.total,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'status': _$SaleStatusEnumMap[instance.status]!,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'cashierId': instance.cashierId,
      'cashierName': instance.cashierName,
      'createdAt': instance.createdAt.toIso8601String(),
      'notes': instance.notes,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.mobile: 'mobile',
  PaymentMethod.mixed: 'mixed',
};

const _$SaleStatusEnumMap = {
  SaleStatus.pending: 'pending',
  SaleStatus.completed: 'completed',
  SaleStatus.cancelled: 'cancelled',
  SaleStatus.refunded: 'refunded',
};
