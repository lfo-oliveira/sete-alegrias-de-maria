import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/backup/application/backup_controller.dart';

/// Tela para guardar e recuperar o histórico e as escolhas do fiel.
class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Guarde o seu caminho de oração', style: tema.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Seus dados ficam só neste celular. Se você trocar de aparelho '
              'ou desinstalar o app, eles se perdem. Gere um backup e guarde o '
              'arquivo onde quiser (Drive, e-mail, WhatsApp). Depois é só '
              'restaurar.',
              style: tema.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'O backup guarda: terços rezados, dias seguidos, calendário, '
              'onde você parou, tamanho da letra e lembretes.',
              style: tema.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _exportar(context, ref),
              icon: const Icon(Icons.upload_file),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Gerar backup'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _restaurar(context, ref),
              icon: const Icon(Icons.download),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Restaurar de um arquivo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportar(BuildContext context, WidgetRef ref) async {
    final box = context.findRenderObject() as RenderBox?;
    final origem = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    final resultado = await ref.read(backupAcoesProvider).exportar(origem: origem);
    if (context.mounted) _avisar(context, resultado);
  }

  Future<void> _restaurar(BuildContext context, WidgetRef ref) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Restaurar backup?'),
        content: const Text(
          'Os dados que estão neste celular serão substituídos pelos do '
          'arquivo escolhido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Escolher arquivo'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    final resultado = await ref.read(backupAcoesProvider).restaurar();
    if (resultado != null && context.mounted) _avisar(context, resultado);
  }

  void _avisar(BuildContext context, ResultadoBackup resultado) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado.mensagem)),
    );
  }
}
