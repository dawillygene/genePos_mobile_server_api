import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'stock_adjustment.g.dart';

enum AdjustmentReason {
  @JsonValue('sale')
  sale,
  @JsonValue('purchase')
  purchase,
  @JsonValue('return')
  return_,
  @JsonValue('damage')
  damage,
  @JsonValue('loss')
  loss,
  @JsonValue('correction')
  correction,
  @JsonValue('initial_stock')
  initialStock,
  @JsonValue('manual_adjustment')
  manualAdjustment,
}

@JsonSerializable()
class StockAdjustment extends Equatable {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'old_quantity')
  final int oldQuantity;
  @JsonKey(name: 'new_quantity')
  final int newQuantity;
  final AdjustmentReason reason;
  final String? notes;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  final DateTime timestamp;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const StockAdjustment({
    required this.id,
    required this.productId,
    required this.oldQuantity,
    required this.newQuantity,
    required this.reason,
    this.notes,
    required this.userId,
    this.shopId,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockAdjustment.fromJson(Map<String, dynamic> json) =>
      _$StockAdjustmentFromJson(json);
  Map<String, dynamic> toJson() => _$StockAdjustmentToJson(this);

  StockAdjustment copyWith({
    int? id,
    int? productId,
    int? oldQuantity,
    int? newQuantity,
    AdjustmentReason? reason,
    String? notes,
    int? userId,
    int? shopId,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockAdjustment(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      oldQuantity: oldQuantity ?? this.oldQuantity,
      newQuantity: newQuantity ?? this.newQuantity,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper properties
  int get quantityDifference => newQuantity - oldQuantity;
  bool get isIncrease => quantityDifference > 0;
  bool get isDecrease => quantityDifference < 0;

  @override
  List<Object?> get props => [
    id,
    productId,
    oldQuantity,
    newQuantity,
    reason,
    notes,
    userId,
    shopId,
    timestamp,
    createdAt,
    updatedAt,
  ];
}
