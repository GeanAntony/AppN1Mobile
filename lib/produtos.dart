// produtos.dart
import 'package:app_n1/controladoras/controladoraProduto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CadastroProduto extends StatefulWidget {
  const CadastroProduto({super.key});

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  final _controladora = ControladoraProduto();

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  Future<void> _loadProdutos() async {
    await _controladora.loadProdutos();
    setState(() {});
  }

  /*Future<void> _saveProdutos() async {
    final prefs = await SharedPreferences.getInstance();
    final String produtosJson = jsonEncode(_controladora.lista.map((p) => p.toJson()).toList());
    await prefs.setString('produtos', produtosJson);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Produtos")),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'INICIAL');
                },
                child: const Text("Voltar para navegação"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FormularioProduto(
                            controladora: _controladora,
                            produto: Produto.nova(),
                          ),
                    ),
                  );
                  setState(() {});
                },
                child: const Text("Criar novo produto"),
              ),
            ),
            Expanded(
              child:
                  _controladora.lista.isEmpty
                      ? const Center(child: Text("Nenhum produto cadastrado"))
                      : ListView.builder(
                        itemCount: _controladora.lista.length,
                        itemBuilder: (context, index) {
                          final produto = _controladora.lista[index];
                          return ListTile(
                            title: Text('${produto.nome} (${produto.unidade})'),
                            subtitle: Text(
                              'Preço: R\$${produto.precoVenda.toStringAsFixed(2)} - Estoque: ${produto.quantidadeEstoque}',
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FormularioProduto(
                                        controladora: _controladora,
                                        produto: Produto.nova(),
                                      ),
                                ),
                              );
                              setState(() {});
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormularioProduto extends StatefulWidget {
  final ControladoraProduto controladora;
  final Produto produto;

  const FormularioProduto({
    super.key,
    required this.controladora,
    required this.produto,
  });

  @override
  State<FormularioProduto> createState() => _FormularioProdutoState();
}

class _FormularioProdutoState extends State<FormularioProduto> {
  final _chaveFormulario = GlobalKey<FormState>();
  late TextEditingController _controladorNome;
  late TextEditingController _controladorUnidade;
  late TextEditingController _controladorQuantidadeEstoque;
  late TextEditingController _controladorPrecoVenda;
  late TextEditingController _controladorStatus;
  late TextEditingController _controladorCusto;
  late TextEditingController _controladorCodigoBarra;

  @override
  void initState() {
    super.initState();
    _controladorNome = TextEditingController(text: widget.produto.nome);
    _controladorUnidade = TextEditingController(text: widget.produto.unidade);
    _controladorQuantidadeEstoque = TextEditingController(
      text: widget.produto.quantidadeEstoque.toString(),
    );
    _controladorPrecoVenda = TextEditingController(
      text: widget.produto.precoVenda.toString(),
    );
    _controladorStatus = TextEditingController(
      text: widget.produto.status.toString(),
    );
    _controladorCusto = TextEditingController(
      text: widget.produto.custo?.toString() ?? '',
    );
    _controladorCodigoBarra = TextEditingController(
      text: widget.produto.codigoBarra ?? '',
    );
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorUnidade.dispose();
    _controladorQuantidadeEstoque.dispose();
    _controladorPrecoVenda.dispose();
    _controladorStatus.dispose();
    _controladorCusto.dispose();
    _controladorCodigoBarra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de ${widget.produto.nome.isEmpty ? 'Novo Produto' : widget.produto.nome}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _chaveFormulario,
          child: ListView(
            children: [
              TextFormField(
                controller: _controladorNome,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorUnidade,
                decoration: const InputDecoration(
                  labelText: 'Unidade (un, cx, kg, lt, ml) *',
                ),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe a unidade';
                  }
                  if (!['un', 'cx', 'kg', 'lt', 'ml'].contains(valor)) {
                    return 'Unidade deve ser un, cx, kg, lt ou ml';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorQuantidadeEstoque,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em Estoque *',
                ),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe a quantidade';
                  }
                  if (int.tryParse(valor) == null || int.parse(valor) < 0) {
                    return 'Quantidade deve ser um número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorPrecoVenda,
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda *',
                ),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe o preço de venda';
                  }
                  if (double.tryParse(valor) == null ||
                      double.parse(valor) <= 0) {
                    return 'Preço deve ser maior que zero';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorStatus,
                decoration: const InputDecoration(
                  labelText: 'Status (0-Ativo, 1-Inativo) *',
                ),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe o status';
                  }
                  if (int.tryParse(valor) == null ||
                      ![0, 1].contains(int.parse(valor))) {
                    return 'Status deve ser 0 (Ativo) ou 1 (Inativo)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorCusto,
                decoration: const InputDecoration(labelText: 'Custo'),
                keyboardType: TextInputType.number,
                validator: (valor) {
                  if (valor != null &&
                      valor.isNotEmpty &&
                      double.tryParse(valor) == null) {
                    return 'Custo deve ser um número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorCodigoBarra,
                decoration: const InputDecoration(labelText: 'Código de Barra'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.produto.id != 0)
                    ElevatedButton(
                      onPressed: () {
                        widget.controladora.excluirProduto(widget.produto);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Excluir'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_chaveFormulario.currentState!.validate()) {
                        final produtoAtualizado = Produto(
                          id: widget.produto.id,
                          nome: _controladorNome.text,
                          unidade: _controladorUnidade.text,
                          quantidadeEstoque: int.parse(
                            _controladorQuantidadeEstoque.text,
                          ),
                          precoVenda: double.parse(_controladorPrecoVenda.text),
                          status: int.parse(_controladorStatus.text),
                          custo:
                              _controladorCusto.text.isEmpty
                                  ? null
                                  : double.parse(_controladorCusto.text),
                          codigoBarra:
                              _controladorCodigoBarra.text.isEmpty
                                  ? null
                                  : _controladorCodigoBarra.text,
                        );
                        widget.controladora.salvarProduto(produtoAtualizado);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Salvar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
