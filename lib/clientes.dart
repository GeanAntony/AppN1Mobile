// clientes.dart
import 'package:app_n1/controladoras/controladoraCliente.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CadastroCliente extends StatefulWidget {
  const CadastroCliente({super.key});

  @override
  State<CadastroCliente> createState() => _CadastroClienteState();
}

class _CadastroClienteState extends State<CadastroCliente> {
  final _controladora = ControladoraCliente();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? clientesJson = prefs.getString('clientes');
    if (clientesJson != null) {
      final List<dynamic> clientesList = jsonDecode(clientesJson);
      _controladora.lista.clear();
      _controladora.lista.addAll(clientesList.map((c) => Cliente.fromJson(c)).toList());
      setState(() {});
    }
  }

  Future<void> _saveClientes() async {
    final prefs = await SharedPreferences.getInstance();
    final String clientesJson = jsonEncode(_controladora.lista.map((c) => c.toJson()).toList());
    await prefs.setString('clientes', clientesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro de Clientes")),
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
                      builder: (context) => FormularioCliente(
                        controladora: _controladora,
                        cliente: Cliente.novo(),
                      ),
                    ),
                  );
                  await _saveClientes();
                  setState(() {});
                },
                child: const Text("Criar novo cliente"),
              ),
            ),
            Expanded(
              child: _controladora.lista.isEmpty
                  ? const Center(child: Text("Nenhum cliente cadastrado"))
                  : ListView.builder(
                      itemCount: _controladora.lista.length,
                      itemBuilder: (context, index) {
                        final cliente = _controladora.lista[index];
                        return ListTile(
                          title: Text(cliente.nome),
                          subtitle: Text('CPF/CNPJ: ${cliente.cpfCnpj} - Tipo: ${cliente.tipo == 'F' ? 'Física' : 'Jurídica'}'),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormularioCliente(
                                  controladora: _controladora,
                                  cliente: cliente,
                                ),
                              ),
                            );
                            await _saveClientes();
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

class FormularioCliente extends StatefulWidget {
  final ControladoraCliente controladora;
  final Cliente cliente;

  const FormularioCliente({
    super.key,
    required this.controladora,
    required this.cliente,
  });

  @override
  State<FormularioCliente> createState() => _FormularioClienteState();
}

class _FormularioClienteState extends State<FormularioCliente> {
  final _chaveFormulario = GlobalKey<FormState>();
  late TextEditingController _controladorNome;
  late TextEditingController _controladorTipo;
  late TextEditingController _controladorCpfCnpj;
  late TextEditingController _controladorEmail;
  late TextEditingController _controladorTelefone;
  late TextEditingController _controladorCep;
  late TextEditingController _controladorEndereco;
  late TextEditingController _controladorBairro;
  late TextEditingController _controladorCidade;
  late TextEditingController _controladorUf;

  @override
  void initState() {
    super.initState();
    _controladorNome = TextEditingController(text: widget.cliente.nome);
    _controladorTipo = TextEditingController(text: widget.cliente.tipo);
    _controladorCpfCnpj = TextEditingController(text: widget.cliente.cpfCnpj);
    _controladorEmail = TextEditingController(text: widget.cliente.email ?? '');
    _controladorTelefone = TextEditingController(text: widget.cliente.telefone ?? '');
    _controladorCep = TextEditingController(text: widget.cliente.cep ?? '');
    _controladorEndereco = TextEditingController(text: widget.cliente.endereco ?? '');
    _controladorBairro = TextEditingController(text: widget.cliente.bairro ?? '');
    _controladorCidade = TextEditingController(text: widget.cliente.cidade ?? '');
    _controladorUf = TextEditingController(text: widget.cliente.uf ?? '');
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorTipo.dispose();
    _controladorCpfCnpj.dispose();
    _controladorEmail.dispose();
    _controladorTelefone.dispose();
    _controladorCep.dispose();
    _controladorEndereco.dispose();
    _controladorBairro.dispose();
    _controladorCidade.dispose();
    _controladorUf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de ${widget.cliente.nome.isEmpty ? 'Novo Cliente' : widget.cliente.nome}')),
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
                controller: _controladorTipo,
                decoration: const InputDecoration(labelText: 'Tipo (F - Física, J - Jurídica) *'),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe o tipo';
                  }
                  if (!['F', 'J'].contains(valor)) {
                    return 'Tipo deve ser F ou J';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorCpfCnpj,
                decoration: const InputDecoration(labelText: 'CPF/CNPJ *'),
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Informe o CPF ou CNPJ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controladorEmail,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _controladorTelefone,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _controladorCep,
                decoration: const InputDecoration(labelText: 'CEP'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _controladorEndereco,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              TextFormField(
                controller: _controladorBairro,
                decoration: const InputDecoration(labelText: 'Bairro'),
              ),
              TextFormField(
                controller: _controladorCidade,
                decoration: const InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: _controladorUf,
                decoration: const InputDecoration(labelText: 'UF'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.cliente.id != 0)
                    ElevatedButton(
                      onPressed: () {
                        widget.controladora.excluirCliente(widget.cliente);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Excluir'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (_chaveFormulario.currentState!.validate()) {
                        final clienteAtualizado = Cliente(
                          id: widget.cliente.id,
                          nome: _controladorNome.text,
                          tipo: _controladorTipo.text,
                          cpfCnpj: _controladorCpfCnpj.text,
                          email: _controladorEmail.text.isEmpty ? null : _controladorEmail.text,
                          telefone: _controladorTelefone.text.isEmpty ? null : _controladorTelefone.text,
                          cep: _controladorCep.text.isEmpty ? null : _controladorCep.text,
                          endereco: _controladorEndereco.text.isEmpty ? null : _controladorEndereco.text,
                          bairro: _controladorBairro.text.isEmpty ? null : _controladorBairro.text,
                          cidade: _controladorCidade.text.isEmpty ? null : _controladorCidade.text,
                          uf: _controladorUf.text.isEmpty ? null : _controladorUf.text,
                        );
                        widget.controladora.salvarCliente(clienteAtualizado);
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