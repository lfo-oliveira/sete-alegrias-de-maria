import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_padrao.dart';

import 'helpers/agendador_falso.dart';

Future<(ProviderContainer, AgendadorFalso)> _montar({
  Map<String, Object> salvos = const {},
  DateTime? agora,
  bool permitir = true,
}) async {
  SharedPreferences.setMockInitialValues(salvos);
  final prefs = await SharedPreferences.getInstance();
  final agendador = AgendadorFalso(permitir: permitir);
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    agendadorLembretesProvider.overrideWithValue(agendador),
    relogioProvider.overrideWithValue(() => agora ?? DateTime(2026, 10, 17, 9)),
  ]);
  addTearDown(container.dispose);
  return (container, agendador);
}

void main() {
  group('mensagens', () {
    test('dias seguidos têm mensagens diferentes', () {
      for (final lembrete in LembretesPadrao.todos) {
        for (var d = 0; d < 60; d++) {
          final dia = DateTime(2026, 10, 1 + d);
          final proximo = DateTime(2026, 10, 2 + d);
          expect(
            mensagemDoDia(lembrete, dia),
            isNot(mensagemDoDia(lembrete, proximo)),
          );
        }
      }
    });

    test('os lembretes padrão são às 12:00 e às 18:00', () {
      expect(LembretesPadrao.meioDia.horario, '12:00');
      expect(LembretesPadrao.entardecer.horario, '18:00');
    });
  });

  group('agenda', () {
    test('de manhã agenda hoje e os próximos dias, 12h e 18h', () {
      final agenda = calcularAgenda(
        LembretesPadrao.todos,
        DateTime(2026, 10, 17, 9),
      );
      expect(agenda.length, 2 * diasAgendados);
      expect(agenda.first.quando, DateTime(2026, 10, 17, 12));
    });

    test('não agenda horário que já passou hoje', () {
      final agenda = calcularAgenda(
        LembretesPadrao.todos,
        DateTime(2026, 10, 17, 13),
      );
      // Hoje só falta o das 18h; o das 12h começa amanhã.
      expect(agenda.length, 2 * diasAgendados - 1);
      expect(agenda.first.quando, DateTime(2026, 10, 17, 18));
    });

    test('lembrete desligado não entra na agenda', () {
      final agenda = calcularAgenda(
        [
          LembretesPadrao.meioDia.copyWith(ativo: false),
          LembretesPadrao.entardecer,
        ],
        DateTime(2026, 10, 17, 9),
      );
      expect(agenda.every((n) => n.quando.hour == 18), isTrue);
    });

    test('os ids das notificações não se repetem', () {
      final agenda = calcularAgenda(
        LembretesPadrao.todos,
        DateTime(2026, 10, 17, 9),
      );
      expect(agenda.map((n) => n.id).toSet().length, agenda.length);
    });
  });

  group('controller', () {
    test('começa com os dois lembretes ligados', () async {
      final (container, _) = await _montar();
      final estado = container.read(lembretesProvider);
      expect(estado.lembretes.length, 2);
      expect(estado.lembretes.every((l) => l.ativo), isTrue);
    });

    test('sincronizar pede permissão e agenda', () async {
      final (container, agendador) = await _montar();
      await container.read(lembretesProvider.notifier).sincronizar();
      expect(agendador.pedidosDePermissao, 1);
      expect(agendador.agenda, isNotEmpty);
    });

    test('ao voltar para o app só confere a permissão, sem pedir de novo',
        () async {
      final (container, agendador) = await _montar(permitir: false);
      final controle = container.read(lembretesProvider.notifier);
      await controle.sincronizar();
      await controle.sincronizar();
      await controle.sincronizar();
      expect(agendador.pedidosDePermissao, 1);
      expect(agendador.consultasDePermissao, 2);
    });

    test('ligar um lembrete pede a permissão de novo', () async {
      final (container, agendador) = await _montar(
        salvos: {'lembretes.permissao_pedida': true},
      );
      final controle = container.read(lembretesProvider.notifier);
      await controle.alternar(LembretesPadrao.meioDia.id, true);
      expect(agendador.pedidosDePermissao, 1);
    });

    test('desligar um lembrete não pede permissão', () async {
      final (container, agendador) = await _montar(
        salvos: {'lembretes.permissao_pedida': true},
      );
      final controle = container.read(lembretesProvider.notifier);
      await controle.alternar(LembretesPadrao.meioDia.id, false);
      expect(agendador.pedidosDePermissao, 0);
      expect(agendador.agenda, isNotEmpty);
    });

    test('sem permissão não agenda e avisa a tela', () async {
      final (container, agendador) = await _montar(permitir: false);
      await container.read(lembretesProvider.notifier).sincronizar();
      expect(agendador.agenda, isEmpty);
      expect(container.read(lembretesProvider).permissaoNegada, isTrue);
    });

    test('desligar um lembrete tira da agenda e fica salvo', () async {
      final (container, agendador) = await _montar();
      final controle = container.read(lembretesProvider.notifier);
      await controle.alternar(LembretesPadrao.meioDia.id, false);

      expect(agendador.agenda.every((n) => n.quando.hour == 18), isTrue);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getBool('lembretes.ativo.1'), false);
    });

    test('desligar todos limpa a agenda sem pedir permissão', () async {
      final (container, agendador) = await _montar(
        salvos: {'lembretes.ativo.1': false, 'lembretes.ativo.2': false},
      );
      await container.read(lembretesProvider.notifier).sincronizar();
      expect(agendador.agenda, isEmpty);
      expect(agendador.pedidosDePermissao, 0);
    });

    test('lembra o que o fiel desligou ao reabrir o app', () async {
      final (container, _) =
          await _montar(salvos: {'lembretes.ativo.2': false});
      final estado = container.read(lembretesProvider);
      expect(estado.lembretes[0].ativo, isTrue);
      expect(estado.lembretes[1].ativo, isFalse);
    });
  });
}
