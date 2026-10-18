/// Uma oração fixa do terço (Pai-Nosso, Ave-Maria, Credo...).
/// Vem de assets/content/oracoes.json.
class Oracao {
  const Oracao({
    required this.id,
    required this.titulo,
    required this.texto,
    this.audio,
  });

  factory Oracao.fromJson(Map<String, dynamic> json) {
    return Oracao(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      texto: json['texto'] as String,
      audio: json['audio'] as String?,
    );
  }

  final String id;
  final String titulo;
  final String texto;

  /// Caminho do áudio (voz humana). Null enquanto não houver gravação.
  final String? audio;
}
