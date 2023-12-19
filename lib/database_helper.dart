import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cities.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE searched_cities (
  id $idType,
  city_name $textType
)
''');
  }

  Future<int> addCity(String cityName) async {
    final db = await instance.database;
    final json = {'city_name': cityName};
    final id = await db.insert('searched_cities', json);
    return id;
  }

  Future<List<String>> getCities() async {
    final db = await instance.database;
    const orderBy = 'city_name ASC';
    final result = await db.query('searched_cities', orderBy: orderBy);

    return result.map((json) => json['city_name'] as String).toList();
  }

  // Method to delete a city from the database
  Future<void> deleteCity(String cityName) async {
    final db = await instance.database;
    await db.delete(
      'searched_cities', // The table name
      where: 'city_name = ?', // The where clause to find the right city
      whereArgs: [cityName], // The city name argument for the where clause
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
