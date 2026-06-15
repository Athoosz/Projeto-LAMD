import 'package:flutter/material.dart';
import '../services/solicitacao_service.dart';
import '../models/solicitacao.dart';

class EditarSolicitacaoScreen extends StatefulWidget {
  final Solicitacao solicitacao;

  const EditarSolicitacaoScreen({Key? key, required this.solicitacao}) : super(key: key);

  @override
  _EditarSolicitacaoScreenState createState() => _EditarSolicitacaoScreenState();
}

class _EditarSolicitacaoScreenState extends State<EditarSolicitacaoScreen> {
  final SolicitacaoService _solicitacaoService = SolicitacaoService();
  late TextEditingController _descricaoController;
  late TextEditingController _enderecoController;
  
  List<dynamic> _tipos = [];
  int? _tipoSelecionado;
  bool _isLoading = false;
  bool _isLoadingTipos = true;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.solicitacao.descricao);
    _enderecoController = TextEditingController(text: widget.solicitacao.endereco);
    _carregarTipos();
  }

  Future<void> _carregarTipos() async {
    try {
      final tipos = await _solicitacaoService.listarTipos();
      if (mounted) {
        setState(() {
          _tipos = tipos;
          _tipoSelecionado = widget.solicitacao.tipoId;
          _isLoadingTipos = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        _redirecionarLogin();
      } else {
        if (mounted) {
          setState(() => _isLoadingTipos = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _salvar() async {
    if (_tipoSelecionado == null || _enderecoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _solicitacaoService.editar(
        widget.solicitacao.id,
        _tipoSelecionado!,
        _descricaoController.text,
        _enderecoController.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (e.toString().contains('401')) {
        _redirecionarLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirecionarLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar pedido'),
      ),
      body: _isLoadingTipos
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A2D)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Tipo de Serviço'),
                    value: _tipoSelecionado,
                    items: _tipos.map((tipo) {
                      return DropdownMenuItem<int>(
                        value: tipo['id'],
                        child: Text(tipo['nome']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _tipoSelecionado = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(labelText: 'Endereço Completo'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A2D)))
                      : ElevatedButton(
                          onPressed: _salvar,
                          child: const Text('Salvar alterações'),
                        ),
                ],
              ),
            ),
    );
  }
}
