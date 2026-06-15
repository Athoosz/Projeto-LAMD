import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solicitacao.dart';
import 'auth_service.dart';

class SolicitacaoService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Solicitacao>> listar() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/solicitacoes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Solicitacao.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else {
      throw Exception('Falha ao listar solicitações');
    }
  }

  Future<Solicitacao> buscarPorId(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/solicitacoes/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Solicitacao.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else {
      throw Exception('Falha ao buscar solicitação');
    }
  }

  Future<void> criar(int tipoId, String descricao, String endereco) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/solicitacoes'),
      headers: headers,
      body: jsonEncode({
        'tipoId': tipoId,
        'descricao': descricao,
        'endereco': endereco,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      if (response.statusCode == 401) throw Exception('401');
      throw Exception('Falha ao criar solicitação');
    }
  }

  Future<void> editar(int id, int tipoId, String descricao, String endereco) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/solicitacoes/$id'),
      headers: headers,
      body: jsonEncode({
        'tipoId': tipoId,
        'descricao': descricao,
        'endereco': endereco,
      }),
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401) throw Exception('401');
      throw Exception('Falha ao editar solicitação');
    }
  }

  Future<void> excluir(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/solicitacoes/$id'),
      headers: headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      if (response.statusCode == 401) throw Exception('401');
      throw Exception('Falha ao excluir solicitação');
    }
  }

  Future<List<dynamic>> listarTipos() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/tipos'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('401');
    } else {
      throw Exception('Falha ao listar tipos');
    }
  }
}
