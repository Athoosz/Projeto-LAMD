class Solicitacao {
  final int id;
  final String tipo;
  final String descricao;
  final String endereco;
  final String status;
  final String criadoEm;

  Solicitacao({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.endereco,
    required this.status,
    required this.criadoEm,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) => Solicitacao(
    id: json['id'],
    tipo: json['tipo']['nome'],
    descricao: json['descricao'] ?? '',
    endereco: json['endereco'],
    status: json['status'],
    criadoEm: json['criadoEm'],
  );
}
