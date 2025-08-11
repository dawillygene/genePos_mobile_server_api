class OrderProduct {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double purchasePrice;
  final double discount;
  final double subTotal;
  final double total;
  final String? createdAt;
  final String? updatedAt;

  OrderProduct({
    this.id,
    required this.orderId,
    required this.productId,
    this.quantity = 1,
    this.price = 0.0,
    this.purchasePrice = 0.0,
    this.discount = 0.0,
    this.subTotal = 0.0,
    this.total = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'purchase_price': purchasePrice,
      'discount': discount,
      'sub_total': subTotal,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
