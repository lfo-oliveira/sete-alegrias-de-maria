/// Histórico de oração do fiel: quantos terços rezou, há quantos dias
/// seguidos e em quais dias rezou. É só DADO e regra de contagem: não guarda
/// nada nem desenha tela.
class Historico {
  const Historico({
    this.tercosRezados = 0,
    this.sequenciaSalva = 0,
    this.ultimoDia,
    this.diasRezados = const <DateTime>{},
  });

  /// Quantos dias para trás guardamos no calendário (mantém o arquivo leve).
  static const diasGuardados = 400;

  final int tercosRezados;

  /// Sequência de dias vista no último terço rezado.
  /// Para mostrar na tela, use [diasSeguidos] (ele confere se a sequência
  /// ainda está valendo hoje).
  final int sequenciaSalva;

  /// Último dia (só a data) em que um terço foi concluído.
  final DateTime? ultimoDia;

  /// Todos os dias (só a data) em que o fiel concluiu pelo menos um terço.
  /// Alimenta o calendário da semana.
  final Set<DateTime> diasRezados;

  static DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

  bool rezouHoje(DateTime agora) =>
      ultimoDia != null && ultimoDia == soData(agora);

  bool rezouOntem(DateTime agora) {
    final h = soData(agora);
    return ultimoDia == DateTime(h.year, h.month, h.day - 1);
  }

  /// O fiel concluiu um terço neste [dia]?
  bool rezouNoDia(DateTime dia) => diasRezados.contains(soData(dia));

  /// Dias seguidos que valem HOJE. Se o fiel não rezou nem hoje nem ontem,
  /// a sequência recomeça: mostramos 0, sem cobrança.
  int diasSeguidos(DateTime agora) =>
      (rezouHoje(agora) || rezouOntem(agora)) ? sequenciaSalva : 0;

  /// Devolve um novo histórico com mais um terço rezado em [agora].
  Historico registrarTerco(DateTime agora) {
    final hoje = soData(agora);
    final limite = DateTime(hoje.year, hoje.month, hoje.day - diasGuardados);
    final dias = <DateTime>{
      for (final d in diasRezados)
        if (!d.isBefore(limite)) d,
      hoje,
    };

    // Mais de um terço no mesmo dia: conta o terço, a sequência não muda.
    if (rezouHoje(agora)) {
      return Historico(
        tercosRezados: tercosRezados + 1,
        sequenciaSalva: sequenciaSalva,
        ultimoDia: hoje,
        diasRezados: dias,
      );
    }

    // Rezou ontem: a sequência continua. Senão, recomeça em 1.
    return Historico(
      tercosRezados: tercosRezados + 1,
      sequenciaSalva: rezouOntem(agora) ? sequenciaSalva + 1 : 1,
      ultimoDia: hoje,
      diasRezados: dias,
    );
  }
}
