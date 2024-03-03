import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = 'databaseMobile.db';
  static const _databaseVersion = 1;

  static const table = 'my_local';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnUrl = 'link';

  late Database _db;

  Future<void> init() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, _databaseName);

    _db = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnUrl TEXT NOT NULL
      )
    ''');
  }

  // Add a method to close the database
  Future<void> close() async {
    await _db.close();
  }

  // Add methods to perform database operations (insert, query, update, delete) based on your requirements
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    return await _db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    return await _db
        .update(table, row, where: '$columnId = ?', whereArgs: [row[columnId]]);
  }

  Future<int> delete(int id) async {
    return await _db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> findOne(int id) async {
    List<Map<String, dynamic>> result = await _db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty ? result.first : null;
  }
}
