import 'package:app_n1/controladoras/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Produto {
  int id;
  String nome;
  String unidade; // un, cx, kg, lt, ml
  int quantidadeEstoque;
  double precoVenda;
  int status;
  double? custo;
  String? codigoBarra;
  String? ultimaAlteracao;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
    this.ultimaAlteracao,
  });

  Produto.nova()
    : id = 0,
      nome = '',
      unidade = 'un',
      quantidadeEstoque = 0,
      precoVenda = 0.0,
      status = 0,
      custo = 0.0,
      codigoBarra = '',
      ultimaAlteracao = null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'unidade': unidade,
    'quantidadeEstoque': quantidadeEstoque,
    'precoVenda': precoVenda,
    'status': status,
    'custo': custo,
    'codigoBarra': codigoBarra,
    'ultimaAlteracao': ultimaAlteracao,
  };

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
    id: json['id'],
    nome: json['nome'],
    unidade: json['unidade'],
    quantidadeEstoque: json['quantidadeEstoque'],
    precoVenda: json['precoVenda'],
    status: json['status'],
    custo: json['custo'],
    codigoBarra: json['codigoBarra'],
    ultimaAlteracao: json['ultimaAlteracao'],
  );
}

class ControladoraProduto {
  final List<Produto> lista = [];

  Future<void> loadProdutos() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    lista.clear();
    lista.addAll(maps.map((p) => Produto.fromJson(p)).toList());
  }

  Future<void> excluirProduto(Produto p) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('produtos', where: 'id = ?', whereArgs: [p.id]);
    lista.remove(p);
  }

  Future<void> salvarProduto(Produto p) async {
    if (p.nome.isEmpty || p.unidade.isEmpty || p.precoVenda <= 0) {
      throw Exception(
        'Campos obrigatórios (nome, unidade, preço de venda) não preenchidos',
      );
    }
    if (!['un', 'cx', 'kg', 'lt', 'ml'].contains(p.unidade)) {
      throw Exception('Unidade deve ser un, cx, kg, lt ou ml');
    }
    if (p.status != 0 && p.status != 1) {
      throw Exception('Status deve ser 0 (Ativo) ou 1 (Inativo)');
    }
    final db = await DatabaseHelper.instance.database;
    if (p.id == 0) {
      p.id = await db.insert('produtos', p.toJson());
      lista.add(p);
    } else {
      await db.update(
        'produtos',
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
