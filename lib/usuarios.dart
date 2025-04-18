// usuarios.dart
import 'package:app_n1/controladoras/controladora.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => CadastroUsuarioState();
}

class CadastroUsuarioState extends State<CadastroUsuario> {
  late final Controladora _control;

  @override
  void initState() {
    super.initState();
    _control = Controladora();
    _loadPessoas();
  }

  Future<void> _loadPessoas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pessoasJson = prefs.getString('pessoas');
    if (pessoasJson != null) {
      final List<dynamic> pessoasList = jsonDecode(pessoasJson);
      _control.lista.clear();
      _control.lista.addAll(pessoasList.map((p) => Pessoa.fromJson(p)).toList());
      setState(() {});
    }
  }

  Future<void> _savePessoas() async {
    final prefs = await SharedPreferences.getInstance();
    final String pessoasJson = jsonEncode(_control.lista.map((p) => p.toJson()).toList());
    await prefs.setString('pessoas', pessoasJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Usuários")),
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
                onPressed: () {
                  abrirPessoa(Pessoa.nova());
                },
                child: const Text("Criar novo usuário"),
              ),
            ),
            Expanded(
              child: _control.lista.isEmpty
                  ? const Center(child: Text("Nenhum usuário cadastrado"))
                  : ListView.builder(
                      itemCount: _control.lista.length,
                      itemBuilder: (context, index) {
                        var pessoa = _control.lista[index];
                        return ListTile(
                          title: Text(pessoa.nomeCompleto),
                          subtitle: Text('Usuário: ${pessoa.user}'),
                          onTap: () async {
                            await abrirPessoa(pessoa);
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

  Future<void> abrirPessoa(Pessoa pessoa) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaForm(_control, pessoa)),
    );
    await _savePessoas();
    setState(() {});
  }
}

class TelaForm extends StatefulWidget {
  final Controladora control;
  final Pessoa pessoa;

  const TelaForm(this.control, this.pessoa, {super.key});

  @override
  State<TelaForm> createState() => _TelaFormState();
}

class _TelaFormState extends State<TelaForm> {
  final GlobalKey<FormState> form_key = GlobalKey<FormState>();
  final TextEditingController _controleNome = TextEditingController();
  final TextEditingController _controleSobrenome = TextEditingController();
  final TextEditingController _controleUser = TextEditingController();
  final TextEditingController _controleSenha = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controleNome.text = widget.pessoa.nome;
    _controleSobrenome.text = widget.pessoa.sobrenome ?? '';
    _controleUser.text = widget.pessoa.user;
    _controleSenha.text = widget.pessoa.senha;
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleSobrenome.dispose();
    _controleUser.dispose();
    _controleSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Pessoa p = widget.pessoa;

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de ${p.nome.isEmpty ? "Novo Usuário" : p.nome}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: form_key,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID'),
                initialValue: p.id.toString(),
                enabled: false,
              ),
              TextFormField(
                controller: _controleNome,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controleSobrenome,
                decoration: const InputDecoration(labelText: 'Sobrenome'),
              ),
              TextFormField(
                controller: _controleUser,
                decoration: const InputDecoration(labelText: 'Usuário *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o usuário';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controleSenha,
                decoration: const InputDecoration(labelText: 'Senha *'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (p.id != 0)
                    ElevatedButton(
                      onPressed: () {
                        widget.control.excluirPessoa(p);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Excluir'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (form_key.currentState!.validate()) {
                        final pessoaAtualizada = Pessoa(
                          id: p.id,
                          nome: _controleNome.text,
                          sobrenome: _controleSobrenome.text.isEmpty ? null : _controleSobrenome.text,
                          user: _controleUser.text,
                          senha: _controleSenha.text,
                        );
                        widget.control.salvarPessoa(pessoaAtualizada);
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