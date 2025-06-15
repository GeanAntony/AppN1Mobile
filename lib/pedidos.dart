import 'package:app_n1/controladoras/controladora.dart';
import 'package:app_n1/controladoras/controladoraCliente.dart';
import 'package:app_n1/controladoras/controladoraPedido.dart';
import 'package:app_n1/controladoras/controladoraProduto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CadastroPedido extends StatefulWidget {
  const CadastroPedido({super.key});

  @override
  State<CadastroPedido> createState() => _CadastroPedidoState();
}

class _CadastroPedidoState extends State<CadastroPedido> {
  final _controladora = ControladoraPedido();
  List<Pedido> pedidos = [];

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    pedidos = await _controladora.loadPedidos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Pedidos")),
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
                          (context) =>
                              FormularioPedido(controladora: _controladora),
                    ),
                  );
                  await _loadPedidos();
                },
                child: const Text("Criar novo pedido"),
              ),
            ),
            Expanded(
              child:
                  pedidos.isEmpty
                      ? const Center(child: Text("Nenhum pedido cadastrado"))
                      : ListView.builder(
                        itemCount: pedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidos[index];
                          return ListTile(
                            title: Text('Pedido #${pedido.id}'),
                            subtitle: Text(
                              'Total: R\$${pedido.totalPedido.toStringAsFixed(2)}',
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FormularioPedido(
                                        controladora: _controladora,
                                        pedido: pedido,
                                      ),
                                ),
                              );
                              await _loadPedidos();
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

class FormularioPedido extends StatefulWidget {
  final ControladoraPedido controladora;
  final Pedido? pedido;

  const FormularioPedido({super.key, required this.controladora, this.pedido});

  @override
  State<FormularioPedido> createState() => _FormularioPedidoState();
}

class _FormularioPedidoState extends State<FormularioPedido> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladoraCliente = ControladoraCliente();
  final _controladoraUsuario = Controladora();
  final _controladoraProduto = ControladoraProduto();
  List<Cliente> clientes = [];
  List<Pessoa> usuarios = [];
  List<Produto> produtos = [];
  Cliente? _clienteSelecionado;
  Pessoa? _usuarioSelecionado;
  Produto? _produtoSelecionado;
  List<PedidoItem> _itens = [];
  List<PedidoPagamento> _pagamentos = [];
  final _controladorQuantidade = TextEditingController();
  final _controladorValorPagamento = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDados();
    if (widget.pedido != null) {
      _itens = List.from(widget.pedido!.itens);
      _pagamentos = List.from(widget.pedido!.pagamentos);
    }
  }

  Future<void> _loadDados() async {
    await _controladoraCliente.loadClientes();
    await _controladoraUsuario.loadPessoas();
    await _controladoraProduto.loadProdutos();
    setState(() {
      clientes = _controladoraCliente.lista;
      usuarios = _controladoraUsuario.lista;
      produtos = _controladoraProduto.lista;
      if (widget.pedido != null && clientes.isNotEmpty && usuarios.isNotEmpty) {
        _clienteSelecionado = clientes.firstWhere(
          (c) => c.id == widget.pedido!.idCliente,
          orElse: () => clientes.first,
        );
        _usuarioSelecionado = usuarios.firstWhere(
          (u) => u.id == widget.pedido!.idUsuario,
          orElse: () => usuarios.first,
        );
      }
    });
  }

  void _adicionarItem(Produto produto, double quantidade) {
    final totalItem = quantidade * produto.precoVenda;
    setState(() {
      _itens.add(
        PedidoItem(
          id: 0,
          idPedido: 0,
          idProduto: produto.id,
          quantidade: quantidade,
          totalItem: totalItem,
        ),
      );
    });
  }

  void _adicionarPagamento(double valor) {
    setState(() {
      _pagamentos.add(PedidoPagamento(id: 0, idPedido: 0, valor: valor));
    });
  }

  double get _totalItens =>
      _itens.fold(0.0, (sum, item) => sum + item.totalItem);
  double get _totalPagamentos =>
      _pagamentos.fold(0.0, (sum, pagamento) => sum + pagamento.valor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pedido == null
              ? 'Novo Pedido'
              : 'Editar Pedido #${widget.pedido!.id}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _chaveFormulario,
          child: ListView(
            children: [
              DropdownButtonFormField<Cliente>(
                value: _clienteSelecionado,
                decoration: const InputDecoration(labelText: 'Cliente *'),
                items:
                    clientes.isEmpty
                        ? []
                        : clientes
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.nome),
                              ),
                            )
                            .toList(),
                onChanged:
                    (value) => setState(() => _clienteSelecionado = value),
                validator:
                    (value) => value == null ? 'Selecione um cliente' : null,
              ),
              DropdownButtonFormField<Pessoa>(
                value: _usuarioSelecionado,
                decoration: const InputDecoration(labelText: 'Usuário *'),
                items:
                    usuarios.isEmpty
                        ? []
                        : usuarios
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u.nomeCompleto),
                              ),
                            )
                            .toList(),
                onChanged:
                    (value) => setState(() => _usuarioSelecionado = value),
                validator:
                    (value) => value == null ? 'Selecione um usuário' : null,
              ),
              const SizedBox(height: 16),
              Text('Itens', style: Theme.of(context).textTheme.titleMedium),
              ..._itens.asMap().entries.map((entry) {
                final item = entry.value;
                final produto = produtos.firstWhere(
                  (p) => p.id == item.idProduto,
                  orElse:
                      () => Produto(
                        id: 0,
                        nome: 'Produto não encontrado',
                        unidade: 'un',
                        quantidadeEstoque: 0,
                        precoVenda: 0.0,
                        status: 0,
                      ),
                );
                return ListTile(
                  title: Text(produto.nome),
                  subtitle: Text(
                    'Qtd: ${item.quantidade} - Total: R\$${item.totalItem.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _itens.removeAt(entry.key)),
                  ),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Produto>(
                      value: _produtoSelecionado,
                      decoration: const InputDecoration(labelText: 'Produto'),
                      items:
                          produtos.isEmpty
                              ? []
                              : produtos
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p.nome),
                                    ),
                                  )
                                  .toList(),
                      onChanged:
                          (value) =>
                              setState(() => _produtoSelecionado = value),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _controladorQuantidade,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a quantidade';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Quantidade deve ser maior que zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (_chaveFormulario.currentState!.validate() &&
                          _produtoSelecionado != null) {
                        _adicionarItem(
                          _produtoSelecionado!,
                          double.parse(_controladorQuantidade.text),
                        );
                        _controladorQuantidade.clear();
                        setState(() => _produtoSelecionado = null);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pagamentos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._pagamentos.asMap().entries.map((entry) {
                final pagamento = entry.value;
                return ListTile(
                  title: Text('R\$${pagamento.valor.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed:
                        () => setState(() => _pagamentos.removeAt(entry.key)),
                  ),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controladorValorPagamento,
                      decoration: const InputDecoration(
                        labelText: 'Valor Pagamento',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Valor deve ser maior que zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (_controladorValorPagamento.text.isNotEmpty &&
                          double.tryParse(_controladorValorPagamento.text) !=
                              null) {
                        _adicionarPagamento(
                          double.parse(_controladorValorPagamento.text),
                        );
                        _controladorValorPagamento.clear();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Total Itens: R\$${_totalItens.toStringAsFixed(2)}'),
              Text(
                'Total Pagamentos: R\$${_totalPagamentos.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.pedido != null)
                    ElevatedButton(
                      onPressed: () {
                        widget.controladora.excluirPedido(widget.pedido!);
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
                        if (_itens.isEmpty || _pagamentos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Adicione pelo menos 1 item e 1 pagamento',
                              ),
                            ),
                          );
                          return;
                        }
                        if (_totalItens != _totalPagamentos) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Total dos itens deve ser igual ao total dos pagamentos',
                              ),
                            ),
                          );
                          return;
                        }
                        final pedido = Pedido(
                          id: widget.pedido?.id ?? 0,
                          idCliente: _clienteSelecionado!.id,
                          idUsuario: _usuarioSelecionado!.id,
                          totalPedido: _totalItens,
                          dataCriacao: DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(DateTime.now()),
                          itens: _itens,
                          pagamentos: _pagamentos,
                        );
                        widget.controladora.salvarPedido(pedido);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Salvar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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

  @override
  void dispose() {
    _controladorQuantidade.dispose();
    _controladorValorPagamento.dispose();
    super.dispose();
  }
}
