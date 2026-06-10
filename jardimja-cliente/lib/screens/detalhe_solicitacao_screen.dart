import 'dart:async';
import 'package:flutter/material.dart';
import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import '../widgets/status_badge.dart';

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
                    ],
                  ),
                ),
    );
  }
}

