class OrderTransaction {
  final int? id;
  final double amount;
  final int orderId;
  final int customerId;
  final int? userId;
  final String paidBy;
  final String? transactionId;
  final String? createdAt;
  final String? updatedAt;

  OrderTransaction({
    this.id,
    required this.amount,
    required this.orderId,
    required this.customerId,
    this.userId,
    required this.paidBy,
    this.transactionId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'order_id': orderId,
      'customer_id': customerId,
      'user_id': userId,
      'paid_by': paidBy,
      'transaction_id': transactionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
