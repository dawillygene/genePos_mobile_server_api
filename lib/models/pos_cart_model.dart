class PosCart {
  final int? id;
  final int productId;
  final int userId;
  int quantity;
  final String? createdAt;
  final String? updatedAt;

  PosCart({
    this.id,
    required this.productId,
    required this.userId,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
