import 'database_helper.dart';
import 'product_service.dart';
import 'transaction_service.dart';

class ReportingService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  // Dashboard Overview
  Future<Map<String, dynamic>> getDashboardOverview({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;

    String dateFilter = '';
    List<dynamic> dateArgs = [];

    if (startDate != null && endDate != null) {
      dateFilter = 'AND DATE(t.timestamp) BETWEEN DATE(?) AND DATE(?)';
      dateArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    // Today's sales
    final todaySales = await db.rawQuery('''
      SELECT
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_sales,
        COALESCE(SUM(amount_tendered), 0) as total_tendered,
        COALESCE(SUM(change_amount), 0) as total_change
      FROM transactions t
      WHERE DATE(timestamp) = DATE('now') $dateFilter
    ''', dateArgs);

    // This week's sales
    final weekSales = await db.rawQuery('''
      SELECT
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_sales
      FROM transactions t
      WHERE timestamp >= DATE('now', '-7 days') $dateFilter
    ''', dateArgs);

    // This month's sales
    final monthSales = await db.rawQuery('''
      SELECT
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_sales
      FROM transactions t
      WHERE timestamp >= DATE('now', '-30 days') $dateFilter
    ''', dateArgs);

    // Top selling products today
    final topProducts = await db.rawQuery('''
      SELECT
        p.name as product_name,
        p.sku,
        SUM(ti.quantity) as quantity_sold,
        SUM(ti.total_price) as revenue
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      WHERE DATE(t.timestamp) = DATE('now') $dateFilter
      GROUP BY p.id, p.name, p.sku
      ORDER BY quantity_sold DESC
      LIMIT 5
    ''', dateArgs);

    // Low stock alerts
    final lowStockProducts = await _productService.getLowStockProducts(
      threshold: 5,
    );

    // Recent transactions
    final recentTransactions = await _transactionService.getAllTransactions(
      limit: 10,
    );

    return {
      'today_sales': {
        'transaction_count':
            (todaySales.first['transaction_count'] as int?) ?? 0,
        'total_sales':
            (todaySales.first['total_sales'] as num?)?.toDouble() ?? 0.0,
        'total_tendered':
            (todaySales.first['total_tendered'] as num?)?.toDouble() ?? 0.0,
        'total_change':
            (todaySales.first['total_change'] as num?)?.toDouble() ?? 0.0,
      },
      'week_sales': {
        'transaction_count':
            (weekSales.first['transaction_count'] as int?) ?? 0,
        'total_sales':
            (weekSales.first['total_sales'] as num?)?.toDouble() ?? 0.0,
      },
      'month_sales': {
        'transaction_count':
            (monthSales.first['transaction_count'] as int?) ?? 0,
        'total_sales':
            (monthSales.first['total_sales'] as num?)?.toDouble() ?? 0.0,
      },
      'top_products_today': topProducts,
      'low_stock_alerts': lowStockProducts
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'sku': p.sku,
              'stock_quantity': p.stockQuantity,
              'category': p.category,
            },
          )
          .toList(),
      'recent_transactions': recentTransactions
          .map(
            (t) => {
              'id': t.id,
              'transaction_number': t.transactionNumber,
              'total': t.total,
              'timestamp': t.timestamp,
              'payment_method': t.paymentMethod,
              'is_credit': t.isCredit,
            },
          )
          .toList(),
    };
  }

  // Sales Reports
  Future<Map<String, dynamic>> getSalesReport({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    String? paymentMethod,
    bool? isCredit,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause += ' AND DATE(timestamp) BETWEEN DATE(?) AND DATE(?)';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    }

    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }

    if (paymentMethod != null) {
      whereClause += ' AND payment_method = ?';
      whereArgs.add(paymentMethod);
    }

    if (isCredit != null) {
      whereClause += ' AND is_credit = ?';
      whereArgs.add(isCredit ? 1 : 0);
    }

    // Summary statistics
    final summary = await db.rawQuery('''
      SELECT
        COUNT(*) as total_transactions,
        COALESCE(SUM(subtotal), 0) as total_subtotal,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COALESCE(SUM(discount_amount), 0) as total_discount,
        COALESCE(SUM(total), 0) as total_sales,
        COALESCE(AVG(total), 0) as average_transaction,
        COALESCE(MIN(total), 0) as min_transaction,
        COALESCE(MAX(total), 0) as max_transaction
      FROM transactions
      WHERE $whereClause
    ''', whereArgs);

    // Payment method breakdown
    final paymentBreakdown = await db.rawQuery('''
      SELECT
        payment_method,
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_amount
      FROM transactions
      WHERE $whereClause
      GROUP BY payment_method
      ORDER BY total_amount DESC
    ''', whereArgs);

    // Hourly sales breakdown
    final hourlyBreakdown = await db.rawQuery('''
      SELECT
        strftime('%H', timestamp) as hour,
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_sales
      FROM transactions
      WHERE $whereClause
      GROUP BY strftime('%H', timestamp)
      ORDER BY hour
    ''', whereArgs);

    // Daily sales breakdown
    final dailyBreakdown = await db.rawQuery('''
      SELECT
        DATE(timestamp) as date,
        COUNT(*) as transaction_count,
        COALESCE(SUM(total), 0) as total_sales,
        COALESCE(SUM(subtotal), 0) as total_subtotal,
        COALESCE(SUM(tax_amount), 0) as total_tax,
        COALESCE(SUM(discount_amount), 0) as total_discount
      FROM transactions
      WHERE $whereClause
      GROUP BY DATE(timestamp)
      ORDER BY date DESC
    ''', whereArgs);

    return {
      'summary': summary.first,
      'payment_breakdown': paymentBreakdown,
      'hourly_breakdown': hourlyBreakdown,
      'daily_breakdown': dailyBreakdown,
      'date_range': {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
      'filters': {
        'user_id': userId,
        'payment_method': paymentMethod,
        'is_credit': isCredit,
      },
    };
  }

  // Product Performance Reports
  Future<Map<String, dynamic>> getProductPerformanceReport({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit = 50,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause += ' AND DATE(t.timestamp) BETWEEN DATE(?) AND DATE(?)';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    }

    if (category != null) {
      whereClause += ' AND p.category = ?';
      whereArgs.add(category);
    }

    // Top selling products
    final topProducts = await db.rawQuery(
      '''
      SELECT
        p.id,
        p.name,
        p.sku,
        p.category,
        p.price,
        p.cost_price,
        COALESCE(SUM(ti.quantity), 0) as total_quantity_sold,
        COALESCE(SUM(ti.total_price), 0) as total_revenue,
        COALESCE(AVG(ti.unit_price), 0) as average_selling_price,
        COUNT(DISTINCT t.id) as transaction_count,
        COALESCE(SUM(ti.total_price - (ti.unit_price * ti.quantity)), 0) as total_profit
      FROM products p
      LEFT JOIN transaction_items ti ON p.id = ti.product_id
      LEFT JOIN transactions t ON ti.transaction_id = t.id AND ($whereClause)
      GROUP BY p.id, p.name, p.sku, p.category, p.price, p.cost_price
      ORDER BY total_revenue DESC
      LIMIT ?
    ''',
      [...whereArgs, limit],
    );

    // Product category performance
    final categoryPerformance = await db.rawQuery('''
      SELECT
        p.category,
        COUNT(DISTINCT p.id) as product_count,
        COALESCE(SUM(ti.quantity), 0) as total_quantity_sold,
        COALESCE(SUM(ti.total_price), 0) as total_revenue,
        COALESCE(AVG(ti.total_price / ti.quantity), 0) as average_price,
        COUNT(DISTINCT t.id) as transaction_count
      FROM products p
      LEFT JOIN transaction_items ti ON p.id = ti.product_id
      LEFT JOIN transactions t ON ti.transaction_id = t.id AND ($whereClause)
      GROUP BY p.category
      ORDER BY total_revenue DESC
    ''', whereArgs);

    // Slow moving products
    final slowMovingProducts = await db.rawQuery(
      '''
      SELECT
        p.id,
        p.name,
        p.sku,
        p.category,
        p.stock_quantity,
        p.price,
        COALESCE(MAX(t.timestamp), 'Never') as last_sold_date,
        COALESCE(SUM(ti.quantity), 0) as total_sold_30_days
      FROM products p
      LEFT JOIN transaction_items ti ON p.id = ti.product_id
      LEFT JOIN transactions t ON ti.transaction_id = t.id
        AND t.timestamp >= DATE('now', '-30 days')
      WHERE p.is_active = 1
      GROUP BY p.id, p.name, p.sku, p.category, p.stock_quantity, p.price
      HAVING total_sold_30_days = 0 OR total_sold_30_days < 5
      ORDER BY p.stock_quantity DESC, p.name
      LIMIT ?
    ''',
      [limit],
    );

    return {
      'top_products': topProducts,
      'category_performance': categoryPerformance,
      'slow_moving_products': slowMovingProducts,
      'date_range': {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
      'filters': {'category': category, 'limit': limit},
    };
  }

  // Customer Reports
  Future<Map<String, dynamic>> getCustomerReport({
    DateTime? startDate,
    DateTime? endDate,
    int? limit = 50,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause += ' AND DATE(t.timestamp) BETWEEN DATE(?) AND DATE(?)';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    }

    // Top customers by spending
    final topCustomers = await db.rawQuery(
      '''
      SELECT
        c.id,
        c.name,
        c.phone,
        c.email,
        c.credit_limit,
        c.outstanding_balance,
        COALESCE(SUM(t.total), 0) as total_spent,
        COUNT(t.id) as transaction_count,
        COALESCE(AVG(t.total), 0) as average_transaction,
        COALESCE(MAX(t.timestamp), 'Never') as last_purchase_date
      FROM customers c
      LEFT JOIN transactions t ON c.id = t.customer_id AND ($whereClause)
      WHERE c.is_active = 1
      GROUP BY c.id, c.name, c.phone, c.email, c.credit_limit, c.outstanding_balance
      ORDER BY total_spent DESC
      LIMIT ?
    ''',
      [...whereArgs, limit],
    );

    // Customer credit analysis
    final creditAnalysis = await db.rawQuery('''
      SELECT
        CASE
          WHEN outstanding_balance = 0 THEN 'No Balance'
          WHEN outstanding_balance > 0 AND outstanding_balance <= credit_limit * 0.5 THEN 'Low Balance'
          WHEN outstanding_balance > credit_limit * 0.5 AND outstanding_balance <= credit_limit * 0.8 THEN 'Medium Balance'
          WHEN outstanding_balance > credit_limit * 0.8 AND outstanding_balance <= credit_limit THEN 'High Balance'
          ELSE 'Over Limit'
        END as balance_category,
        COUNT(*) as customer_count,
        COALESCE(SUM(outstanding_balance), 0) as total_balance,
        COALESCE(AVG(outstanding_balance), 0) as average_balance
      FROM customers
      WHERE is_active = 1 AND credit_limit > 0
      GROUP BY balance_category
      ORDER BY total_balance DESC
    ''');

    // New customers acquired
    final newCustomers = await db.rawQuery('''
      SELECT
        DATE(created_at) as registration_date,
        COUNT(*) as new_customers
      FROM customers
      WHERE is_active = 1
        AND DATE(created_at) >= DATE('now', '-30 days')
      GROUP BY DATE(created_at)
      ORDER BY registration_date DESC
    ''');

    return {
      'top_customers': topCustomers,
      'credit_analysis': creditAnalysis,
      'new_customers': newCustomers,
      'date_range': {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
    };
  }

  // Inventory Reports
  Future<Map<String, dynamic>> getInventoryReport() async {
    final db = await _dbHelper.database;

    // Inventory value by category
    final inventoryByCategory = await db.rawQuery('''
      SELECT
        category,
        COUNT(*) as product_count,
        SUM(stock_quantity) as total_stock,
        SUM(price * stock_quantity) as total_value,
        AVG(price) as average_price,
        MIN(price) as min_price,
        MAX(price) as max_price
      FROM products
      WHERE is_active = 1
      GROUP BY category
      ORDER BY total_value DESC
    ''');

    // Stock movement summary
    final stockMovement = await db.rawQuery('''
      SELECT
        reason,
        COUNT(*) as adjustment_count,
        SUM(new_quantity - old_quantity) as net_change,
        SUM(CASE WHEN new_quantity > old_quantity THEN new_quantity - old_quantity ELSE 0 END) as total_added,
        SUM(CASE WHEN new_quantity < old_quantity THEN old_quantity - new_quantity ELSE 0 END) as total_removed
      FROM stock_adjustments
      WHERE timestamp >= DATE('now', '-30 days')
      GROUP BY reason
      ORDER BY adjustment_count DESC
    ''');

    // Products with no movement
    final stagnantInventory = await db.rawQuery('''
      SELECT
        p.id,
        p.name,
        p.sku,
        p.category,
        p.stock_quantity,
        p.price,
        COALESCE(MAX(sa.timestamp), 'Never') as last_movement,
        JULIANDAY('now') - JULIANDAY(COALESCE(MAX(sa.timestamp), p.created_at)) as days_since_movement
      FROM products p
      LEFT JOIN stock_adjustments sa ON p.id = sa.product_id
      WHERE p.is_active = 1
      GROUP BY p.id, p.name, p.sku, p.category, p.stock_quantity, p.price, p.created_at
      HAVING days_since_movement > 30 OR last_movement = 'Never'
      ORDER BY days_since_movement DESC
      LIMIT 20
    ''');

    return {
      'inventory_by_category': inventoryByCategory,
      'stock_movement': stockMovement,
      'stagnant_inventory': stagnantInventory,
      'inventory_summary': await _productService.getProductStatistics(),
    };
  }

  // Export Functions
  Future<List<Map<String, dynamic>>> exportTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE DATE(timestamp) BETWEEN DATE(?) AND DATE(?)';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    return await db.rawQuery('''
      SELECT
        t.transaction_number,
        t.timestamp,
        t.user_id,
        t.customer_id,
        t.subtotal,
        t.tax_amount,
        t.discount_amount,
        t.total,
        t.amount_tendered,
        t.change_amount,
        t.payment_method,
        CASE WHEN t.is_credit = 1 THEN 'Yes' ELSE 'No' END as is_credit,
        c.name as customer_name,
        c.phone as customer_phone
      FROM transactions t
      LEFT JOIN customers c ON t.customer_id = c.id
      $whereClause
      ORDER BY t.timestamp DESC
    ''', whereArgs);
  }

  Future<List<Map<String, dynamic>>> exportProducts() async {
    final db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        id,
        name,
        sku,
        description,
        price,
        cost_price,
        stock_quantity,
        barcode,
        category,
        image_url,
        CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END as status,
        created_at,
        updated_at
      FROM products
      ORDER BY category, name
    ''');
  }

  Future<List<Map<String, dynamic>>> exportCustomers() async {
    final db = await _dbHelper.database;

    return await db.rawQuery('''
      SELECT
        id,
        name,
        phone,
        email,
        credit_limit,
        outstanding_balance,
        credit_limit - outstanding_balance as available_credit,
        CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END as status,
        created_at,
        updated_at
      FROM customers
      ORDER BY name
    ''');
  }
}
