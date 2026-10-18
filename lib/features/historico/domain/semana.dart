import 'package:sete_alegrias_de_maria/data/models/historico.dart';

/// Letras que aparecem sobre cada dia do calendário (domingo a sábado).
const letrasDiasSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

/// Nomes completos, usados na leitura em voz alta (acessibilidade).
const nomesDiasSemana = [
  'Domingo',
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
];

/// Os 7 dias da semana que contém [agora], de domingo a sábado.
/// Para a semana começar na segunda, mude só a linha de "deslocamento".
List<DateTime> diasDaSemana(DateTime agora) {
  final hoje = Historico.soData(agora);

  // DateTime.weekday: segunda = 1 ... domingo = 7. Com "% 7", domingo vira 0.
  final deslocamento = hoje.weekday % 7;

  return [
    for (var i = 0; i < 7; i++)
      DateTime(hoje.year, hoje.month, hoje.day - deslocamento + i),
  ];
}
