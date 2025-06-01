import 'package:cadastrocombanco/model/produto.model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductDatabase {
  static final ProductDatabase _instance = ProductDatabase._internal();
  factory ProductDatabase() => _instance;
  ProductDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'produtos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    preco_compra REAL NOT NULL,
    preco_venda REAL NOT NULL,
    categoria TEXT NOT NULL,
    quantidade INTEGER NOT NULL,
    imagem TEXT,
    ativo INTEGER NOT NULL DEFAULT 1,
    em_promocao INTEGER NOT NULL DEFAULT 0,
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    desconto REAL NOT NULL DEFAULT 0.0
  )
''');
      },
    );
  }

  Future<int> insertProduct(ProdutoModel productModel) async {
    final db = await database;
    final map = productModel.toMap();
    return await db.insert('produtos', map);
  }

  Future<List<ProdutoModel>> findAllProducts() async {
    final db = await database;
    await Future.delayed(const Duration(seconds: 1));
    List<Map<String, Object?>> listMap = await db.query('produtos');
    return listMap.map((m) => ProdutoModel.fromMap(m)).toList();
  }

  Future<int> updateProduct(int id, ProdutoModel productModel) async {
    final db = await database;

    return await db.update(
      'produtos',
      productModel.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;

    return await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}
