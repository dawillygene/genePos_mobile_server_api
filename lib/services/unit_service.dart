import 'package:gene_pos/database_helper.dart';
import 'package:gene_pos/models/unit_model.dart';

class UnitService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all units
  Future<List<Unit>> getUnits() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('units');
    return List.generate(maps.length, (i) {
      return Unit.fromMap(maps[i]);
    });
  }

  // Get a single unit by ID
  Future<Unit?> getUnit(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Unit.fromMap(maps.first);
    }
    return null;
  }

  // Add a new unit
  Future<int> addUnit(Unit unit) async {
    final db = await _dbHelper.database;
    return await db.insert('units', unit.toMap());
  }

  // Update a unit
  Future<int> updateUnit(Unit unit) async {
    final db = await _dbHelper.database;
    return await db.update(
      'units',
      unit.toMap(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
  }

  // Delete a unit
  Future<int> deleteUnit(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'units',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
