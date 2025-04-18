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
        uf = '';

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
      );
}

class ControladoraCliente {
  final List<Cliente> lista = [];

  void excluirCliente(Cliente c) {
    lista.remove(c);
  }

  void salvarCliente(Cliente c) {
    if (c.nome.isEmpty || c.tipo.isEmpty || c.cpfCnpj.isEmpty) {
      throw Exception('Campos obrigatórios (nome, tipo, CPF/CNPJ) não preenchidos');
    }
    if (!['F', 'J'].contains(c.tipo)) {
      throw Exception('Tipo deve ser F (Física) ou J (Jurídica)');
    }
    if (c.id == 0) {
      c.id = lista.isEmpty ? 1 : lista.reduce((a, b) => a.id > b.id ? a : b).id + 1;
      lista.add(c);
    } else {
      final index = lista.indexWhere((element) => element.id == c.id);
      if (index != -1) {
        lista[index] = c;
      }
    }
  }
}