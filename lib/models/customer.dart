import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  @JsonKey(name: 'credit_limit')
  final double creditLimit;
  @JsonKey(name: 'outstanding_balance')
  final double outstandingBalance;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'shop_id')
  final int? shopId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.creditLimit = 0.0,
    this.outstandingBalance = 0.0,
    this.isActive = true,
    this.shopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    double? creditLimit,
    double? outstandingBalance,
    bool? isActive,
    int? shopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      creditLimit: creditLimit ?? this.creditLimit,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      isActive: isActive ?? this.isActive,
      shopId: shopId ?? this.shopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for credit management
  double get availableCredit => creditLimit - outstandingBalance;
  bool get hasOutstandingBalance => outstandingBalance > 0;
  bool get isOverCreditLimit => outstandingBalance > creditLimit;

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    creditLimit,
    outstandingBalance,
    isActive,
    shopId,
    createdAt,
    updatedAt,
  ];
}
