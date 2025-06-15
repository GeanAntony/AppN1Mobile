import 'package:app_n1/controladoras/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Pedido {
  int id;
  int idCliente;
  int idUsuario;
  double totalPedido;
  String dataCriacao;
  String? ultimaAlteracao;
  List<PedidoItem> itens;
  List<PedidoPagamento> pagamentos;

  Pedido({
    required this.id,
    required this.idCliente,
    required this.idUsuario,
    required this.totalPedido,
    required this.dataCriacao,
    this.ultimaAlteracao,
    this.itens = const [],
    this.pagamentos = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idCliente': idCliente,
    'idUsuario': idUsuario,
    'totalPedido': totalPedido,
    'dataCriacao': dataCriacao,
    'ultimaAlteracao': ultimaAlteracao,
  };

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    id: json['id'],
    idCliente: json['idCliente'],
    idUsuario: json['idUsuario'],
    totalPedido: json['totalPedido'],
    dataCriacao: json['dataCriacao'],
    ultimaAlteracao: json['ultimaAlteracao'],
  );
}

class PedidoItem {
  int id;
  int idPedido;
  int idProduto;
  double quantidade;
  double totalItem;

  PedidoItem({
    required this.id,
    required this.idPedido,
    required this.idProduto,
    required this.quantidade,
    required this.totalItem,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idPedido': idPedido,
    'idProduto': idProduto,
    'quantidade': quantidade,
    'totalItem': totalItem,
  };

  factory PedidoItem.fromJson(Map<String, dynamic> json) => PedidoItem(
    id: json['id'],
    idPedido: json['idPedido'],
    idProduto: json['idProduto'],
    quantidade: json['quantidade'],
    totalItem: json['totalItem'],
  );
}

class PedidoPagamento {
  int id;
  int idPedido;
  double valor;

  PedidoPagamento({
    required this.id,
    required this.idPedido,
    required this.valor,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'idPedido': idPedido,
    'valor': valor,
  };

  factory PedidoPagamento.fromJson(Map<String, dynamic> json) =>
      PedidoPagamento(
        id: json['id'],
        idPedido: json['idPedido'],
        valor: json['valor'],
      );
}

class ControladoraPedido {
  Future<void> salvarPedido(Pedido pedido) async {
    if (pedido.itens.isEmpty || pedido.pagamentos.isEmpty) {
      throw Exception('Pedido deve ter pelo menos 1 item e 1 pagamento');
    }
    final totalItens = pedido.itens.fold(
      0.0,
      (sum, item) => sum + item.totalItem,
    );
    final totalPagamentos = pedido.pagamentos.fold(
      0.0,
      (sum, pagamento) => sum + pagamento.valor,
    );
    if (totalItens != totalPagamentos) {
      throw Exception('Total dos itens deve ser igual ao total dos pagamentos');
    }

    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      if (pedido.id == 0) {
        pedido.id = await txn.insert('pedidos', pedido.toJson());
        for (var item in pedido.itens) {
          item.idPedido = pedido.id;
          item.id = await txn.insert('pedido_itens', item.toJson());
        }
        for (var pagamento in pedido.pagamentos) {
          pagamento.idPedido = pedido.id;
          pagamento.id = await txn.insert(
            'pedido_pagamentos',
            pagamento.toJson(),
          );
        }
      } else {
        await txn.update(
          'pedidos',
          pedido.toJson(),
          where: 'id = ?',
          whereArgs: [pedido.id],
        );
        await txn.delete(
          'pedido_itens',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
        await txn.delete(
          'pedido_pagamentos',
          where: 'idPedido = ?',
          whereArgs: [pedido.id],
        );
        for (var item in pedido.itens) {
          item.idPedido = pedido.id;
          item.id = await txn.insert('pedido_itens', item.toJson());
        }
        for (var pagamento in pedido.pagamentos) {
          pagamento.idPedido = pedido.id;
          pagamento.id = await txn.insert(
            'pedido_pagamentos',
            pagamento.toJson(),
          );
        }
      }
    });
  }

  Future<List<Pedido>> loadPedidos() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> pedidoMaps = await db.query('pedidos');
    final List<Pedido> pedidos = [];

    for (var pedidoMap in pedidoMaps) {
      final itens = await db.query(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [pedidoMap['id']],
      );
      final pagamentos = await db.query(
        'pedido_pagamentos',
        where: 'idPedido = ?',
        whereArgs: [pedidoMap['id']],
      );
      pedidos.add(
        Pedido(
          id: pedidoMap['id'],
          idCliente: pedidoMap['idCliente'],
          idUsuario: pedidoMap['idUsuario'],
          totalPedido: pedidoMap['totalPedido'],
          dataCriacao: pedidoMap['dataCriacao'],
          ultimaAlteracao: pedidoMap['ultimaAlteracao'],
          itens: itens.map((i) => PedidoItem.fromJson(i)).toList(),
          pagamentos:
              pagamentos.map((p) => PedidoPagamento.fromJson(p)).toList(),
        ),
      );
    }
    return pedidos;
  }

  Future<void> excluirPedido(Pedido pedido) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'pedido_itens',
        where: 'idPedido = ?',
        whereArgs: [pedido.id],
      );
      await txn.delete(
        'pedido_pagamentos',
        where: 'idPedido = ?',
        whereArgs: [pedido.id],
      );
      await txn.delete('pedidos', where: 'id = ?', whereArgs: [pedido.id]);
    });
  }
}
