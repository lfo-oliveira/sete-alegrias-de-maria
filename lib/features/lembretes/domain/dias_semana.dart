/// Ordem em que os dias aparecem na tela: começa no domingo,
/// como o calendário da semana do app.
const diasNaOrdemDoCalendario = <int>[7, 1, 2, 3, 4, 5, 6];

const _abreviados = {
  1: 'Seg',
  2: 'Ter',
  3: 'Qua',
  4: 'Qui',
  5: 'Sex',
  6: 'Sáb',
  7: 'Dom',
};

String abreviacaoDoDia(int dia) => _abreviados[dia] ?? '';

/// Resume os dias escolhidos em uma frase curta.
String descreverDias(Set<int> dias) {
  if (dias.length == 7) return 'Todos os dias';
  if (dias.length == 5 && dias.every((d) => d >= 1 && d <= 5)) {
    return 'De segunda a sexta';
  }
  if (dias.length == 2 && dias.containsAll({6, 7})) return 'Fins de semana';
  return [
    for (final d in diasNaOrdemDoCalendario)
      if (dias.contains(d)) abreviacaoDoDia(d),
  ].join(', ');
}
