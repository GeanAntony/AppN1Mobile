import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Inicial"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bem-vindo ao Sistema de Vendas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _criarBotaoNavegacao(
                  context,
                  'Cadastrar Produto',
                  'CADASTRO_PRODUTO',
                  Icons.inventory,
                ),
                const SizedBox(height: 16),
                _criarBotaoNavegacao(
                  context,
                  'Cadastrar Cliente',
                  'CADASTRO_CLIENTE',
                  Icons.person_add,
                ),
                const SizedBox(height: 16),
                _criarBotaoNavegacao(
                  context,
                  'Cadastrar Usuário',
                  'CADASTRO_USUARIO',
                  Icons.group_add,
                ),
                const SizedBox(height: 16),
                _criarBotaoNavegacao(
                  context,
                  'Cadastrar Pedido',
                  'CADASTRO_PEDIDO',
                  Icons.shopping_cart,
                ),
                const SizedBox(height: 16),
                _criarBotaoNavegacao(
                  context,
                  'Sincronizar Dados',
                  'SINCRONIZACAO',
                  Icons.sync,
                ),
                const SizedBox(height: 16),
                _criarBotaoNavegacao(
                  context,
                  'Configuração',
                  'CONFIGURACAO',
                  Icons.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _criarBotaoNavegacao(
    BuildContext context,
    String rotulo,
    String rota,
    IconData icone,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushReplacementNamed(context, rota);
      },
      icon: Icon(icone, size: 24),
      label: Text(rotulo, style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
