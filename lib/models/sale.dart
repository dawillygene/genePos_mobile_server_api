import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'cart_item.dart';

part 'sale.g.dart';

enum SaleStatus { pending, completed, cancelled, refunded }

enum PaymentMethod { cash, card, mobile, mixed }

@JsonSerializable()
class Sale extends Equatable {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String cashierId;
  final String cashierName;
  final DateTime createdAt;
  final String? notes;

  const Sale({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.cashierId,
    required this.cashierName,
    required this.createdAt,
    this.notes,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  Sale copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? cashierId,
    String? cashierName,
    DateTime? createdAt,
    String? notes,
  }) {
    return Sale(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    items,
    subtotal,
    tax,
    discount,
    total,
    paymentMethod,
    status,
    customerId,
    customerName,
    customerPhone,
    cashierId,
    cashierName,
    createdAt,
    notes,
  ];
}
