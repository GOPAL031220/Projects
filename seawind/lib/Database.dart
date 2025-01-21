import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await setDatabase();
    return _database;
  }

  setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'Contacts_Data');
    var database = await openDatabase(path, version: 1, onCreate: _onCreatingDatabase);
    return database;
  }

  _onCreatingDatabase(Database database, int version) async {
    await database.execute('''
    CREATE TABLE Contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firstname TEXT,
      lastname TEXT,
      phone TEXT,
      email TEXT,
      company TEXT,
      street TEXT,
      city TEXT,
      state TEXT,
      zip TEXT,
      dppath TEXT
    )
  ''');
  }


  insertData(table,data) async{
    var connection = await database;
    return await connection?.insert(table, data);
  }

  readData(table) async{
    var connection = await database;
    return await connection?.query(table);
  }

  readDataById(table, contactId) async {
    var connection = await database;
    return await connection?.query(table,where: 'id=?',whereArgs: [contactId]);
  }

  updateData(table, data) async{
    var connection = await database;
    return await connection?.update(table, data, where: 'id=?',whereArgs: [data['id']]);
  }

  deleteData(table,contactId) async{
    var connection = await database;
    return await connection?.delete(table, where: 'id = ?', whereArgs: [contactId]);;
  }
}



