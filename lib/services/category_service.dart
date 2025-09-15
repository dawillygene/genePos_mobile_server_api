import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import 'database_helper.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // CRUD Operations
  Future<int> createCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'is_active': category.isActive ? 1 : 0,
      'shop_id': category.shopId,
      'created_at': category.createdAt.toIso8601String(),
      'updated_at': category.updatedAt.toIso8601String(),
    });
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Category.fromJson(maps.first);
    }
    return null;
  }

  Future<Category?> getCategoryByName(String name) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Category.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Category>> getAllCategories({bool activeOnly = true}) async {
    final db = await _dbHelper.database;
    String whereClause = activeOnly ? 'is_active = 1' : '';
    final maps = await db.query(
      'categories',
      where: whereClause,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Category.fromJson(map)).toList();
  }

  Future<List<Category>> searchCategories(
    String query, {
    bool activeOnly = true,
  }) async {
    final db = await _dbHelper.database;
    String whereClause = '(name LIKE ? OR description LIKE ?)';
    List<dynamic> whereArgs = ['%$query%', '%$query%'];

    if (activeOnly) {
      whereClause += ' AND is_active = 1';
    }

    final maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Category.fromJson(map)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      {
        'name': category.name,
        'description': category.description,
        'is_active': category.isActive ? 1 : 0,
        'shop_id': category.shopId,
        'updated_at': category.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deactivateCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Validation
  Future<bool> isCategoryNameUnique(String name, {int? excludeId}) async {
    final db = await _dbHelper.database;
    String whereClause = 'name = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM categories WHERE $whereClause',
            whereArgs,
          ),
        ) ??
        0;

    return count == 0;
  }

  // Statistics
  Future<Map<String, dynamic>> getCategoryStatistics() async {
    final db = await _dbHelper.database;

    final totalCategories =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM categories WHERE is_active = 1',
          ),
        ) ??
        0;

    final categoryProductCounts = await db.rawQuery('''
      SELECT
        c.name as category_name,
        COUNT(p.id) as product_count
      FROM categories c
      LEFT JOIN products p ON c.name = p.category AND p.is_active = 1
      WHERE c.is_active = 1
      GROUP BY c.id, c.name
      ORDER BY product_count DESC
    ''');

    return {
      'total_categories': totalCategories,
      'category_product_counts': categoryProductCounts,
    };
  }

  Future<List<Map<String, dynamic>>> getCategoriesWithProductCount() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT
        c.id,
        c.name,
        c.description,
        c.is_active,
        c.created_at,
        c.updated_at,
        COUNT(p.id) as product_count,
        COALESCE(SUM(p.stock_quantity), 0) as total_stock,
        COALESCE(SUM(p.price * p.stock_quantity), 0) as total_value
      FROM categories c
      LEFT JOIN products p ON c.name = p.category AND p.is_active = 1
      WHERE c.is_active = 1
      GROUP BY c.id, c.name, c.description, c.is_active, c.created_at, c.updated_at
      ORDER BY c.name ASC
    ''');
  }
}
