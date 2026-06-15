import 'dart:async';
import 'package:flutter/material.dart';
import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import '../widgets/status_badge.dart';
import 'editar_solicitacao_screen.dart';

class DetalheSolicitacaoScreen extends StatefulWidget {
  final int id;

  const DetalheSolicitacaoScreen({Key? key, required this.id}) : super(key: key);

  @override
  _DetalheSolicitacaoScreenState createState() => _DetalheSolicitacaoScreenState();
}

class _DetalheSolicitacaoScreenState extends State<DetalheSolicitacaoScreen> {
  final SolicitacaoService _solicitacaoService = SolicitacaoService();
  Solicitacao? _solicitacao;
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _carregarDetalhes();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _carregarDetalhes();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _carregarDetalhes() async {
    try {
      final data = await _solicitacaoService.buscarPorId(widget.id);
      if (mounted) {
        setState(() {
          _solicitacao = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        _timer.cancel();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar detalhes: $e')),
          );
        }
      }
    }
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir pedido'),
        content: const Text('Tem certeza que deseja excluir este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _isLoading = true);
      try {
        await _solicitacaoService.excluir(widget.id);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _editar() async {
    final atualizou = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarSolicitacaoScreen(solicitacao: _solicitacao!),
      ),
    );

    if (atualizou == true) {
      setState(() => _isLoading = true);
      _carregarDetalhes();
    }
  }

  String _formatarData(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year;
      final hora = data.hour.toString().padLeft(2, '0');
      final min = data.minute.toString().padLeft(2, '0');
      return '$dia/$mes/$ano às $hora:$min';
    } catch (e) {
      return dataIso;
    }
  }

  Widget _buildInfoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF9E9E9E),
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do pedido'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A2D)))
          : _solicitacao == null
              ? const Center(child: Text('Pedido não encontrado.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Pedido #${_solicitacao!.id}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2D6A2D),
                              ),
                            ),
                          ),
                          StatusBadge(status: _solicitacao!.status),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildInfoBlock('Tipo de Serviço', _solicitacao!.tipo),
                      _buildInfoBlock('Data do pedido', _formatarData(_solicitacao!.criadoEm)),
                      _buildInfoBlock('Endereço', _solicitacao!.endereco),
                      const Text(
                        'DESCRIÇÃO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9E9E9E),
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          _solicitacao!.descricao.isEmpty
                              ? 'Nenhuma descrição adicional informada pelo cliente.'
                              : _solicitacao!.descricao,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF424242),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (_solicitacao!.status.toLowerCase() == 'pendente')
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _excluir,
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _editar,
                                icon: const Icon(Icons.edit, color: Colors.white),
                                label: const Text('Editar', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D6A2D),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}

