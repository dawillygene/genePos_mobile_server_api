import '../database_helper.dart';
import '../models/currency_model.dart';

class CurrencyService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertCurrency(Currency currency) async {
    final db = await _dbHelper.database;
    return await db.insert('currencies', currency.toMap());
  }

  Future<List<Currency>> getCurrencies() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('currencies');
    return List.generate(maps.length, (i) {
      return Currency.fromMap(maps[i]);
    });
  }

  Future<int> updateCurrency(Currency currency) async {
    final db = await _dbHelper.database;
    return await db.update('currencies', currency.toMap(),
        where: 'id = ?', whereArgs: [currency.id]);
  }

  Future<int> deleteCurrency(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('currencies', where: 'id = ?', whereArgs: [id]);
  }
}
