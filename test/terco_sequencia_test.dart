import 'package:flutter_test/flutter_test.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_config.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_sequencia.dart';

void main() {
  final passos = construirTerco();

  test('reza 72 Ave-Marias no total', () {
    final total = passos.where((p) => p.tipo == TipoPasso.aveMaria).length;
    expect(total, TercoConfig.totalAveMarias);
    expect(total, 72);
  });

  test('tem 7 meditações, uma por alegria, em ordem', () {
    final meditacoes = passos
        .where((p) => p.tipo == TipoPasso.meditacao)
        .map((p) => p.alegriaId)
        .toList();
    expect(meditacoes, [1, 2, 3, 4, 5, 6, 7]);
  });

  test('começa pelas orações iniciais e termina pelas finais', () {
    expect(passos.first.oracaoId, TercoConfig.oracoesIniciais.first);
    expect(passos.last.oracaoId, TercoConfig.oracoesFinais.last);
  });

  test('cada dezena segue: meditação, Pai-Nosso, 10 Ave-Marias, Glória', () {
    for (var alegria = 1; alegria <= TercoConfig.totalAlegrias; alegria++) {
      final daAlegria = passos.where((p) => p.alegriaId == alegria).toList();

      expect(daAlegria.first.tipo, TipoPasso.meditacao);
      expect(daAlegria[1].oracaoId, OracaoIds.paiNosso);
      expect(
        daAlegria.where((p) => p.tipo == TipoPasso.aveMaria).length,
        TercoConfig.aveMariasPorDezena,
      );
      expect(daAlegria.last.oracaoId, OracaoIds.gloria);
    }
  });

  test('o contador das Ave-Marias vai de 1 até o total do grupo', () {
    final dezena1 = passos
        .where((p) => p.alegriaId == 1 && p.tipo == TipoPasso.aveMaria)
        .toList();
    expect(dezena1.first.contador, 1);
    expect(dezena1.last.contador, 10);
    expect(dezena1.last.total, 10);
  });

  test('as 2 Ave-Marias extras vêm depois da 7ª alegria e antes da Salve Rainha',
      () {
    final extras = passos
        .where((p) => p.tipo == TipoPasso.aveMaria && p.alegriaId == null)
        .toList();
    expect(extras.length, TercoConfig.aveMariasExtras);

    final indiceUltimoGloria =
        passos.lastIndexWhere((p) => p.oracaoId == OracaoIds.gloria);
    final indiceSalve =
        passos.indexWhere((p) => p.oracaoId == OracaoIds.salveRainha);
    final indiceExtra = passos.indexOf(extras.first);

    expect(indiceExtra, greaterThan(indiceUltimoGloria));
    expect(indiceExtra, lessThan(indiceSalve));
  });
}
