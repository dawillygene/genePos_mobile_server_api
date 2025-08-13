import 'package:gene_pos/database_helper.dart';
import 'package:gene_pos/models/brand_model.dart';

class BrandService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all brands
  Future<List<Brand>> getBrands() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('brands');
    return List.generate(maps.length, (i) {
      return Brand.fromMap(maps[i]);
    });
  }

  // Get a single brand by ID
  Future<Brand?> getBrand(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'brands',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Brand.fromMap(maps.first);
    }
    return null;
  }

  // Add a new brand
  Future<int> addBrand(Brand brand) async {
    final db = await _dbHelper.database;
    return await db.insert('brands', brand.toMap());
  }

  // Update a brand
  Future<int> updateBrand(Brand brand) async {
    final db = await _dbHelper.database;
    return await db.update(
      'brands',
      brand.toMap(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
  }

  // Delete a brand
  Future<int> deleteBrand(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'brands',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
