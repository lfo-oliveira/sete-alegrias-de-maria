/// Uma das 7 alegrias: trecho bíblico + breve reflexão.
/// Vem de assets/content/alegrias.json.
class Alegria {
  const Alegria({
    required this.id,
    required this.titulo,
    required this.referencia,
    required this.trechoBiblico,
    required this.reflexao,
    this.revisadoPor,
    this.dataRevisao,
  });

  factory Alegria.fromJson(Map<String, dynamic> json) {
    return Alegria(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      referencia: json['referencia'] as String,
      trechoBiblico: json['trecho_biblico'] as String,
      reflexao: json['reflexao'] as String,
      revisadoPor: json['revisado_por'] as String?,
      dataRevisao: json['data_revisao'] as String?,
    );
  }

  final int id;
  final String titulo;
  final String referencia;
  final String trechoBiblico;
  final String reflexao;

  /// Quem conferiu o texto (ex.: o padre). Null = ainda não revisado.
  final String? revisadoPor;
  final String? dataRevisao;

  bool get revisado => revisadoPor != null;
}
