import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/app.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/models/historico.dart';
import 'package:sete_alegrias_de_maria/data/repositories/historico_repository.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/historico/domain/semana.dart';

void main() {
  group('diasDaSemana (domingo a sábado)', () {
    test('quinta-feira 15/10/2026: de 11/10 a 17/10', () {
      final dias = diasDaSemana(DateTime(2026, 10, 15, 14, 30));
      expect(dias.length, 7);
      expect(dias.first, DateTime(2026, 10, 11));
      expect(dias.last, DateTime(2026, 10, 17));
    });

    test('domingo é o primeiro dia da semana', () {
      final dias = diasDaSemana(DateTime(2026, 10, 11));
      expect(dias.first, DateTime(2026, 10, 11));
    });

    test('sábado é o último dia da semana', () {
      final dias = diasDaSemana(DateTime(2026, 10, 17));
      expect(dias.first, DateTime(2026, 10, 11));
      expect(dias.last, DateTime(2026, 10, 17));
    });

    test('semana que atravessa dois meses', () {
      final dias = diasDaSemana(DateTime(2026, 9, 30));
      expect(dias.first, DateTime(2026, 9, 27));
      expect(dias.last, DateTime(2026, 10, 3));
    });
  });

  group('Historico.diasRezados', () {
    test('registrar marca o dia e mantém os anteriores', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 13, 9))
          .registrarTerco(DateTime(2026, 10, 15, 21));
      expect(h.rezouNoDia(DateTime(2026, 10, 13)), isTrue);
      expect(h.rezouNoDia(DateTime(2026, 10, 14)), isFalse);
      expect(h.rezouNoDia(DateTime(2026, 10, 15, 3)), isTrue);
    });

    test('dias muito antigos saem da lista, mas os terços continuam contados',
        () {
      final h = const Historico()
          .registrarTerco(DateTime(2024, 1, 1))
          .registrarTerco(DateTime(2026, 10, 15));
      expect(h.rezouNoDia(DateTime(2024, 1, 1)), isFalse);
      expect(h.tercosRezados, 2);
    });
  });

  group('HistoricoRepository (dias rezados)', () {
    test('salva e restaura a lista de dias', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = HistoricoRepository(prefs);

      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 14))
          .registrarTerco(DateTime(2026, 10, 15));
      await repo.salvar(h);

      expect(prefs.getStringList('historico.dias_rezados'),
          ['2026-10-14', '2026-10-15']);

      final lido = repo.ler();
      expect(lido.rezouNoDia(DateTime(2026, 10, 14)), isTrue);
      expect(lido.rezouNoDia(DateTime(2026, 10, 15)), isTrue);
      expect(lido.rezouNoDia(DateTime(2026, 10, 13)), isFalse);
    });

    test('dados antigos (sem lista de dias) ainda marcam o último dia', () async {
      SharedPreferences.setMockInitialValues({
        'historico.tercos_rezados': 1,
        'historico.sequencia': 1,
        'historico.ultimo_dia': '2026-10-14',
      });
      final prefs = await SharedPreferences.getInstance();

      final lido = HistoricoRepository(prefs).ler();
      expect(lido.rezouNoDia(DateTime(2026, 10, 14)), isTrue);
    });
  });

  testWidgets('o calendário da semana marca só os dias rezados desta semana',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'historico.tercos_rezados': 3,
      'historico.sequencia': 2,
      'historico.ultimo_dia': '2026-10-15',
      // 05/10 é de outra semana e não deve aparecer marcado.
      'historico.dias_rezados': ['2026-10-05', '2026-10-14', '2026-10-15'],
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          relogioProvider.overrideWithValue(() => DateTime(2026, 10, 15, 9)),
        ],
        child: const SeteAlegriasApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Esta semana'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });
}
