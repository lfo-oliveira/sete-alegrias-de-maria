import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/features/backup/data/arquivo_de_backup.dart';
import 'package:sete_alegrias_de_maria/features/backup/data/backup_service.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/tamanho_letra_controller.dart';
import 'package:sete_alegrias_de_maria/features/historico/application/historico_controller.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';

/// Resultado de uma ação de backup, pronto para mostrar ao fiel.
class ResultadoBackup {
  const ResultadoBackup(this.mensagem, {this.sucesso = true});

  final String mensagem;
  final bool sucesso;
}

/// Orquestra exportar e restaurar. A tela só chama e mostra a mensagem.
class BackupAcoes {
  BackupAcoes(this._ref);

  final Ref _ref;

  Future<ResultadoBackup> exportar() async {
    try {
      final agora = _ref.read(relogioProvider)();
      final texto = _ref.read(backupServiceProvider).gerar(agora);
      final data = '${agora.year}-${_dois(agora.month)}-${_dois(agora.day)}';
      await _ref.read(arquivoDeBackupProvider).compartilhar(
            nome: 'backup-sete-alegrias-$data.json',
            conteudo: texto,
          );
      return const ResultadoBackup('Backup gerado. Guarde o arquivo com carinho.');
    } catch (_) {
      return const ResultadoBackup(
        'Não foi possível gerar o backup. Tente de novo.',
        sucesso: false,
      );
    }
  }

  /// Devolve null se o fiel cancelou a escolha do arquivo.
  Future<ResultadoBackup?> restaurar() async {
    try {
      final texto = await _ref.read(arquivoDeBackupProvider).escolherELer();
      if (texto == null) return null;

      await _ref.read(backupServiceProvider).restaurar(texto);

      // Faz as telas lerem de novo os dados que acabaram de ser gravados.
      _ref.invalidate(historicoProvider);
      _ref.invalidate(tamanhoLetraProvider);
      _ref.invalidate(tercoControllerProvider);
      _ref.invalidate(lembretesProvider);
      await _ref.read(lembretesProvider.notifier).sincronizar();

      return const ResultadoBackup('Backup restaurado. Deus te abençoe! 🙏');
    } on BackupInvalido catch (erro) {
      return ResultadoBackup(erro.mensagem, sucesso: false);
    } catch (_) {
      return const ResultadoBackup(
        'Não foi possível ler o arquivo. Nada foi alterado.',
        sucesso: false,
      );
    }
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
}

final backupAcoesProvider = Provider<BackupAcoes>((ref) => BackupAcoes(ref));
