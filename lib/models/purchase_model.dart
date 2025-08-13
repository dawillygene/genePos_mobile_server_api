class Purchase {
  final int? id;
  final int supplierId;
  final int userId;
  final double subTotal;
  final double tax;
  final double discountValue;
  final String discountType;
  final double shipping;
  final double grandTotal;
  final int status;
  final String date;
  final String? createdAt;
  final String? updatedAt;

  Purchase({
    this.id,
    required this.supplierId,
    required this.userId,
    this.subTotal = 0.0,
    this.tax = 0.0,
    this.discountValue = 0.0,
    this.discountType = 'fixed',
    this.shipping = 0.0,
    this.grandTotal = 0.0,
    required this.status,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'user_id': userId,
      'sub_total': subTotal,
      'tax': tax,
      'discount_value': discountValue,
      'discount_type': discountType,
      'shipping': shipping,
      'grand_total': grandTotal,
      'status': status,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      supplierId: map['supplier_id'],
      userId: map['user_id'],
      subTotal: map['sub_total'],
      tax: map['tax'],
      discountValue: map['discount_value'],
      discountType: map['discount_type'],
      shipping: map['shipping'],
      grandTotal: map['grand_total'],
      status: map['status'],
      date: map['date'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
