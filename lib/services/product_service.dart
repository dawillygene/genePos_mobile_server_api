import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/stock_adjustment.dart';
import 'database_helper.dart';

class ProductService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CRUD Operations
  Future<int> createProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.insert('products', {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'cost_price': product.costPrice,
      'stock_quantity': product.stockQuantity,
      'barcode': product.barcode,
      'sku': product.sku,
      'category': product.category,
      'image_url': product.imageUrl,
      'is_active': product.isActive ? 1 : 0,
      'shop_id': product.shopId,
      'created_at': product.createdAt.toIso8601String(),
      'updated_at': product.updatedAt.toIso8601String(),
    });
  }

  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  Future<Product?> getProductBySku(String sku) async {
    final db = await _dbHelper.database;
    final maps = await db.query('products', where: 'sku = ?', whereArgs: [sku]);

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Product>> getAllProducts({bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    String whereClause = activeOnly ? 'is_active = 1' : '';
    final maps = await db.query(
      'products',
      where: whereClause,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product.fromJson(map)).toList();
  }

  Future<List<Product>> getProductsByCategory(
    String category, {
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = 'category = ?';
    List<dynamic> whereArgs = [category];

    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }

    final maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product.fromJson(map)).toList();
  }

  Future<List<Product>> searchProducts(
    String query, {
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '(name LIKE ? OR sku LIKE ? OR barcode LIKE ?)';
    List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%'];

    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }

    final maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product.fromJson(map)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.update(
      'products',
      {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'cost_price': product.costPrice,
        'stock_quantity': product.stockQuantity,
        'barcode': product.barcode,
        'sku': product.sku,
        'category': product.category,
        'image_url': product.imageUrl,
        'is_active': product.isActive ? 1 : 0,
        'shop_id': product.shopId,
        'updated_at': product.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deactivateProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'products',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inventory Management
  Future<int> updateStockQuantity(
    int productId,
    int newQuantity,
    int userId, {
    String? reason,
    String? notes,
  }) async {
    final db = await _dbHelper.database;

    // Get current product
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final oldQuantity = product.stockQuantity;

    // Update product stock
    await db.update(
      'products',
      {
        'stock_quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );

    // Record stock adjustment
    await db.insert('stock_adjustments', {
      'product_id': productId,
      'old_quantity': oldQuantity,
      'new_quantity': newQuantity,
      'reason': reason ?? 'manual_adjustment',
      'notes': notes,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    return newQuantity;
  }

  Future<int> adjustStock(
    int productId,
    int adjustment,
    int userId, {
    AdjustmentReason reason = AdjustmentReason.manualAdjustment,
    String? notes,
  }) async {
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final newQuantity = product.stockQuantity + adjustment;
    if (newQuantity < 0) {
      throw Exception('Insufficient stock');
    }

    return await updateStockQuantity(
      productId,
      newQuantity,
      userId,
      reason: reason.toString().split('.').last,
      notes: notes,
    );
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'stock_quantity <= ? AND is_active = 1',
      whereArgs: [threshold],
      orderBy: 'stock_quantity ASC',
    );

    return maps.map((map) => Product.fromJson(map)).toList();
  }

  Future<List<Product>> getOutOfStockProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'products',
      where: 'stock_quantity = 0 AND is_active = 1',
      orderBy: 'name ASC',
    );

    return maps.map((map) => Product.fromJson(map)).toList();
  }

  // Stock Adjustment History
  Future<List<StockAdjustment>> getStockAdjustmentsForProduct(
    int productId,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'stock_adjustments',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => StockAdjustment.fromJson(map)).toList();
  }

  Future<List<StockAdjustment>> getRecentStockAdjustments({
    int limit = 50,
  }) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'stock_adjustments',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => StockAdjustment.fromJson(map)).toList();
  }

  // Statistics
  Future<Map<String, dynamic>> getProductStatistics() async {
    final db = await _dbHelper.database;

    final totalProducts =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE is_active = 1',
          ),
        ) ??
        0;

    final lowStockProducts =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE stock_quantity <= 10 AND is_active = 1',
          ),
        ) ??
        0;

    final outOfStockProducts =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE stock_quantity = 0 AND is_active = 1',
          ),
        ) ??
        0;

    final totalValue = await db.rawQuery('''
      SELECT SUM(price * stock_quantity) as total_value
      FROM products
      WHERE is_active = 1
    ''');

    final totalValueAmount =
        (totalValue.first['total_value'] as num?)?.toDouble() ?? 0.0;

    return {
      'total_products': totalProducts,
      'low_stock_products': lowStockProducts,
      'out_of_stock_products': outOfStockProducts,
      'total_inventory_value': totalValueAmount,
    };
  }

  Future<List<Map<String, dynamic>>> getProductsByCategorySummary() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        category,
        COUNT(*) as product_count,
        SUM(stock_quantity) as total_stock,
        SUM(price * stock_quantity) as total_value
      FROM products
      WHERE is_active = 1
      GROUP BY category
      ORDER BY product_count DESC
    ''');
  }
}
