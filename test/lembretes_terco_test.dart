import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/backup/data/backup_service.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/agenda.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/dias_semana.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembretes_terco.dart';

import 'helpers/agendador_falso.dart';

// 17/10/2026 é sábado (weekday 6).
final _sabado = DateTime(2026, 10, 17, 9);

Future<(ProviderContainer, AgendadorFalso, SharedPreferences)> _montar({
  Map<String, Object> salvos = const {},
}) async {
  SharedPreferences.setMockInitialValues(salvos);
  final prefs = await SharedPreferences.getInstance();
  final agendador = AgendadorFalso();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    agendadorLembretesProvider.overrideWithValue(agendador),
    relogioProvider.overrideWithValue(() => _sabado),
  ]);
  addTearDown(container.dispose);
  return (container, agendador, prefs);
}

void main() {
  group('dias da semana', () {
    test('descreve os dias de forma curta', () {
      expect(descreverDias(todosOsDias), 'Todos os dias');
      expect(descreverDias({1, 2, 3, 4, 5}), 'De segunda a sexta');
      expect(descreverDias({6, 7}), 'Fins de semana');
      expect(descreverDias({7, 3, 1}), 'Dom, Seg, Qua');
    });
  });

  group('agenda com dias da semana', () {
    test('só agenda nos dias escolhidos', () {
      final segundas = LembretesTerco.criar(
        id: 10,
        hora: 20,
        minuto: 0,
        dias: {DateTime.monday},
      );
      final agenda = calcularAgenda([segundas], _sabado);

      expect(agenda.length, 2); // segundas 19 e 26 de outubro
      expect(agenda.every((n) => n.quando.weekday == DateTime.monday), isTrue);
      expect(agenda.first.quando, DateTime(2026, 10, 19, 20));
    });

    test('mensagens do terço mudam a cada dia', () {
      final todos = LembretesTerco.criar(
        id: 10,
        hora: 20,
        minuto: 0,
        dias: todosOsDias,
      );
      final agenda = calcularAgenda([todos], _sabado);
      for (var i = 1; i < agenda.length; i++) {
        expect(agenda[i].corpo, isNot(agenda[i - 1].corpo));
      }
      expect(agenda.first.titulo, 'Hora do terço');
    });
  });

  group('controller dos lembretes do terço', () {
    test('adicionar cria, salva e agenda', () async {
      final (container, agendador, prefs) = await _montar();
      final controle = container.read(lembretesProvider.notifier);

      await controle.adicionar(hora: 21, minuto: 30, dias: todosOsDias);

      final personalizados = container.read(lembretesProvider).personalizados;
      expect(personalizados.length, 1);
      expect(personalizados.first.horario, '21:30');
      expect(personalizados.first.id, primeiroIdPersonalizado);
      expect(prefs.getString('lembretes.terco'), isNotNull);
      expect(
        agendador.agenda.where((n) => n.titulo == 'Hora do terço'),
        isNotEmpty,
      );
    });

    test('ids dos lembretes novos não se repetem', () async {
      final (container, _, _) = await _montar();
      final controle = container.read(lembretesProvider.notifier);

      await controle.adicionar(hora: 7, minuto: 0, dias: todosOsDias);
      await controle.adicionar(hora: 21, minuto: 0, dias: todosOsDias);

      final ids = container
          .read(lembretesProvider)
          .personalizados
          .map((l) => l.id)
          .toList();
      expect(ids.toSet().length, 2);
    });

    test('notificações do terço não colidem com as da Ave-Maria', () async {
      final (container, agendador, _) = await _montar();
      await container
          .read(lembretesProvider.notifier)
          .adicionar(hora: 21, minuto: 0, dias: todosOsDias);
      await container.read(lembretesProvider.notifier).sincronizar();

      final ids = agendador.agenda.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('editar muda horário e dias', () async {
      final (container, _, _) = await _montar();
      final controle = container.read(lembretesProvider.notifier);
      await controle.adicionar(hora: 21, minuto: 0, dias: todosOsDias);
      final id = container.read(lembretesProvider).personalizados.first.id;

      await controle.editar(id, hora: 6, minuto: 45, dias: {1, 3});

      final editado = container.read(lembretesProvider).personalizados.first;
      expect(editado.horario, '06:45');
      expect(editado.dias, {1, 3});
    });

    test('desligar um lembrete do terço tira da agenda', () async {
      final (container, agendador, _) = await _montar(
        salvos: {'lembretes.ativo.1': false, 'lembretes.ativo.2': false},
      );
      final controle = container.read(lembretesProvider.notifier);
      await controle.adicionar(hora: 21, minuto: 0, dias: todosOsDias);
      final id = container.read(lembretesProvider).personalizados.first.id;
      expect(agendador.agenda, isNotEmpty);

      await controle.alternar(id, false);

      expect(agendador.agenda, isEmpty);
    });

    test('remover apaga o lembrete e a agenda dele', () async {
      final (container, agendador, _) = await _montar(
        salvos: {'lembretes.ativo.1': false, 'lembretes.ativo.2': false},
      );
      final controle = container.read(lembretesProvider.notifier);
      await controle.adicionar(hora: 21, minuto: 0, dias: todosOsDias);
      final id = container.read(lembretesProvider).personalizados.first.id;

      await controle.remover(id);

      expect(container.read(lembretesProvider).personalizados, isEmpty);
      expect(agendador.agenda, isEmpty);
    });

    test('lembra os lembretes criados ao reabrir o app', () async {
      final (primeiro, _, prefs) = await _montar();
      await primeiro
          .read(lembretesProvider.notifier)
          .adicionar(hora: 19, minuto: 15, dias: {2, 4});

      final segundo = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        agendadorLembretesProvider.overrideWithValue(AgendadorFalso()),
        relogioProvider.overrideWithValue(() => _sabado),
      ]);
      addTearDown(segundo.dispose);

      final lembrete = segundo.read(lembretesProvider).personalizados.single;
      expect(lembrete.horario, '19:15');
      expect(lembrete.dias, {2, 4});
    });

    test('dado corrompido no celular não derruba o app', () async {
      final (container, _, _) = await _montar(
        salvos: {'lembretes.terco': 'lixo'},
      );
      expect(container.read(lembretesProvider).personalizados, isEmpty);
    });
  });

  group('backup dos lembretes do terço', () {
    test('vai e volta no backup', () async {
      final (container, _, prefs) = await _montar();
      await container
          .read(lembretesProvider.notifier)
          .adicionar(hora: 18, minuto: 30, dias: {1, 5});

      final texto = BackupService(prefs).gerar(_sabado);

      SharedPreferences.setMockInitialValues({});
      final destino = await SharedPreferences.getInstance();
      await BackupService(destino).restaurar(texto);

      expect(destino.getString('lembretes.terco'), prefs.getString('lembretes.terco'));
    });

    test('lista de lembretes inválida é recusada', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ruim = jsonEncode({
        'app': BackupService.app,
        'versao': 1,
        'dados': {
          'lembretes.terco': jsonEncode([
            {'id': 10, 'hora': 99, 'minuto': 0, 'dias': [1], 'ativo': true},
          ]),
        },
      });
      await expectLater(
        BackupService(prefs).restaurar(ruim),
        throwsA(isA<BackupInvalido>()),
      );
    });
  });
}
