class Product {
  final int? id;
  final String? image;
  final String name;
  final String slug;
  final String sku;
  final String? description;
  final int? categoryId;
  final int? brandId;
  final int? unitId;
  final double price;
  final double discount;
  final String discountType;
  final double purchasePrice;
  final int quantity;
  final String? expireDate;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    this.image,
    required this.name,
    required this.slug,
    required this.sku,
    this.description,
    this.categoryId,
    this.brandId,
    this.unitId,
    this.price = 0.0,
    this.discount = 0.0,
    this.discountType = 'fixed',
    this.purchasePrice = 0.0,
    this.quantity = 0,
    this.expireDate,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'slug': slug,
      'sku': sku,
      'description': description,
      'category_id': categoryId,
      'brand_id': brandId,
      'unit_id': unitId,
      'price': price,
      'discount': discount,
      'discount_type': discountType,
      'purchase_price': purchasePrice,
      'quantity': quantity,
      'expire_date': expireDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
