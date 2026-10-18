/// Um lembrete diário de oração.
class Lembrete {
  const Lembrete({
    required this.id,
    required this.hora,
    required this.minuto,
    required this.titulo,
    required this.descricao,
    required this.mensagens,
    this.ativo = true,
  });

  /// Identificador fixo (é guardado no celular e usado nas notificações).
  final int id;
  final int hora;
  final int minuto;

  /// Título da notificação e da linha na tela de lembretes.
  final String titulo;

  /// Explicação curta mostrada na tela de lembretes.
  final String descricao;

  /// Mensagens que se alternam, uma por dia.
  final List<String> mensagens;

  final bool ativo;

  String get horario =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  Lembrete copyWith({bool? ativo}) => Lembrete(
        id: id,
        hora: hora,
        minuto: minuto,
        titulo: titulo,
        descricao: descricao,
        mensagens: mensagens,
        ativo: ativo ?? this.ativo,
      );
}
