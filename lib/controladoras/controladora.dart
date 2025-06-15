import 'package:app_n1/controladoras/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Pessoa {
  int id;
  String nome;
  String? sobrenome;
  String user;
  String senha;
  String? ultimaAlteracao;

  Pessoa({
    required this.id,
    required this.nome,
    this.sobrenome,
    required this.user,
    required this.senha,
    this.ultimaAlteracao,
  });

  get nomeCompleto => (nome + ' ' + (sobrenome ?? ''));

  Pessoa.nova()
    : id = 0,
      nome = '',
      user = '',
      senha = '',
      ultimaAlteracao = null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'sobrenome': sobrenome,
    'user': user,
    'senha': senha,
    'ultimaAlteracao': ultimaAlteracao,
  };

  factory Pessoa.fromJson(Map<String, dynamic> json) => Pessoa(
    id: json['id'],
    nome: json['nome'],
    sobrenome: json['sobrenome'],
    user: json['user'],
    senha: json['senha'],
    ultimaAlteracao: json['ultimaAlteracao'],
  );
}

class Controladora {
  final List<Pessoa> lista = [];

  Future<void> loadPessoas() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    lista.clear();
    lista.addAll(maps.map((p) => Pessoa.fromJson(p)).toList());
  }

  Future<void> excluirPessoa(Pessoa p) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [p.id]);
    lista.remove(p);
  }

  Future<void> salvarPessoa(Pessoa p) async {
    final db = await DatabaseHelper.instance.database;
    if (p.id == 0) {
      p.id = await db.insert('usuarios', p.toJson());
      lista.add(p);
    } else {
      await db.update(
        'usuarios',
        p.toJson(),
        where: 'id = ?',
        whereArgs: [p.id],
      );
      final index = lista.indexWhere((element) => element.id == p.id);
      if (index != -1) {
        lista[index] = p;
      }
    }
  }
}
