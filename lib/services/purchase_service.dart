import '../database_helper.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertPurchase(Purchase purchase) async {
    final db = await _dbHelper.database;
    return await db.insert('purchases', purchase.toMap());
  }

  Future<List<Purchase>> getPurchases() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('purchases');
    return List.generate(maps.length, (i) {
      return Purchase.fromMap(maps[i]);
    });
  }

  Future<int> updatePurchase(Purchase purchase) async {
    final db = await _dbHelper.database;
    return await db.update('purchases', purchase.toMap(),
        where: 'id = ?', whereArgs: [purchase.id]);
  }

  Future<int> deletePurchase(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('purchases', where: 'id = ?', whereArgs: [id]);
  }
}
