import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'product.dart';

part 'cart_item.g.dart';

@JsonSerializable()
class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double discount;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
  });

  double get subtotal => (unitPrice * quantity) - discount;
  double get totalDiscount => discount;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? discount,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, unitPrice, discount];
}
