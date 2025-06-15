import 'package:app_n1/controladoras/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Cliente {
  int id;
  String nome;
  String tipo; // F (Física) ou J (Jurídica)
  String cpfCnpj;
  String? email;
  String? telefone;
  String? cep;
  String? endereco;
  String? bairro;
  String? cidade;
  String? uf;
  String? ultimaAlteracao;

  Cliente({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
    this.ultimaAlteracao,
  });

  Cliente.novo()
    : id = 0,
      nome = '',
      tipo = 'F',
      cpfCnpj = '',
      email = '',
      telefone = '',
      cep = '',
      endereco = '',
      bairro = '',
      cidade = '',
      uf = '',
      ultimaAlteracao = null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'cpfCnpj': cpfCnpj,
    'email': email,
    'telefone': telefone,
    'cep': cep,
    'endereco': endereco,
    'bairro': bairro,
    'cidade': cidade,
    'uf': uf,
    'ultimaAlteracao': ultimaAlteracao,
  };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'],
    nome: json['nome'],
    tipo: json['tipo'],
    cpfCnpj: json['cpfCnpj'],
    email: json['email'],
    telefone: json['telefone'],
    cep: json['cep'],
    endereco: json['endereco'],
    bairro: json['bairro'],
    cidade: json['cidade'],
    uf: json['uf'],
    ultimaAlteracao: json['ultimaAlteracao'],
  );
}

class ControladoraCliente {
  final List<Cliente> lista = [];

  Future<void> loadClientes() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    lista.clear();
    lista.addAll(maps.map((c) => Cliente.fromJson(c)).toList());
  }

  Future<void> excluirCliente(Cliente c) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('clientes', where: 'id = ?', whereArgs: [c.id]);
    lista.remove(c);
  }

  Future<void> salvarCliente(Cliente c) async {
    if (c.nome.isEmpty || c.tipo.isEmpty || c.cpfCnpj.isEmpty) {
      throw Exception(
        'Campos obrigatórios (nome, tipo, CPF/CNPJ) não preenchidos',
      );
    }
    if (!['F', 'J'].contains(c.tipo)) {
      throw Exception('Tipo deve ser F (Física) ou J (Jurídica)');
    }
    final db = await DatabaseHelper.instance.database;
    if (c.id == 0) {
      c.id = await db.insert('clientes', c.toJson());
      lista.add(c);
    } else {
      await db.update(
        'clientes',
        c.toJson(),
        where: 'id = ?',
        whereArgs: [c.id],
      );
      final index = lista.indexWhere((element) => element.id == c.id);
      if (index != -1) {
        lista[index] = c;
      }
    }
  }
}
