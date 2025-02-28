import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/cidade_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'clima.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE cidade(id INTEGER PRIMARY KEY, nome TEXT)");
      },
    );
  }

  Future<void> salvarCidade(Cidade cidade) async {
    final db = await database;
    await db.insert('cidade', cidade.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Cidade?> recuperarCidade() async {
    final db = await database;
    List<Map<String, dynamic>> resultado = await db.query('cidade');

    if (resultado.isNotEmpty) {
      return Cidade(id: resultado.first['id'], nome: resultado.first['nome']);
    }
    return null;
  }
}
