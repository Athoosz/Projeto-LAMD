import 'package:flutter/material.dart';
import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';

class DetalheSolicitacaoScreen extends StatefulWidget {
  final Solicitacao solicitacao;

  const DetalheSolicitacaoScreen({Key? key, required this.solicitacao}) : super(key: key);

  @override
  _DetalheSolicitacaoScreenState createState() => _DetalheSolicitacaoScreenState();
}

class _DetalheSolicitacaoScreenState extends State<DetalheSolicitacaoScreen> {
  final SolicitacaoService _service = SolicitacaoService();
  bool _isLoading = false;

  Future<void> _atualizarStatus(String novoStatus) async {
    setState(() => _isLoading = true);
    try {
      await _service.atualizarStatus(widget.solicitacao.id, novoStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para $novoStatus com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAcoes() {
    if (widget.solicitacao.status == 'pendente') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.close),
            label: const Text('Recusar'),
            onPressed: () => _atualizarStatus('recusado'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6A2D)),
            icon: const Icon(Icons.check),
            label: const Text('Aceitar'),
            onPressed: () => _atualizarStatus('aceito'),
          ),
        ],
      );
    } else if (widget.solicitacao.status == 'aceito' || widget.solicitacao.status == 'em_andamento') {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A2D),
            minimumSize: const Size(200, 50),
          ),
          icon: const Icon(Icons.done_all),
          label: const Text('Marcar como Concluído', style: TextStyle(fontSize: 16)),
          onPressed: () => _atualizarStatus('concluido'),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A2D)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Serviço: ${widget.solicitacao.tipo}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D6A2D)),
                          ),
                          const Divider(height: 30),
                          const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.solicitacao.descricao.isEmpty ? 'Sem descrição' : widget.solicitacao.descricao),
                          const SizedBox(height: 16),
                          const Text('Endereço:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.solicitacao.endereco),
                          const SizedBox(height: 16),
                          const Text('Status Atual:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            widget.solicitacao.status.toUpperCase(),
                            style: TextStyle(
                              color: widget.solicitacao.status == 'pendente' ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Data de Criação:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.solicitacao.criadoEm),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAcoes(),
                ],
              ),
            ),
    );
  }
}
