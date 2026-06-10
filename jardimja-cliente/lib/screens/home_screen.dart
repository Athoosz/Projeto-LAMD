import 'dart:async';
import 'package:flutter/material.dart';
import '../models/solicitacao.dart';
import '../services/solicitacao_service.dart';
import '../services/auth_service.dart';
import '../widgets/solicitacao_card.dart';
import 'nova_solicitacao_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SolicitacaoService _solicitacaoService = SolicitacaoService();
  final AuthService _authService = AuthService();
  List<Solicitacao> _solicitacoes = [];
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _carregarSolicitacoes();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _carregarSolicitacoes() async {
    try {
      final list = await _solicitacaoService.listar();
      if (mounted) {
        setState(() {
          _solicitacoes = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e.toString().contains('401')) {
        _sair();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _sair() async {
    _timer.cancel();
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JardimJá', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D6A2D)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Olá!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Expanded(
                  child: _solicitacoes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.park, size: 64, color: Color(0xFFBDBDBD)),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum pedido ainda',
                                style: TextStyle(color: Color(0xFF757575), fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _solicitacoes.length,
                          itemBuilder: (context, index) {
                            return SolicitacaoCard(solicitacao: _solicitacoes[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D6A2D),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NovaSolicitacaoScreen(),
            ),
          );
          _carregarSolicitacoes();
        },
      ),
    );
  }
}

