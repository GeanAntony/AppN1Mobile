class Produto {
  int id;
  String nome;
  String unidade; // un, cx, kg, lt, ml
  int quantidadeEstoque;
  double precoVenda;
  int status; 
  double? custo;
  String? codigoBarra;

  Produto({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.quantidadeEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
  });

  Produto.nova()
      : id = 0,
        nome = '',
        unidade = 'un',
        quantidadeEstoque = 0,
        precoVenda = 0.0,
        status = 0,
        custo = 0.0,
        codigoBarra = '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'unidade': unidade,
        'quantidadeEstoque': quantidadeEstoque,
        'precoVenda': precoVenda,
        'status': status,
        'custo': custo,
        'codigoBarra': codigoBarra,
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
      );
}

class ControladoraProduto {
  final List<Produto> lista = [];

  // Exclui um produto da lista
  void excluirProduto(Produto p) {
    lista.remove(p);
  }

  // Salva ou atualiza um produto na lista
  void salvarProduto(Produto p) {
    if (p.nome.isEmpty || p.unidade.isEmpty || p.precoVenda <= 0) {
      throw Exception('Campos obrigatórios (nome, unidade, preço de venda) não preenchidos');
    }
    if (!['un', 'cx', 'kg', 'lt', 'ml'].contains(p.unidade)) {
      throw Exception('Unidade deve ser un, cx, kg, lt ou ml');
    }
    if (p.status != 0 && p.status != 1) {
      throw Exception('Status deve ser 0 (Ativo) ou 1 (Inativo)');
    }
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
