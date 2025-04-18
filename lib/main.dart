// main.dart
import 'package:app_n1/clientes.dart';
import 'package:app_n1/home.dart';
import 'package:app_n1/login.dart';
import 'package:app_n1/produtos.dart';
import 'package:app_n1/usuarios.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AplicativoPrincipal());
}

class AplicativoPrincipal extends StatelessWidget {
  const AplicativoPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'LOGIN',
      routes: {
        'LOGIN': (context) => TelaLogin(),
        'INICIAL': (context) => TelaInicial(),
        'CADASTRO_PRODUTO': (context) => CadastroProduto(), 
        'CADASTRO_CLIENTE': (context) => CadastroCliente(),
        'CADASTRO_USUARIO': (context) => CadastroUsuario(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}