class Cidade {
  int id;
  String nome;

  Cidade({this.id = 0, this.nome = ""});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  @override
  String toString() {
    return 'Cidade{id: $id, nome: $nome}';
  }
}
