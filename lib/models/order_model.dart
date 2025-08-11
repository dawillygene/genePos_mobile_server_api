class Order {
  final int? id;
  final int userId;
  final int customerId;
  final double discount;
  final double subTotal;
  final double total;
  final double paid;
  final double due;
  final String? note;
  final bool isReturned;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  Order({
    this.id,
    required this.userId,
    required this.customerId,
    this.discount = 0.0,
    this.subTotal = 0.0,
    this.total = 0.0,
    this.paid = 0.0,
    this.due = 0.0,
    this.note,
    this.isReturned = false,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'customer_id': customerId,
      'discount': discount,
      'sub_total': subTotal,
      'total': total,
      'paid': paid,
      'due': due,
      'note': note,
      'is_returned': isReturned ? 1 : 0,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
