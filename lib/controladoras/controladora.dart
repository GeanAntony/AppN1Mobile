class Pessoa {
  int id;
  String nome;
  String? sobrenome;
  String user;
  String senha;

  Pessoa({
    required this.id,
    required this.nome,
    this.sobrenome,
    required this.user,
    required this.senha,
  });

  get nomeCompleto => (nome + ' ' + (sobrenome ?? ''));

  Pessoa.nova() : id = 0, nome = '', user = '', senha = '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'sobrenome': sobrenome,
        'user': user,
        'senha': senha,
      };

  factory Pessoa.fromJson(Map<String, dynamic> json) => Pessoa(
        id: json['id'],
        nome: json['nome'],
        sobrenome: json['sobrenome'],
        user: json['user'],
        senha: json['senha'],
      );
}

class Controladora {
  final List<Pessoa> lista = [];

  // Exclui uma pessoa da lista
  void excluirPessoa(Pessoa p) {
    lista.remove(p);
  }

  // Salva ou atualiza uma pessoa na lista
  void salvarPessoa(Pessoa p) {
    if (p.id == 0) {
      p.id = lista.isEmpty ? 1 : lista.reduce((a, b) => a.id > b.id ? a : b).id + 1;
      lista.add(p);
    } else {
      final index = lista.indexWhere((element) => element.id == p.id);
      if (index != -1) {
        lista[index] = p;
      }
    }
  }
}