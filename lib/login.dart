import 'package:app_n1/controladoras/controladora.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _EstadosTelaLogin();
}

class _EstadosTelaLogin extends State<TelaLogin> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorUsuario = TextEditingController();
  final _controladorSenha = TextEditingController();
  String? _mensagemErro;
  late Controladora _controladora;

  @override
  void initState() {
    super.initState();
    _controladora = Controladora();
    _loadPessoas();
  }

  Future<void> _loadPessoas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pessoasJson = prefs.getString('pessoas');
    if (pessoasJson != null) {
      final List<dynamic> pessoasList = jsonDecode(pessoasJson);
      _controladora.lista.clear();
      _controladora.lista.addAll(pessoasList.map((p) => Pessoa.fromJson(p)).toList());      
      setState(() {});
    } else {
      print('Nenhum usuário encontrado em no cadastro');
    }
  }

  void _entrar() {
    if (_chaveFormulario.currentState!.validate()) {
      final usuario = _controladorUsuario.text;
      final senha = _controladorSenha.text;

      bool valido = false;
      if (usuario == 'admin' && senha == 'admin' && _controladora.lista.isEmpty) {
        valido = true;
        print('Login com admin bem-sucedido');
      } else {
        valido = _controladora.lista.any(
          (p) => p.user == usuario && p.senha == senha,
        );
        if (valido) {
          print('Login bem-sucedido para usuário: $usuario');
        } else {
          print('Falha no login: usuário ou senha inválidos');
        }
      }

      if (valido) {
        Navigator.pushReplacementNamed(context, 'INICIAL');
      } else {
        setState(() {
          _mensagemErro = 'Usuário ou senha inválidos';
        });
      }
    }
  }

  @override
  void dispose() {
    _controladorUsuario.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bem-vindo',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controladorUsuario,
                        decoration: InputDecoration(
                          labelText: 'Usuário',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Informe o usuário';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controladorSenha,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Informe a senha';
                          }
                          return null;
                        },
                      ),
                      if (_mensagemErro != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _mensagemErro!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _entrar,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Entrar', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}