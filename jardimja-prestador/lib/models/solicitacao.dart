class Solicitacao {
  final int id;
  final String tipo;
  final String descricao;
  final String endereco;
  final int tipoId;
  final String status;
  final String criadoEm;
  final dynamic cliente;

  Solicitacao({
    required this.id,
    required this.tipo,
    required this.tipoId,
    required this.descricao,
    required this.endereco,
    required this.status,
    required this.criadoEm,
    this.cliente,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) => Solicitacao(
    id: json['id'],
    tipo: json['tipo'] != null ? json['tipo']['nome'] : '',
    tipoId: json['tipoId'],
    descricao: json['descricao'] ?? '',
    endereco: json['endereco'],
    status: json['status'],
    criadoEm: json['criadoEm'],
    cliente: json['cliente'],
  );
}
