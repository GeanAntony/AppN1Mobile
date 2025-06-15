import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vendas.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        sobrenome TEXT,
        user TEXT NOT NULL,
        senha TEXT NOT NULL,
        ultimaAlteracao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        cpfCnpj TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        cep TEXT,
        endereco TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        ultimaAlteracao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        unidade TEXT NOT NULL,
        quantidadeEstoque INTEGER NOT NULL,
        precoVenda REAL NOT NULL,
        status INTEGER NOT NULL,
        custo REAL,
        codigoBarra TEXT,
        ultimaAlteracao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY,
        idCliente INTEGER NOT NULL,
        idUsuario INTEGER NOT NULL,
        totalPedido REAL NOT NULL,
        dataCriacao TEXT NOT NULL,
        ultimaAlteracao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pedido_itens (
        id INTEGER PRIMARY KEY,
        idPedido INTEGER NOT NULL,
        idProduto INTEGER NOT NULL,
        quantidade REAL NOT NULL,
        totalItem REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pedido_pagamentos (
        id INTEGER PRIMARY KEY,
        idPedido INTEGER NOT NULL,
        valor REAL NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar lógica para atualizações futuras do banco
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
