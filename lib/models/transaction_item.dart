import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'transaction_item.g.dart';

@JsonSerializable()
class TransactionItem extends Equatable {
  final int id;
  @JsonKey(name: 'transaction_id')
  final int transactionId;
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  @JsonKey(name: 'discount_amount')
  final double discountAmount;
  @JsonKey(name: 'total_price')
  final double totalPrice;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0.0,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);

  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    int? quantity,
    double? unitPrice,
    double? discountAmount,
    double? totalPrice,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transactionId,
    productId,
    quantity,
    unitPrice,
    discountAmount,
    totalPrice,
    notes,
    createdAt,
    updatedAt,
  ];
}
