import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment.g.dart';

enum PaymentType {
  @JsonValue('loan_repayment')
  loanRepayment,
  @JsonValue('advance_payment')
  advancePayment,
  @JsonValue('credit_payment')
  creditPayment,
}

@JsonSerializable()
class Payment extends Equatable {
  final int id;
  @JsonKey(name: 'customer_id')
  final int customerId;
  final double amount;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String? notes;
  @JsonKey(name: 'transaction_id')
  final int? transactionId;
  @JsonKey(name: 'payment_type')
  final PaymentType paymentType;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  final DateTime timestamp;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
    this.transactionId,
    this.paymentType = PaymentType.loanRepayment,
    this.shopId,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  Payment copyWith({
    int? id,
    int? customerId,
    double? amount,
    String? paymentMethod,
    String? notes,
    int? transactionId,
    PaymentType? paymentType,
    int? shopId,
    DateTime? timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      transactionId: transactionId ?? this.transactionId,
      paymentType: paymentType ?? this.paymentType,
      shopId: shopId ?? this.shopId,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    amount,
    paymentMethod,
    notes,
    transactionId,
    paymentType,
    shopId,
    timestamp,
    createdAt,
    updatedAt,
  ];
}
