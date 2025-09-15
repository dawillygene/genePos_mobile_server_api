import 'package:sqflite/sqflite.dart';
import '../models/customer.dart';
import '../models/payment.dart';
import 'database_helper.dart';

class CustomerService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CRUD Operations
  Future<int> createCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'credit_limit': customer.creditLimit,
      'outstanding_balance': customer.outstandingBalance,
      'is_active': customer.isActive ? 1 : 0,
      'shop_id': customer.shopId,
      'created_at': customer.createdAt.toIso8601String(),
      'updated_at': customer.updatedAt.toIso8601String(),
    });
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Customer.fromJson(maps.first);
    }
    return null;
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    if (maps.isNotEmpty) {
      return Customer.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Customer>> getAllCustomers({bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    String whereClause = activeOnly ? 'is_active = 1' : '';
    final maps = await db.query(
      'customers',
      where: whereClause,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Customer.fromJson(map)).toList();
  }

  Future<List<Customer>> searchCustomers(
    String query, {
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '(name LIKE ? OR phone LIKE ? OR email LIKE ?)';
    List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%'];

    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }

    final maps = await db.query(
      'customers',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Customer.fromJson(map)).toList();
  }

  Future<List<Customer>> getCustomersWithOutstandingBalance() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'outstanding_balance > 0 AND is_active = 1',
      orderBy: 'outstanding_balance DESC',
    );

    return maps.map((map) => Customer.fromJson(map)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      {
        'name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
        'credit_limit': customer.creditLimit,
        'outstanding_balance': customer.outstandingBalance,
        'is_active': customer.isActive ? 1 : 0,
        'shop_id': customer.shopId,
        'updated_at': customer.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deactivateCustomer(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Credit Management
  Future<bool> canCustomerMakeCreditPurchase(
    int customerId,
    double purchaseAmount,
  ) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return false;

    return customer.availableCredit >= purchaseAmount;
  }

  Future<double> updateOutstandingBalance(int customerId, double amount) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) {
      throw Exception('Customer not found');
    }

    final newBalance = customer.outstandingBalance + amount;
    if (newBalance < 0) {
      throw Exception('Invalid balance update');
    }

    final db = await _dbHelper.database;
    await db.update(
      'customers',
      {
        'outstanding_balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );

    return newBalance;
  }

  Future<int> recordPayment(Payment payment) async {
    final db = await _dbHelper.database;

    // Insert payment record
    final paymentId = await db.insert('payments', {
      'id': payment.id,
      'customer_id': payment.customerId,
      'amount': payment.amount,
      'payment_method': payment.paymentMethod,
      'notes': payment.notes,
      'transaction_id': payment.transactionId,
      'payment_type': payment.paymentType.toString().split('.').last,
      'shop_id': payment.shopId,
      'timestamp': payment.timestamp.toIso8601String(),
      'created_at': payment.createdAt.toIso8601String(),
      'updated_at': payment.updatedAt.toIso8601String(),
    });

    // Update customer's outstanding balance
    await updateOutstandingBalance(payment.customerId, -payment.amount);

    return paymentId;
  }

  Future<List<Payment>> getCustomerPayments(
    int customerId, {
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    String query = '''
      SELECT * FROM payments
      WHERE customer_id = ?
      ORDER BY timestamp DESC
    ''';

    List<dynamic> args = [customerId];

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    final maps = await db.rawQuery(query, args);
    return maps.map((map) => Payment.fromJson(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getCustomerTransactionHistory(
    int customerId,
  ) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT
        t.transaction_number,
        t.total,
        t.timestamp,
        t.payment_method,
        t.is_credit,
        p.amount as payment_amount,
        p.timestamp as payment_timestamp,
        p.payment_method as payment_method_used
      FROM transactions t
      LEFT JOIN payments p ON t.id = p.transaction_id
      WHERE t.customer_id = ?
      ORDER BY t.timestamp DESC
    ''',
      [customerId],
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getCustomerStatistics() async {
    final db = await _dbHelper.database;

    final totalCustomers =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM customers WHERE is_active = 1',
          ),
        ) ??
        0;

    final customersWithBalance =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM customers WHERE outstanding_balance > 0 AND is_active = 1',
          ),
        ) ??
        0;

    final totalOutstandingBalance = await db.rawQuery('''
      SELECT SUM(outstanding_balance) as total_balance
      FROM customers
      WHERE is_active = 1
    ''');

    final totalBalance =
        (totalOutstandingBalance.first['total_balance'] as num?)?.toDouble() ??
        0.0;

    final totalCreditLimit = await db.rawQuery('''
      SELECT SUM(credit_limit) as total_limit
      FROM customers
      WHERE is_active = 1
    ''');

    final totalLimit =
        (totalCreditLimit.first['total_limit'] as num?)?.toDouble() ?? 0.0;

    return {
      'total_customers': totalCustomers,
      'customers_with_outstanding_balance': customersWithBalance,
      'total_outstanding_balance': totalBalance,
      'total_credit_limit': totalLimit,
      'available_credit': totalLimit - totalBalance,
    };
  }

  Future<List<Map<String, dynamic>>> getTopCustomersByBalance({
    int limit = 10,
  }) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT
        id,
        name,
        phone,
        outstanding_balance,
        credit_limit,
        (credit_limit - outstanding_balance) as available_credit
      FROM customers
      WHERE is_active = 1 AND outstanding_balance > 0
      ORDER BY outstanding_balance DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  // Validation
  Future<bool> isPhoneUnique(String phone, {int? excludeId}) async {
    final db = await _dbHelper.database;
    String whereClause = 'phone = ?';
    List<dynamic> whereArgs = [phone];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM customers WHERE $whereClause',
            whereArgs,
          ),
        ) ??
        0;

    return count == 0;
  }

  Future<bool> isEmailUnique(String email, {int? excludeId}) async {
    final db = await _dbHelper.database;
    String whereClause = 'email = ?';
    List<dynamic> whereArgs = [email];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM customers WHERE $whereClause',
            whereArgs,
          ),
        ) ??
        0;

    return count == 0;
  }
}
