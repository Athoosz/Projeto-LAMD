class Usuario {
  final int id;
  final String nome;
  final String email;
  final String perfil;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      perfil: json['perfil'],
    );
  }
}
