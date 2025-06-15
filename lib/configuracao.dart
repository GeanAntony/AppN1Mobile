import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaConfiguracao extends StatefulWidget {
  const TelaConfiguracao({super.key});

  @override
  State<TelaConfiguracao> createState() => _TelaConfiguracaoState();
}

class _TelaConfiguracaoState extends State<TelaConfiguracao> {
  final _controladorServidor = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _controladorServidor.text =
        prefs.getString('serverUrl') ?? 'http://localhost:8080';
  }

  Future<void> _salvarConfig() async {
    if (_chaveFormulario.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('serverUrl', _controladorServidor.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Configuração salva com sucesso')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _chaveFormulario,
          child: Column(
            children: [
              TextFormField(
                controller: _controladorServidor,
                decoration: const InputDecoration(
                  labelText: 'Link do Servidor',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o link do servidor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarConfig,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
