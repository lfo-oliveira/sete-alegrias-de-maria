import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_sequencia.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/faixa_da_alegria.dart';

const _anunciacao = Alegria(
  id: 1,
  titulo: 'A Anunciação',
  referencia: 'Lc 1, 26-38',
  trechoBiblico: 'texto',
  reflexao: 'reflexão',
);

const _conteudo = Conteudo(
  oracoes: {},
  alegrias: {1: _anunciacao},
);

Future<void> _mostrar(WidgetTester tester, Passo passo) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: FaixaDaAlegria(passo: passo, conteudo: _conteudo),
      ),
    ),
  );
}

void main() {
  testWidgets('mostra a alegria no Pai-Nosso da dezena', (tester) async {
    await _mostrar(tester, const Passo.oracao(OracaoIds.paiNosso, alegriaId: 1));
    expect(find.text('1ª Alegria · A Anunciação'), findsOneWidget);
  });

  testWidgets('mostra a alegria em cada Ave-Maria da dezena', (tester) async {
    await _mostrar(
      tester,
      const Passo.aveMaria(contador: 7, total: 10, alegriaId: 1),
    );
    expect(find.text('1ª Alegria · A Anunciação'), findsOneWidget);
  });

  testWidgets('mostra a alegria no Glória da dezena', (tester) async {
    await _mostrar(tester, const Passo.oracao(OracaoIds.gloria, alegriaId: 1));
    expect(find.text('1ª Alegria · A Anunciação'), findsOneWidget);
  });

  testWidgets('não repete na meditação (a tela já tem o título)', (tester) async {
    await _mostrar(tester, const Passo.meditacao(1));
    expect(find.text('1ª Alegria · A Anunciação'), findsNothing);
  });

  testWidgets('não aparece nas orações iniciais', (tester) async {
    await _mostrar(tester, const Passo.oracao(OracaoIds.credo));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('não aparece nas Ave-Marias extras (sem alegria)', (tester) async {
    await _mostrar(tester, const Passo.aveMaria(contador: 1, total: 3));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('alegria que não existe no conteúdo não quebra a tela',
      (tester) async {
    await _mostrar(tester, const Passo.oracao(OracaoIds.paiNosso, alegriaId: 5));
    expect(find.byType(Text), findsNothing);
  });

  test('em todo o terço, só os passos das dezenas (menos a meditação) têm faixa',
      () {
    final conteudo = Conteudo(
      oracoes: const {},
      alegrias: {
        for (var i = 1; i <= 7; i++)
          i: Alegria(
            id: i,
            titulo: 'Alegria $i',
            referencia: 'x',
            trechoBiblico: 'x',
            reflexao: 'x',
          ),
      },
    );
    final passos = construirTerco();
    final comFaixa = passos
        .where((p) => FaixaDaAlegria.textoDoPasso(p, conteudo) != null)
        .length;
    final dosDezenas = passos
        .where((p) => p.alegriaId != null && p.tipo != TipoPasso.meditacao)
        .length;
    expect(comFaixa, dosDezenas);
    expect(comFaixa, 7 * 12); // Pai-Nosso + 10 Ave-Marias + Glória, 7 vezes
  });
}
