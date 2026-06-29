import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/solicitacao_service.dart';
import '../models/solicitacao.dart';
import 'detalhe_solicitacao_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final SolicitacaoService _solicitacaoService = SolicitacaoService();
  final AuthService _authService = AuthService();
  
  List<Solicitacao> _pendentes = [];
  List<Solicitacao> _emAndamento = [];
  bool _isLoading = true;
  Timer? _pollingTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _carregarDadosSilencioso();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    await _carregarDadosSilencioso();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _carregarDadosSilencioso() async {
    try {
      final solicitacoes = await _solicitacaoService.listar();
      if (!mounted) return;
      setState(() {
        _pendentes = solicitacoes.where((s) => s.status == 'pendente').toList();
        _emAndamento = solicitacoes.where((s) => s.status == 'aceito' || s.status == 'em_andamento').toList();
      });
    } catch (e) {
      print('Erro ao carregar solicitações: $e');
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildLista(List<Solicitacao> lista) {
    if (lista.isEmpty) {
      return const Center(
        child: Text('Nenhuma solicitação encontrada.', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: const Color(0xFF2D6A2D),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final s = lista[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                s.tipo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(s.endereco),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${s.status.toUpperCase()}',
                    style: TextStyle(
                      color: s.status == 'pendente' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2D6A2D)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalheSolicitacaoScreen(solicitacao: s),
                  ),
                ).then((_) => _carregarDados());
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Prestador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Meus Serviços'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D6A2D)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(_pendentes),
                _buildLista(_emAndamento),
              ],
            ),
    );
  }
}
