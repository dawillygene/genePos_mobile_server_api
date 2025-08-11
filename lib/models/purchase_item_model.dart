class PurchaseItem {
  final int? id;
  final int purchaseId;
  final int productId;
  final double purchasePrice;
  final double price;
  final int quantity;
  final String? createdAt;
  final String? updatedAt;

  PurchaseItem({
    this.id,
    required this.purchaseId,
    required this.productId,
    this.purchasePrice = 0.0,
    this.price = 0.0,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'purchase_price': purchasePrice,
      'price': price,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
