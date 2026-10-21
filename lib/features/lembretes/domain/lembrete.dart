/// Todos os dias da semana, no padrão do Dart (1 = segunda ... 7 = domingo).
const todosOsDias = <int>{1, 2, 3, 4, 5, 6, 7};

/// Ids a partir deste número são lembretes criados pelo fiel.
/// Os ids menores são os lembretes fixos do app (Hora da Ave-Maria).
const primeiroIdPersonalizado = 10;

/// Um lembrete diário de oração.
class Lembrete {
  const Lembrete({
    required this.id,
    required this.hora,
    required this.minuto,
    required this.titulo,
    required this.descricao,
    required this.mensagens,
    this.dias = todosOsDias,
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

  /// Dias da semana em que avisa (1 = segunda ... 7 = domingo).
  final Set<int> dias;

  final bool ativo;

  /// Criado pelo fiel (pode editar o horário e apagar).
  bool get ehPersonalizado => id >= primeiroIdPersonalizado;

  String get horario =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  Lembrete copyWith({bool? ativo, int? hora, int? minuto, Set<int>? dias}) =>
      Lembrete(
        id: id,
        hora: hora ?? this.hora,
        minuto: minuto ?? this.minuto,
        titulo: titulo,
        descricao: descricao,
        mensagens: mensagens,
        dias: dias ?? this.dias,
        ativo: ativo ?? this.ativo,
      );
}
