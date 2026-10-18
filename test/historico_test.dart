import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/models/historico.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/historico/application/historico_controller.dart';
import 'package:sete_alegrias_de_maria/features/historico/domain/mensagem_historico.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

void main() {
  group('Historico (regras de contagem)', () {
    test('primeiro terço: 1 terço e 1 dia seguido', () {
      final h = const Historico().registrarTerco(DateTime(2026, 10, 15, 8));
      expect(h.tercosRezados, 1);
      expect(h.diasSeguidos(DateTime(2026, 10, 15, 20)), 1);
    });

    test('dois terços no mesmo dia: conta os terços, não a sequência', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 15, 8))
          .registrarTerco(DateTime(2026, 10, 15, 21));
      expect(h.tercosRezados, 2);
      expect(h.diasSeguidos(DateTime(2026, 10, 15)), 1);
    });

    test('dias consecutivos aumentam a sequência', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 13))
          .registrarTerco(DateTime(2026, 10, 14))
          .registrarTerco(DateTime(2026, 10, 15));
      expect(h.diasSeguidos(DateTime(2026, 10, 15)), 3);
    });

    test('pular um dia reinicia a sequência em 1, sem apagar os terços', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 13))
          .registrarTerco(DateTime(2026, 10, 14))
          .registrarTerco(DateTime(2026, 10, 16));
      expect(h.tercosRezados, 3);
      expect(h.diasSeguidos(DateTime(2026, 10, 16)), 1);
    });

    test('virada de mês conta como dia seguido', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 1, 31))
          .registrarTerco(DateTime(2026, 2, 1));
      expect(h.diasSeguidos(DateTime(2026, 2, 1)), 2);
    });

    test('rezou ontem: a sequência ainda vale hoje', () {
      final h = const Historico()
          .registrarTerco(DateTime(2026, 10, 14))
          .registrarTerco(DateTime(2026, 10, 15));
      expect(h.diasSeguidos(DateTime(2026, 10, 16)), 2);
    });

    test('ficou 2 dias ou mais sem rezar: mostra 0 dias seguidos', () {
      final h = const Historico().registrarTerco(DateTime(2026, 10, 10));
      expect(h.diasSeguidos(DateTime(2026, 10, 15)), 0);
      expect(h.tercosRezados, 1);
    });
  });

  group('mensagemHistorico (acolhedora)', () {
    final hoje = DateTime(2026, 10, 15);

    test('nunca rezou', () {
      expect(mensagemHistorico(const Historico(), hoje), contains('primeiro terço'));
    });

    test('rezou hoje', () {
      final h = const Historico().registrarTerco(hoje);
      expect(mensagemHistorico(h, hoje), contains('já rezou'));
    });

    test('rezou ontem', () {
      final h = const Historico().registrarTerco(DateTime(2026, 10, 14));
      expect(mensagemHistorico(h, hoje), contains('ontem'));
    });

    test('ficou dias sem rezar: acolhe, sem cobrar', () {
      final h = const Historico().registrarTerco(DateTime(2026, 10, 1));
      final msg = mensagemHistorico(h, hoje);
      expect(msg, contains('braços abertos'));
      expect(msg.toLowerCase(), isNot(contains('perdeu')));
      expect(msg.toLowerCase(), isNot(contains('falhou')));
    });
  });

  group('HistoricoController (salvar e restaurar)', () {
    Future<ProviderContainer> criar(
      Map<String, Object> valoresSalvos,
      DateTime agora,
    ) async {
      SharedPreferences.setMockInitialValues(valoresSalvos);
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          relogioProvider.overrideWithValue(() => agora),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('começa zerado', () async {
      final container = await criar({}, DateTime(2026, 10, 15));
      final h = container.read(historicoProvider);
      expect(h.tercosRezados, 0);
      expect(h.ultimoDia, isNull);
    });

    test('registrar salva no celular', () async {
      final container = await criar({}, DateTime(2026, 10, 15, 9));
      final prefs = container.read(sharedPreferencesProvider);

      container.read(historicoProvider.notifier).registrarTercoRezado();
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getInt('historico.tercos_rezados'), 1);
      expect(prefs.getInt('historico.sequencia'), 1);
      expect(prefs.getString('historico.ultimo_dia'), '2026-10-15');
    });

    test('restaura o histórico salvo', () async {
      final container = await criar({
        'historico.tercos_rezados': 7,
        'historico.sequencia': 3,
        'historico.ultimo_dia': '2026-10-14',
      }, DateTime(2026, 10, 15));

      final h = container.read(historicoProvider);
      expect(h.tercosRezados, 7);
      expect(h.diasSeguidos(DateTime(2026, 10, 15)), 3);
    });

    test('concluir o terço soma no histórico e zera o "onde parei"', () async {
      final container = await criar(
        {'terco.indice_atual': 40},
        DateTime(2026, 10, 15),
      );

      container.read(tercoControllerProvider.notifier).concluir();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(historicoProvider).tercosRezados, 1);
      expect(container.read(tercoControllerProvider).indice, 0);
    });
  });
}
