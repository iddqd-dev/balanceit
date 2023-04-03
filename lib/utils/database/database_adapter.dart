import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'balance_it.db');

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {

    await db.execute(
        'CREATE TABLE transactions ('
            'id INTEGER PRIMARY KEY,'
            'type INTEGER(1),' // Тип транзакции (доход (earn) = 1 или расход (spend) = 0)
            'amount REAL,' // Сумма транзакции
            'category TEXT,' // Категория транзакции
            'description TEXT,' // Описание транзакции
            'date TEXT,' // Дата транзакции (хранится в формате ISO 8601)
            'is_owed INTEGER(1),' // Флаг, указывающий на то, является ли транзакция займом
            'is_lent INTEGER(1))' // Флаг, указывающий на то, является ли транзакция долгом
    );

    await db.execute(
        'CREATE TABLE debts ('
            'id INTEGER PRIMARY KEY,'
            'type INTEGER(1),' // Тип долга/займа (занятая = 0 /одолженная = 1 сумма)
            'amount REAL,' // Сумма долга/займа
            'description TEXT,' // Описание долга/займа
            'date TEXT,' // Дата создания долга/займа (хранится в формате ISO 8601)
            'due_date TEXT,' // Дата, когда нужно вернуть долг/займ (хранится в формате ISO 8601)
            'is_lent INTEGER(1),' // Флаг, указывающий на то, является ли долг займом
            'is_borrowed INTEGER(1),' // Флаг, указывающий на то, является ли долг заёмом
            'is_paid INTEGER(1))' // Флаг, указывающий на то, оплачен ли долг/займ
    );

    await db.execute(
        'CREATE TABLE monthly_payments ('
            'id INTEGER PRIMARY KEY,'
            'amount REAL' // Сумма ежемесячного платежа
            'description TEXT,' // Описание ежемесячного платежа
            'due_date TEXT)' // Дата, когда нужно оплатить платеж (хранится в формате ISO 8601)
    );
  }

  Future<int> saveData(String table, Map<String, dynamic> data) async {
    var dbClient = await db;
    return dbClient!.insert(table, data);
  }


  // Implementation
  // int result = await dbHelper.addTransaction('transactions', {
  //                        'type': 0,
  //                        'amount': 500.00,
  //                        'category': 'Магазины',
  //                        'description': 'Тут всякая инфа',
  //                        'date': '2023-04-01T00:00:00+0000',
  //                        'is_owed': 0,
  //                        'is_lent': 0,
  //                        });
  Future<int> addTransaction(Map<String, dynamic> data) async {

    var dbClient = await db;
    return dbClient!.insert('transactions', data);
  }

  Future<List<Map<String, dynamic>>> getData(String table) async {
    var dbClient = await db;
    return dbClient!.query(table, limit: null);
  }

  Future<List<Map<String, dynamic>>> getTransactionData(String id) async {
    var dbClient = await db;
    return dbClient!.query('transactions', limit: null, where: 'id= ?', whereArgs: [id]);
  }

  Future<int> updateData(
      String table, Map<String, dynamic> data, int id) async {
    var dbClient = await db;
    return dbClient!.update(table, data, where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateTransactionData(Map<String, dynamic> data, int id) async {
    var dbClient = await db;
    return dbClient!.update('transactions', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteData(String table, int id) async {
    var dbClient = await db;
    return dbClient!.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}