import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'transaction.g.dart';

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('credit')
  credit,
  @JsonValue('transfer')
  transfer,
}

@JsonSerializable()
class Transaction extends Equatable {
  final int id;
  @JsonKey(name: 'transaction_number')
  final String transactionNumber;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'customer_id')
  final int? customerId;
  final double subtotal;
  @JsonKey(name: 'tax_amount')
  final double taxAmount;
  @JsonKey(name: 'discount_amount')
  final double discountAmount;
  final double total;
  @JsonKey(name: 'amount_tendered')
  final double? amountTendered;
  @JsonKey(name: 'change_amount')
  final double? changeAmount;
  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;
  @JsonKey(name: 'is_credit')
  final bool isCredit;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  final DateTime timestamp;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.transactionNumber,
    required this.userId,
    this.customerId,
    required this.subtotal,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.total,
    this.amountTendered,
    this.changeAmount,
    required this.paymentMethod,
    this.isCredit = false,
    this.shopId,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    int? id,
    String? transactionNumber,
    int? userId,
    int? customerId,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? total,
    double? amountTendered,
    double? changeAmount,
    PaymentMethod? paymentMethod,
    bool? isCredit,
    int? shopId,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      amountTendered: amountTendered ?? this.amountTendered,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isCredit: isCredit ?? this.isCredit,
      shopId: shopId ?? this.shopId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transactionNumber,
    userId,
    customerId,
    subtotal,
    taxAmount,
    discountAmount,
    total,
    amountTendered,
    changeAmount,
    paymentMethod,
    isCredit,
    shopId,
    timestamp,
    createdAt,
    updatedAt,
  ];
}
