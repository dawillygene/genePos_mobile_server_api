import 'package:sqflite/sqflite.dart' as sql;
import '../models/transaction.dart' as txn_model;
import '../models/transaction_item.dart';
import '../models/cart_item.dart';
import 'database_helper.dart';
import 'product_service.dart';
import 'customer_service.dart';

class TransactionService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();

  // Transaction CRUD
  Future<int> createTransaction(txn_model.Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', {
      'id': transaction.id,
      'transaction_number': transaction.transactionNumber,
      'user_id': transaction.userId,
      'customer_id': transaction.customerId,
      'subtotal': transaction.subtotal,
      'tax_amount': transaction.taxAmount,
      'discount_amount': transaction.discountAmount,
      'total': transaction.total,
      'amount_tendered': transaction.amountTendered,
      'change_amount': transaction.changeAmount,
      'payment_method': transaction.paymentMethod.toString().split('.').last,
      'is_credit': transaction.isCredit ? 1 : 0,
      'shop_id': transaction.shopId,
      'timestamp': transaction.timestamp.toIso8601String(),
      'created_at': transaction.createdAt.toIso8601String(),
      'updated_at': transaction.updatedAt.toIso8601String(),
    });
  }

  Future<txn_model.Transaction?> getTransactionById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return txn_model.Transaction.fromJson(maps.first);
    }
    return null;
  }

  Future<txn_model.Transaction?> getTransactionByNumber(
    String transactionNumber,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'transaction_number = ?',
      whereArgs: [transactionNumber],
    );

    if (maps.isNotEmpty) {
      return txn_model.Transaction.fromJson(maps.first);
    }
    return null;
  }

  Future<List<txn_model.Transaction>> getAllTransactions({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'timestamp BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    String query = 'SELECT * FROM transactions';
    if (whereClause.isNotEmpty) {
      query += ' WHERE $whereClause';
    }
    query += ' ORDER BY timestamp DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
    }

    final maps = await db.rawQuery(query, whereArgs);
    return maps.map((map) => txn_model.Transaction.fromJson(map)).toList();
  }

  Future<List<txn_model.Transaction>> getTransactionsByUser(
    int userId, {
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    String query =
        'SELECT * FROM transactions WHERE user_id = ? ORDER BY timestamp DESC';
    List<dynamic> args = [userId];

    if (limit != null) {
      query += ' LIMIT $limit';
      args.add(limit);
    }

    final maps = await db.rawQuery(query, args);
    return maps.map((map) => txn_model.Transaction.fromJson(map)).toList();
  }

  Future<List<txn_model.Transaction>> getTransactionsByCustomer(
    int customerId, {
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    String query =
        'SELECT * FROM transactions WHERE customer_id = ? ORDER BY timestamp DESC';
    List<dynamic> args = [customerId];

    if (limit != null) {
      query += ' LIMIT $limit';
      args.add(limit);
    }

    final maps = await db.rawQuery(query, args);
    return maps.map((map) => txn_model.Transaction.fromJson(map)).toList();
  }

  // Transaction Items
  Future<int> addTransactionItem(TransactionItem item) async {
    final db = await _dbHelper.database;
    return await db.insert('transaction_items', {
      'id': item.id,
      'transaction_id': item.transactionId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'unit_price': item.unitPrice,
      'discount_amount': item.discountAmount,
      'total_price': item.totalPrice,
      'notes': item.notes,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    });
  }

  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => TransactionItem.fromJson(map)).toList();
  }

  // Complete Transaction Processing
  Future<String> processTransaction({
    required int userId,
    required List<CartItem> cartItems,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double total,
    required txn_model.PaymentMethod paymentMethod,
    double? amountTendered,
    int? customerId,
    bool isCredit = false,
  }) async {
    final db = await _dbHelper.database;

    // Generate transaction number
    final transactionNumber = await _generateTransactionNumber();

    // Validate stock availability
    for (var item in cartItems) {
      final product = await _productService.getProductById(item.product.id);
      if (product == null) {
        throw Exception('Product ${item.product.id} not found');
      }
      if (product.stockQuantity < item.quantity) {
        throw Exception('Insufficient stock for ${product.name}');
      }
    }

    // Validate credit purchase if applicable
    if (isCredit && customerId != null) {
      final canMakeCreditPurchase = await _customerService
          .canCustomerMakeCreditPurchase(customerId, total);
      if (!canMakeCreditPurchase) {
        throw Exception('Customer does not have sufficient credit limit');
      }
    }

    // Calculate change
    double? changeAmount;
    if (amountTendered != null &&
        paymentMethod != txn_model.PaymentMethod.credit) {
      changeAmount = amountTendered - total;
      if (changeAmount < 0) {
        throw Exception('Insufficient payment amount');
      }
    }

    // Start transaction
    await db.transaction((txn) async {
      // Create transaction record
      final transactionId = await txn.insert('transactions', {
        'transaction_number': transactionNumber,
        'user_id': userId,
        'customer_id': customerId,
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'discount_amount': discountAmount,
        'total': total,
        'amount_tendered': amountTendered,
        'change_amount': changeAmount,
        'payment_method': paymentMethod.toString().split('.').last,
        'is_credit': isCredit ? 1 : 0,
        'timestamp': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Add transaction items and update stock
      for (var item in cartItems) {
        await txn.insert('transaction_items', {
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'discount_amount': item.discount,
          'total_price': item.subtotal,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Update product stock
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ?, updated_at = ? WHERE id = ?',
          [item.quantity, DateTime.now().toIso8601String(), item.product.id],
        );

        // Record stock adjustment
        await txn.insert('stock_adjustments', {
          'product_id': item.product.id,
          'old_quantity': 0, // Will be updated with actual old quantity
          'new_quantity': 0, // Will be updated with actual new quantity
          'reason': 'sale',
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Update customer balance if credit purchase
      if (isCredit && customerId != null) {
        await txn.rawUpdate(
          'UPDATE customers SET outstanding_balance = outstanding_balance + ?, updated_at = ? WHERE id = ?',
          [total, DateTime.now().toIso8601String(), customerId],
        );
      }
    });

    return transactionNumber;
  }

  Future<String> _generateTransactionNumber() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final db = await _dbHelper.database;
    final count =
        sql.Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE DATE(timestamp) = DATE(?)',
            [now.toIso8601String()],
          ),
        ) ??
        0;

    final sequence = (count + 1).toString().padLeft(4, '0');
    return 'TXN$dateStr$sequence';
  }

  // Transaction Statistics
  Future<Map<String, dynamic>> getTransactionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;

    String dateFilter = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateFilter = 'WHERE DATE(timestamp) BETWEEN DATE(?) AND DATE(?)';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    final totalTransactions =
        sql.Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions $dateFilter',
            dateArgs,
          ),
        ) ??
        0;

    final totalRevenue = await db.rawQuery(
      'SELECT SUM(total) as revenue FROM transactions $dateFilter',
      dateArgs,
    );

    final revenue = (totalRevenue.first['revenue'] as num?)?.toDouble() ?? 0.0;

    final creditTransactions =
        sql.Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE is_credit = 1 $dateFilter',
            dateArgs,
          ),
        ) ??
        0;

    final cashTransactions =
        sql.Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE payment_method = "cash" $dateFilter',
            dateArgs,
          ),
        ) ??
        0;

    final cardTransactions =
        sql.Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM transactions WHERE payment_method = "card" $dateFilter',
            dateArgs,
          ),
        ) ??
        0;

    return {
      'total_transactions': totalTransactions,
      'total_revenue': revenue,
      'credit_transactions': creditTransactions,
      'cash_transactions': cashTransactions,
      'card_transactions': cardTransactions,
      'average_transaction_value': totalTransactions > 0
          ? revenue / totalTransactions
          : 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getDailySales({int days = 7}) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        DATE(timestamp) as date,
        COUNT(*) as transaction_count,
        SUM(total) as daily_revenue,
        SUM(CASE WHEN is_credit = 1 THEN total ELSE 0 END) as credit_sales,
        SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END) as cash_sales
      FROM transactions
      WHERE timestamp >= DATE('now', '-$days days')
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;

    String dateFilter = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateFilter = 'AND t.timestamp BETWEEN ? AND ?';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    return await db.rawQuery(
      '''
      SELECT
        p.name as product_name,
        p.sku,
        SUM(ti.quantity) as total_quantity_sold,
        SUM(ti.total_price) as total_revenue,
        COUNT(DISTINCT t.id) as transaction_count
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      WHERE 1=1 $dateFilter
      GROUP BY p.id, p.name, p.sku
      ORDER BY total_quantity_sold DESC
      LIMIT ?
    ''',
      [...dateArgs, limit],
    );
  }

  // Void/Refund Transaction (simplified - in real app would need more complex logic)
  Future<bool> voidTransaction(int transactionId, int userId) async {
    final db = await _dbHelper.database;

    final transaction = await getTransactionById(transactionId);
    if (transaction == null) {
      return false;
    }

    // Only allow voiding within 24 hours (configurable)
    final transactionTime = transaction.timestamp;
    final now = DateTime.now();
    if (now.difference(transactionTime).inHours > 24) {
      throw Exception('Transaction cannot be voided after 24 hours');
    }

    await db.transaction((txn) async {
      // Get transaction items
      final items = await getTransactionItems(transactionId);

      // Restore stock
      for (var item in items) {
        await txn.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity + ?, updated_at = ? WHERE id = ?',
          [item.quantity, DateTime.now().toIso8601String(), item.productId],
        );

        // Record stock adjustment
        await txn.insert('stock_adjustments', {
          'product_id': item.productId,
          'old_quantity': 0, // Will be calculated
          'new_quantity': 0, // Will be calculated
          'reason': 'return',
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Restore customer balance if credit transaction
      if (transaction.isCredit && transaction.customerId != null) {
        await txn.rawUpdate(
          'UPDATE customers SET outstanding_balance = outstanding_balance - ?, updated_at = ? WHERE id = ?',
          [
            transaction.total,
            DateTime.now().toIso8601String(),
            transaction.customerId,
          ],
        );
      }

      // Mark transaction as voided (you might want to add a status field)
      await txn.update(
        'transactions',
        {'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });

    return true;
  }
}
