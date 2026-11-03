import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/audio/presentation/controles_audio.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/faixa_da_alegria.dart';

/// Tela de oração: mostra o passo atual e os botões Voltar / Próxima.
class TercoPage extends ConsumerWidget {
  const TercoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conteudo = ref.watch(conteudoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sete Alegrias de Nossa Senhora'),
        actions: const [BotaoTamanhoLetra()],
      ),
      body: conteudo.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (erro, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Não foi possível carregar as orações.\n$erro'),
          ),
        ),
        data: (dados) => _Corpo(conteudo: dados),
      ),
    );
  }
}

class _Corpo extends ConsumerWidget {
  const _Corpo({required this.conteudo});

  final Conteudo conteudo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(tercoControllerProvider);
    final controle = ref.read(tercoControllerProvider.notifier);

    return Column(
      children: [
        LinearProgressIndicator(value: estado.progresso),
        FaixaDaAlegria(passo: estado.passoAtual, conteudo: conteudo),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(estado.indice), // <-- Adicione esta linha
            padding: const EdgeInsets.all(24),
            child: _ConteudoDoPasso(passo: estado.passoAtual, conteudo: conteudo),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ControlesAudio(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: estado.ehPrimeiro ? null : controle.voltar,
                        child: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: estado.ehUltimo
                            ? () {
                                final mensagens = ScaffoldMessenger.of(context);
                                controle.concluir();
                                Navigator.of(context).pop();
                                mensagens.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Terço concluído. Deus te abençoe! 🙏',
                                    ),
                                  ),
                                );
                              }
                            : controle.avancar,
                        child: Text(estado.ehUltimo ? 'Concluir' : 'Próxima'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Decide o que desenhar conforme o tipo do passo.
class _ConteudoDoPasso extends StatelessWidget {
  const _ConteudoDoPasso({required this.passo, required this.conteudo});

  final Passo passo;
  final Conteudo conteudo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    switch (passo.tipo) {
      case TipoPasso.meditacao:
        final alegria = conteudo.alegrias[passo.alegriaId];
        if (alegria == null) {
          return _Aviso('Alegria ${passo.alegriaId} não encontrada');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${alegria.id}ª Alegria', style: tema.titleMedium),
            const SizedBox(height: 4),
            Text(alegria.titulo, style: tema.headlineMedium),
            const SizedBox(height: 4),
            Text(alegria.referencia, style: tema.titleSmall),
            const SizedBox(height: 20),
            // Trecho vazio no JSON: fica só a referência acima.
            if (alegria.trechoBiblico.isNotEmpty) ...[
              Text(alegria.trechoBiblico, style: tema.titleLarge),
              const SizedBox(height: 20),
            ],
            Text(alegria.reflexao, style: tema.bodyLarge),
          ],
        );

      case TipoPasso.oracao:
      case TipoPasso.aveMaria:
        final oracao = conteudo.oracoes[passo.oracaoId];
        if (oracao == null) {
          return _Aviso('Oração "${passo.oracaoId}" não encontrada');
        }
        final ehAveMaria = passo.tipo == TipoPasso.aveMaria;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ehAveMaria)
              Text(
                '${passo.contador} de ${passo.total}',
                style: tema.displaySmall,
              ),
            Text(oracao.titulo, style: tema.headlineMedium),
            const SizedBox(height: 20),
            Text(oracao.texto, style: tema.titleLarge),
          ],
        );
    }
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.mensagem);

  final String mensagem;

  @override
  Widget build(BuildContext context) => Text(mensagem);
}
