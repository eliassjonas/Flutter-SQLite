import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String tabela = 'contatos';
final String colunaId = 'id';
final String colunaNome = 'nome';
final String colunaEmail = 'email';
final String colunaTelefone = 'telefone';
final String colunaCaminhoImagem = 'caminhoImagem';

class Contato {
  int id;
  String nome;
  String email;
  String telefone;
  String caminhoImagem;

  Contato({this.nome, this.email, this.telefone, this.caminhoImagem});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      colunaNome: nome,
      colunaEmail: email,
      colunaTelefone: telefone,
      colunaCaminhoImagem: caminhoImagem
    };

    if (id != null) {
      map[colunaId] = id;
    }
    return map;
  }

  Contato.fromMap(Map<String, dynamic> map) {
    id = map[colunaId];
    nome = map[colunaNome];
    email = map[colunaEmail];
    telefone = map[colunaTelefone];
    caminhoImagem = map[colunaCaminhoImagem];
  }
}

class SQLiteOpenHelper {
  static final SQLiteOpenHelper _instance = SQLiteOpenHelper.internal();
  factory SQLiteOpenHelper() => _instance;

  SQLiteOpenHelper.internal();

  Database _dataBase;

  Future<Database> get dataBase async {
    if (_dataBase != null) {
      return _dataBase;
    } else {
      return _dataBase = await inicializarBanco();
    }
  }

  Future<Database> inicializarBanco() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contatos.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
      db.execute(''' 
            CREATE TABLE IF NOT EXISTS $tabela(
              $colunaId INTEGER PRIMARY KEY,
              $colunaNome TEXT NOT NULL,
              $colunaEmail TEXT NOT NULL,
              $colunaTelefone TEXT,
              $colunaCaminhoImagem TEXT
            );
          ''');
    });
  }

  Future<Contato> insert(Contato contato) async {
    Database db = await dataBase;
    contato.id = await db.insert(tabela, contato.toMap());
    return contato;
  }

  Future<Contato> findById(int id) async {
    Database db = await dataBase;
    List<Map<String, dynamic>> map = await db.query(tabela,
        distinct: true,
        columns: [
          colunaId,
          colunaNome,
          colunaEmail,
          colunaTelefone,
          colunaCaminhoImagem
        ],
        where: '$colunaId = ?',
        whereArgs: [id]);

    return map.length > 0 ? Contato.fromMap(map.first) : Map();
  }

  Future<List<Contato>> findAll() async {
    Database db = await dataBase;

    List<Map> mapContatos = await db.rawQuery('SELECT * FROM $tabela;');

    List<Contato> contatos = List();

    mapContatos.forEach((element) {
      contatos.add(Contato.fromMap(element));
    });
    return contatos;
  }

  Future<int> delete(int id) async {
    Database db = await dataBase;
    return await db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Contato contato) async {
    Database db = await dataBase;
    return await db.update(tabela, contato.toMap(),
        where: '$colunaId = ?', whereArgs: [contato.id]);
  }

  Future<int> getCount() async {
    Database db = dataBase as Database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tabela'));
  }

  Future close() {
    Database db = dataBase as Database;
    return db.close();
  }
}
