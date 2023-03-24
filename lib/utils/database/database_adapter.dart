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
            'type BOOLEAN,' // Тип транзакции (доход = 1 или расход = 0)
            'amount REAL,' // Сумма транзакции
            'category TEXT,' // Категория транзакции
            'description TEXT,' // Описание транзакции
            'date TEXT,' // Дата транзакции (хранится в формате ISO 8601)
            'is_owed BOOLEAN,' // Флаг, указывающий на то, является ли транзакция займом
            'is_lent BOOLEAN)' // Флаг, указывающий на то, является ли транзакция долгом
    );

    await db.execute(
        'CREATE TABLE debts ('
            'id INTEGER PRIMARY KEY,'
            'type BOOLEAN,' // Тип долга/займа (занятая/одолженная сумма)
            'amount REAL,' // Сумма долга/займа
            'description TEXT,' // Описание долга/займа
            'date TEXT,' // Дата создания долга/займа (хранится в формате ISO 8601)
            'due_date TEXT,' // Дата, когда нужно вернуть долг/займ (хранится в формате ISO 8601)
            'is_lent BOOLEAN,' // Флаг, указывающий на то, является ли долг займом
            'is_borrowed BOOLEAN,' // Флаг, указывающий на то, является ли долг заёмом
            'is_paid BOOLEAN)' // Флаг, указывающий на то, оплачен ли долг/займ
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

  Future<List<Map<String, dynamic>>> getData(String table) async {
    var dbClient = await db;
    return dbClient!.query(table);
  }

  Future<int> updateData(
      String table, Map<String, dynamic> data, int id) async {
    var dbClient = await db;
    return dbClient!.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteData(String table, int id) async {
    var dbClient = await db;
    return dbClient!.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}