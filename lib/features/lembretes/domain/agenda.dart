import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';

/// Uma notificação já calculada: quando tocar e o que dizer.
class NotificacaoAgendada {
  const NotificacaoAgendada({
    required this.id,
    required this.quando,
    required this.titulo,
    required this.corpo,
  });

  final int id;
  final DateTime quando;
  final String titulo;
  final String corpo;
}

/// Quantos dias à frente o app deixa agendados.
/// O app reagenda toda vez que é aberto, então a janela nunca se esgota
/// para quem abre o app de vez em quando.
const diasAgendados = 14;

/// Escolhe a mensagem do dia. Dias seguidos sempre têm mensagens diferentes.
String mensagemDoDia(Lembrete lembrete, DateTime dia) {
  final dias = DateTime.utc(dia.year, dia.month, dia.day)
      .difference(DateTime.utc(2024))
      .inDays;
  return lembrete.mensagens[dias % lembrete.mensagens.length];
}

/// Id único de cada notificação: lembrete + posição do dia (0 a 99).
int idDaNotificacao(Lembrete lembrete, int posicaoDoDia) =>
    lembrete.id * 100 + posicaoDoDia;

/// Calcula as notificações dos próximos [diasAgendados] dias.
/// Só considera lembretes ativos, nos dias da semana escolhidos, e ignora
/// horários que já passaram hoje.
/// O resultado vem em ordem cronológica.
///
/// Função pura: não toca em celular, relógio ou tela. Fácil de testar.
List<NotificacaoAgendada> calcularAgenda(
  List<Lembrete> lembretes,
  DateTime agora,
) {
  final resultado = <NotificacaoAgendada>[];
  for (final lembrete in lembretes.where((l) => l.ativo)) {
    for (var i = 0; i < diasAgendados; i++) {
      final quando = DateTime(
        agora.year,
        agora.month,
        agora.day + i,
        lembrete.hora,
        lembrete.minuto,
      );
      if (!quando.isAfter(agora)) continue;
      if (!lembrete.dias.contains(quando.weekday)) continue;
      resultado.add(
        NotificacaoAgendada(
          id: idDaNotificacao(lembrete, i),
          quando: quando,
          titulo: lembrete.titulo,
          corpo: mensagemDoDia(lembrete, quando),
        ),
      );
    }
  }
  resultado.sort((a, b) => a.quando.compareTo(b.quando));
  return resultado;
}
