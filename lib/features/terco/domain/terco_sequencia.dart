import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_config.dart';

/// Monta a lista completa de passos do terço, na ordem em que são rezados.
///
/// Ordem:
///  1. Orações iniciais ([TercoConfig.oracoesIniciais])
///  2. Para cada alegria (1 a 7):
///       meditação -> Pai-Nosso -> 10 Ave-Marias -> Glória
///  3. Ave-Marias extras (completam as 72)
///  4. Pelas intenções do Papa ([TercoConfig.oracoesPeloPapa])
///  5. Orações finais ([TercoConfig.oracoesFinais])
///
/// Função pura: sem áudio, sem tela, sem estado. Fácil de testar.
List<Passo> construirTerco() {
  return [
    ..._oracoesSimples(TercoConfig.oracoesIniciais),
    for (var alegria = 1; alegria <= TercoConfig.totalAlegrias; alegria++)
      ..._dezena(alegria),
    ..._aveMariasExtras(),
    // A Ave-Maria pelo Papa entra como oração simples: não conta nas 72.
    ..._oracoesSimples(TercoConfig.oracoesPeloPapa),
    ..._oracoesSimples(TercoConfig.oracoesFinais),
  ];
}

/// Passos de uma alegria: meditação, Pai-Nosso, Ave-Marias e Glória.
List<Passo> _dezena(int alegriaId) {
  return [
    Passo.meditacao(alegriaId),
    Passo.oracao(OracaoIds.paiNosso, alegriaId: alegriaId),
    for (var n = 1; n <= TercoConfig.aveMariasPorDezena; n++)
      Passo.aveMaria(
        contador: n,
        total: TercoConfig.aveMariasPorDezena,
        alegriaId: alegriaId,
      ),
    Passo.oracao(OracaoIds.gloria, alegriaId: alegriaId),
  ];
}

/// As Ave-Marias que completam a tradição das 72 (não pertencem a uma alegria).
List<Passo> _aveMariasExtras() {
  return [
    for (var n = 1; n <= TercoConfig.aveMariasExtras; n++)
      Passo.aveMaria(contador: n, total: TercoConfig.aveMariasExtras),
  ];
}

List<Passo> _oracoesSimples(List<String> ids) {
  return [for (final id in ids) Passo.oracao(id)];
}
