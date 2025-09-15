// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockAdjustment _$StockAdjustmentFromJson(Map<String, dynamic> json) =>
    StockAdjustment(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      oldQuantity: (json['old_quantity'] as num).toInt(),
      newQuantity: (json['new_quantity'] as num).toInt(),
      reason: $enumDecode(_$AdjustmentReasonEnumMap, json['reason']),
      notes: json['notes'] as String?,
      userId: (json['user_id'] as num).toInt(),
      shopId: (json['shop_id'] as num?)?.toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StockAdjustmentToJson(StockAdjustment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'old_quantity': instance.oldQuantity,
      'new_quantity': instance.newQuantity,
      'reason': _$AdjustmentReasonEnumMap[instance.reason]!,
      'notes': instance.notes,
      'user_id': instance.userId,
      'shop_id': instance.shopId,
      'timestamp': instance.timestamp.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$AdjustmentReasonEnumMap = {
  AdjustmentReason.sale: 'sale',
  AdjustmentReason.purchase: 'purchase',
  AdjustmentReason.return_: 'return',
  AdjustmentReason.damage: 'damage',
  AdjustmentReason.loss: 'loss',
  AdjustmentReason.correction: 'correction',
  AdjustmentReason.initialStock: 'initial_stock',
  AdjustmentReason.manualAdjustment: 'manual_adjustment',
};
