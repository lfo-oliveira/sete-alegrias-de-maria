import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/backup/application/backup_controller.dart';
import 'package:sete_alegrias_de_maria/features/backup/data/arquivo_de_backup.dart';
import 'package:sete_alegrias_de_maria/features/backup/data/backup_service.dart';
import 'package:sete_alegrias_de_maria/features/historico/application/historico_controller.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/agendador_lembretes.dart';

import 'helpers/agendador_falso.dart';
import 'helpers/arquivo_falso.dart';

final _agora = DateTime(2026, 10, 17, 10);

const _dadosCompletos = <String, Object>{
  'terco.indice_atual': 12,
  'historico.tercos_rezados': 5,
  'historico.sequencia': 3,
  'historico.ultimo_dia': '2026-10-17',
  'historico.dias_rezados': ['2026-10-15', '2026-10-16', '2026-10-17'],
  'config.tamanho_letra': 'grande',
  'config.idioma': 'es',
  'lembretes.ativo.1': true,
  'lembretes.ativo.2': false,
};

Future<SharedPreferences> _prefs(Map<String, Object> valores) async {
  SharedPreferences.setMockInitialValues(valores);
  return SharedPreferences.getInstance();
}

String _backupCom(Map<String, Object?> dados, {Object? versao = 1}) =>
    jsonEncode({'app': BackupService.app, 'versao': versao, 'dados': dados});

void main() {
  group('BackupService', () {
    test('gerar e restaurar devolve exatamente os mesmos dados', () async {
      final origem = BackupService(await _prefs(_dadosCompletos));
      final texto = origem.gerar(_agora);

      final prefsDestino = await _prefs({'historico.tercos_rezados': 99});
      await BackupService(prefsDestino).restaurar(texto);

      expect(prefsDestino.getInt('terco.indice_atual'), 12);
      expect(prefsDestino.getInt('historico.tercos_rezados'), 5);
      expect(prefsDestino.getInt('historico.sequencia'), 3);
      expect(prefsDestino.getString('historico.ultimo_dia'), '2026-10-17');
      expect(prefsDestino.getStringList('historico.dias_rezados'),
          ['2026-10-15', '2026-10-16', '2026-10-17']);
      expect(prefsDestino.getString('config.tamanho_letra'), 'grande');
      expect(prefsDestino.getString('config.idioma'), 'es');
      expect(prefsDestino.getBool('lembretes.ativo.2'), false);
    });

    test('o backup não leva dados que não são do app', () async {
      final texto = BackupService(
        await _prefs({..._dadosCompletos, 'outra.coisa': 'segredo'}),
      ).gerar(_agora);
      expect(texto.contains('segredo'), isFalse);
    });

    test('restaurar apaga o que não está no backup', () async {
      final prefs = await _prefs({'historico.sequencia': 7});
      await BackupService(prefs).restaurar(
        _backupCom({'historico.tercos_rezados': 2}),
      );
      expect(prefs.containsKey('historico.sequencia'), isFalse);
      expect(prefs.getInt('historico.tercos_rezados'), 2);
    });

    test('texto que não é JSON é recusado e nada muda', () async {
      final prefs = await _prefs({'historico.tercos_rezados': 4});
      await expectLater(
        BackupService(prefs).restaurar('isto não é um backup'),
        throwsA(isA<BackupInvalido>()),
      );
      expect(prefs.getInt('historico.tercos_rezados'), 4);
    });

    test('JSON de outro app é recusado', () async {
      final prefs = await _prefs({'historico.tercos_rezados': 4});
      await expectLater(
        BackupService(prefs).restaurar(jsonEncode({'app': 'outro', 'versao': 1})),
        throwsA(isA<BackupInvalido>()),
      );
      expect(prefs.getInt('historico.tercos_rezados'), 4);
    });

    test('backup de versão mais nova é recusado', () async {
      final prefs = await _prefs({});
      await expectLater(
        BackupService(prefs).restaurar(_backupCom({}, versao: 99)),
        throwsA(isA<BackupInvalido>()),
      );
    });

    test('dado com tipo errado é recusado e nada muda', () async {
      final prefs = await _prefs({'historico.tercos_rezados': 4});
      await expectLater(
        BackupService(prefs).restaurar(_backupCom({
          'historico.tercos_rezados': 10,
          'historico.ultimo_dia': 'ontem',
        })),
        throwsA(isA<BackupInvalido>()),
      );
      expect(prefs.getInt('historico.tercos_rezados'), 4);
    });

    test('chaves desconhecidas no arquivo são ignoradas', () async {
      final prefs = await _prefs({});
      await BackupService(prefs).restaurar(_backupCom({
        'historico.tercos_rezados': 3,
        'qualquer.outra': 'x',
      }));
      expect(prefs.getInt('historico.tercos_rezados'), 3);
      expect(prefs.containsKey('qualquer.outra'), isFalse);
    });
  });

  group('BackupAcoes', () {
    Future<(ProviderContainer, ArquivoFalso)> montar(
      Map<String, Object> salvos, {
      String? arquivoEscolhido,
    }) async {
      final prefs = await _prefs(salvos);
      final arquivo = ArquivoFalso(paraLer: arquivoEscolhido);
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        arquivoDeBackupProvider.overrideWithValue(arquivo),
        agendadorLembretesProvider.overrideWithValue(AgendadorFalso()),
        relogioProvider.overrideWithValue(() => _agora),
      ]);
      addTearDown(container.dispose);
      return (container, arquivo);
    }

    test('exportar compartilha um arquivo com nome da data', () async {
      final (container, arquivo) = await montar(_dadosCompletos);
      final resultado = await container.read(backupAcoesProvider).exportar();

      expect(resultado.sucesso, isTrue);
      expect(arquivo.nomeCompartilhado, 'backup-sete-alegrias-2026-10-17.json');
      expect(arquivo.conteudoCompartilhado, contains('historico.tercos_rezados": 5'));
    });

    test('restaurar atualiza o histórico que a tela mostra', () async {
      final (container, _) = await montar(
        {},
        arquivoEscolhido: _backupCom({
          'historico.tercos_rezados': 8,
          'historico.sequencia': 2,
          'historico.ultimo_dia': '2026-10-17',
        }),
      );
      expect(container.read(historicoProvider).tercosRezados, 0);

      final resultado = await container.read(backupAcoesProvider).restaurar();

      expect(resultado!.sucesso, isTrue);
      expect(container.read(historicoProvider).tercosRezados, 8);
    });

    test('cancelar a escolha do arquivo não faz nada', () async {
      final (container, _) = await montar({'historico.tercos_rezados': 3});
      final resultado = await container.read(backupAcoesProvider).restaurar();
      expect(resultado, isNull);
      expect(container.read(historicoProvider).tercosRezados, 3);
    });

    test('arquivo inválido mostra mensagem e mantém os dados', () async {
      final (container, _) = await montar(
        {'historico.tercos_rezados': 3},
        arquivoEscolhido: 'lixo',
      );
      final resultado = await container.read(backupAcoesProvider).restaurar();
      expect(resultado!.sucesso, isFalse);
      expect(container.read(historicoProvider).tercosRezados, 3);
    });
  });
}
