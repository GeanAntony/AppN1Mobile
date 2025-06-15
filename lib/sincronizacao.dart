import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_n1/controladoras/controladora.dart';
import 'package:app_n1/controladoras/controladoraCliente.dart';
import 'package:app_n1/controladoras/controladoraProduto.dart';
import 'package:app_n1/controladoras/controladoraPedido.dart';

class TelaSincronizacao extends StatefulWidget {
  const TelaSincronizacao({super.key});

  @override
  State<TelaSincronizacao> createState() => _TelaSincronizacaoState();
}

class _TelaSincronizacaoState extends State<TelaSincronizacao> {
  final _controladoraUsuario = Controladora();
  final _controladoraCliente = ControladoraCliente();
  final _controladoraProduto = ControladoraProduto();
  final _controladoraPedido = ControladoraPedido();
  List<String> erros = [];
  String serverUrl = 'http://localhost:8080';

  Future<void> _sincronizar() async {
    erros.clear();
    await _sincronizarUsuarios();
    await _sincronizarClientes();
    await _sincronizarProdutos();
    await _sincronizarPedidos();
    setState(() {});
  }

  Future<void> _sincronizarUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/usuarios'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['dados'];
        for (var usuarioJson in data) {
          final usuario = Pessoa.fromJson(usuarioJson);
          if (usuario.ultimaAlteracao != null) {
            final localUsuario = _controladoraUsuario.lista.firstWhere(
              (u) => u.id == usuario.id,
              orElse: () => Pessoa.nova(),
            );
            if (localUsuario.ultimaAlteracao == null ||
                DateTime.parse(
                  usuario.ultimaAlteracao!,
                ).isAfter(DateTime.parse(localUsuario.ultimaAlteracao!))) {
              _controladoraUsuario.salvarPessoa(usuario);
            }
          }
        }
      } else {
        erros.add('Erro ao buscar usuários: ${response.statusCode}');
      }

      for (var usuario in _controladoraUsuario.lista.where(
        (u) => u.ultimaAlteracao == null,
      )) {
        final response = await http.post(
          Uri.parse('$serverUrl/usuarios'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(usuario.toJson()),
        );
        if (response.statusCode == 200) {
          usuario.ultimaAlteracao = DateTime.now().toIso8601String();
          _controladoraUsuario.salvarPessoa(usuario);
        } else {
          erros.add(
            'Erro ao enviar usuário ${usuario.nome}: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      erros.add('Erro na sincronização de usuários: $e');
    }
  }

  Future<void> _sincronizarClientes() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/clientes'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['dados'];
        for (var clienteJson in data) {
          final cliente = Cliente.fromJson(clienteJson);
          if (cliente.ultimaAlteracao != null) {
            final localCliente = _controladoraCliente.lista.firstWhere(
              (c) => c.id == cliente.id,
              orElse: () => Cliente.novo(),
            );
            if (localCliente.ultimaAlteracao == null ||
                DateTime.parse(
                  cliente.ultimaAlteracao!,
                ).isAfter(DateTime.parse(localCliente.ultimaAlteracao!))) {
              _controladoraCliente.salvarCliente(cliente);
            }
          }
        }
      } else {
        erros.add('Erro ao buscar clientes: ${response.statusCode}');
      }

      for (var cliente in _controladoraCliente.lista.where(
        (c) => c.ultimaAlteracao == null,
      )) {
        final response = await http.post(
          Uri.parse('$serverUrl/clientes'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(cliente.toJson()),
        );
        if (response.statusCode == 200) {
          cliente.ultimaAlteracao = DateTime.now().toIso8601String();
          _controladoraCliente.salvarCliente(cliente);
        } else {
          erros.add(
            'Erro ao enviar cliente ${cliente.nome}: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      erros.add('Erro na sincronização de clientes: $e');
    }
  }

  Future<void> _sincronizarProdutos() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/produtos'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['dados'];
        for (var produtoJson in data) {
          final produto = Produto.fromJson(produtoJson);
          if (produto.ultimaAlteracao != null) {
            final localProduto = _controladoraProduto.lista.firstWhere(
              (p) => p.id == produto.id,
              orElse: () => Produto.nova(),
            );
            if (localProduto.ultimaAlteracao == null ||
                DateTime.parse(
                  produto.ultimaAlteracao!,
                ).isAfter(DateTime.parse(localProduto.ultimaAlteracao!))) {
              _controladoraProduto.salvarProduto(produto);
            }
          }
        }
      } else {
        erros.add('Erro ao buscar produtos: ${response.statusCode}');
      }

      for (var produto in _controladoraProduto.lista.where(
        (p) => p.ultimaAlteracao == null,
      )) {
        final response = await http.post(
          Uri.parse('$serverUrl/produtos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(produto.toJson()),
        );
        if (response.statusCode == 200) {
          produto.ultimaAlteracao = DateTime.now().toIso8601String();
          _controladoraProduto.salvarProduto(produto);
        } else {
          erros.add(
            'Erro ao enviar produto ${produto.nome}: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      erros.add('Erro na sincronização de produtos: $e');
    }
  }

  Future<void> _sincronizarPedidos() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/pedidos'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['dados'];
        for (var pedidoJson in data) {
          final pedido = Pedido.fromJson(pedidoJson);
          if (pedido.ultimaAlteracao != null) {
            final localPedidos = await _controladoraPedido.loadPedidos();
            final localPedido = localPedidos.firstWhere(
              (p) => p.id == pedido.id,
              orElse:
                  () => Pedido(
                    id: 0,
                    idCliente: 0,
                    idUsuario: 0,
                    totalPedido: 0,
                    dataCriacao: '',
                  ),
            );
            if (localPedido.ultimaAlteracao == null ||
                DateTime.parse(
                  pedido.ultimaAlteracao!,
                ).isAfter(DateTime.parse(localPedido.ultimaAlteracao!))) {
              _controladoraPedido.salvarPedido(pedido);
            }
          }
        }
      } else {
        erros.add('Erro ao buscar pedidos: ${response.statusCode}');
      }

      final localPedidos = await _controladoraPedido.loadPedidos();
      for (var pedido in localPedidos.where((p) => p.ultimaAlteracao == null)) {
        final response = await http.post(
          Uri.parse('$serverUrl/pedidos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...pedido.toJson(),
            'itens': pedido.itens.map((i) => i.toJson()).toList(),
            'pagamentos': pedido.pagamentos.map((p) => p.toJson()).toList(),
          }),
        );
        if (response.statusCode == 200) {
          pedido.ultimaAlteracao = DateTime.now().toIso8601String();
          _controladoraPedido.salvarPedido(pedido);
        } else {
          erros.add(
            'Erro ao enviar pedido #${pedido.id}: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      erros.add('Erro na sincronização de pedidos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização de Dados')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _sincronizar,
              child: const Text('Sincronizar Agora'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  erros.isEmpty
                      ? const Center(child: Text('Nenhum erro registrado'))
                      : ListView.builder(
                        itemCount: erros.length,
                        itemBuilder:
                            (context, index) => ListTile(
                              title: Text(erros[index]),
                              leading: Icon(Icons.error, color: Colors.red),
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
