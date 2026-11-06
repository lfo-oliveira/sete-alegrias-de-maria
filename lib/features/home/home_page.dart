import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/backup/presentation/backup_page.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/features/historico/presentation/cartao_historico.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/presentation/lembretes_page.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/terco_page.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_modo_tema.dart';
/// Tela inicial.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final terco = ref.watch(tercoControllerProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Lembretes',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LembretesPage()),
            ),
          ),
          IconButton(
            tooltip: 'Backup',
            icon: const Icon(Icons.save_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BackupPage()),
            ),
          ),
          const BotaoModoTema(),
          const BotaoTamanhoLetra(),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Rolagem: com letra grande o conteúdo pode passar da tela.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sete Alegrias de Nossa Senhora',
                  style: tema.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Terço da Coroa Franciscana',
                  style: tema.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (terco.emAndamento) ...[
                  Text(
                    _descreverOndeParou(terco),
                    style: tema.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _abrirTerco(context),
                    child: const _TextoBotao('Continuar de onde parei'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _confirmarERecomencar(context, ref),
                    child: const _TextoBotao('Começar de novo'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => _abrirTerco(context),
                    child: const _TextoBotao('Rezar o terço'),
                  ),
                const SizedBox(height: 32),
                const CartaoHistorico(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirTerco(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TercoPage()),
    );
  }
Future<void> _confirmarERecomencar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Começar de novo?'),
        content: const Text(
          'O progresso salvo até aqui será apagado e você voltará ao início.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Começar de novo'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      ref.read(tercoControllerProvider.notifier).reiniciar();
      _abrirTerco(context);
    }
  }
  /// Pergunta antes de apagar o "onde parei": um toque sem querer não
  /// pode fazer o fiel perder o lugar no terço.

  String _descreverOndeParou(TercoState terco) {
    final alegria = terco.passoAtual.alegriaId;
    if (alegria == null) return 'Você parou nas orações.';
    return 'Você parou na $alegriaª alegria.';
  }
}

class _TextoBotao extends StatelessWidget {
  const _TextoBotao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(texto),
      );
}
