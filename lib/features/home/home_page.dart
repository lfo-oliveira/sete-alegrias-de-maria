import 'package:flutter/material.dart';
import 'package:sete_alegrias_de_maria/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n?.lembretes ?? 'Lembretes',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LembretesPage()),
            ),
          ),
          IconButton(
            tooltip: l10n?.backup ?? 'Backup',
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
                  l10n?.tituloApp ?? 'Sete Alegrias de Nossa Senhora',
                  style: tema.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.subtituloApp ?? 'Terço da Coroa Franciscana',
                  style: tema.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (terco.emAndamento) ...[
                  Text(
                    _descreverOndeParou(terco, context),
                    style: tema.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _abrirTerco(context),
                    child: _TextoBotao(l10n?.continuarOndeParei ?? 'Continuar de onde parei'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _confirmarERecomencar(context, ref),
                    child: _TextoBotao(l10n?.comecarDeNovo ?? 'Começar de novo'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => _abrirTerco(context),
                    child: _TextoBotao(l10n?.rezarTerco ?? 'Rezar o terço'),
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
    final l10n = AppLocalizations.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.dialogRecomecarTitulo ?? 'Recomeçar o terço?'),
        content: Text(
          l10n?.dialogRecomecarConteudo ??
              'O progresso salvo até aqui será apagado e você voltará ao início.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancelar ?? 'Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.recomecar ?? 'Recomeçar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      ref.read(tercoControllerProvider.notifier).reiniciar();
      _abrirTerco(context);
    }
  }

  String _descreverOndeParou(TercoState terco, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alegria = terco.passoAtual.alegriaId;
    if (alegria == null) return l10n?.parouNasOracoes ?? 'Você parou nas orações.';
    return l10n?.parouNaAlegria(alegria) ?? 'Você parou na $alegriaª alegria.';
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
