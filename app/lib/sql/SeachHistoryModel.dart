import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern to avoid multiple instances of the database
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

  // Open the database, or create it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;

    // If database is not initialized, create it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'example.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create a table with List<String> as a column
        await db.execute('''
          CREATE TABLE MyTable (
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
      },
    );
  }

  // Insert a record with List<String> as data (stringified)
  Future<void> insertRecord(List<String>? dataList) async {
    final db = await database;
    String data = dataList != null ? dataList.join(',') : '';
    await db.insert('MyTable', {
      'data': data,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch all records
  Future<List<Map<String, dynamic>>> fetchAllRecords() async {
    final db = await database;
    return await db.query('MyTable');
  }

  // Convert String to List<String>
  List<String> _stringToList(String? data) {
    if (data == null) return [];
    return data.split(',');
  }

  // Fetch records with List<String> data
  Future<List<String>> fetchRecordsWithList() async {
    final db = await database;
    final result = await db.query('MyTable');
    return result
        .map((row) {
          return _stringToList(row['data'] as String?);
        })
        .toList()
        .expand((i) => i)
        .toList(); // Flatten the list
  }
}

// List<String> records = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   // Load data from the database
//   void _loadData() async {
//     List<String> recordsFromDb = await DatabaseHelper.instance.fetchRecordsWithList();
//     setState(() {
//       records = recordsFromDb;
//     });
//   }
//
//   // Insert data into the database
//   void _insertData() async {
//     List<String> data = ['item1', 'item2', 'item3'];
//     await DatabaseHelper.instance.insertRecord(data);
//     _loadData(); // Refresh data after insertion
//   }
