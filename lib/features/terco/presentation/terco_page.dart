import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';
import 'package:sete_alegrias_de_maria/features/audio/presentation/controles_audio.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/features/terco/application/terco_controller.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/faixa_da_alegria.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; 
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_modo_tema.dart';
import 'package:sete_alegrias_de_maria/features/terco/presentation/indicador_contas.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/presentation/botao_vibracao.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/vibracao_controller.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';


/// Tela de oração: mostra o passo atual e os botões Voltar / Próxima.
class TercoPage extends ConsumerStatefulWidget {
  const TercoPage({super.key});

  @override
  ConsumerState<TercoPage> createState() => _TercoPageState();
}

class _TercoPageState extends ConsumerState<TercoPage> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Mantém a tela acesa durante toda a oração
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // Libera o desligamento normal de tela ao sair
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = ref.watch(conteudoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sete Alegrias de Nossa Senhora'),
        actions: const [
          BotaoVibracao(),
          BotaoTamanhoLetra(),
          BotaoModoTema(),
        ],
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

  void _avancarComFeedback(
    TercoState estado,
    TercoController controle,
    WidgetRef ref,
  ) {
    if (estado.ehUltimo) return;
    if (ref.read(vibracaoProvider)) {
      final passo = estado.passoAtual;
      if (passo.tipo == TipoPasso.aveMaria && passo.contador == passo.total) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    controle.avancar();
  }

  void _voltarComFeedback(
    TercoState estado,
    TercoController controle,
    WidgetRef ref,
  ) {
    if (estado.ehPrimeiro) return;
    if (ref.read(vibracaoProvider)) {
      HapticFeedback.selectionClick();
    }
    controle.voltar();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(tercoControllerProvider);
    final controle = ref.read(tercoControllerProvider.notifier);
    double arrastoX = 0;

    return Column(
      children: [
        LinearProgressIndicator(value: estado.progresso),
        FaixaDaAlegria(passo: estado.passoAtual, conteudo: conteudo),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => arrastoX = 0,
            onHorizontalDragUpdate: (detalhes) => arrastoX += detalhes.delta.dx,
            onHorizontalDragEnd: (detalhes) {
              final velocidade = detalhes.primaryVelocity ?? 0;
              final paraDireita = arrastoX > 40 || velocidade > 120;
              final paraEsquerda = arrastoX < -40 || velocidade < -120;

              if (paraDireita) {
                _avancarComFeedback(estado, controle, ref);
              } else if (paraEsquerda) {
                _voltarComFeedback(estado, controle, ref);
              }
              arrastoX = 0;
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final deslize = Tween<Offset>(
                  begin: const Offset(-0.25, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: deslize,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: SingleChildScrollView(
                key: ValueKey(estado.indice),
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: _ConteudoDoPasso(
                    passo: estado.passoAtual,
                    conteudo: conteudo,
                  ),
                ),
              ),
            ),
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
                        onPressed: estado.ehPrimeiro
                            ? null
                            : () => _voltarComFeedback(estado, controle, ref),
                        child: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: estado.ehUltimo
                            ? () async {
                                final mensagens = ScaffoldMessenger.of(context);

                                if (ref.read(vibracaoProvider)) {
                                  await HapticFeedback.heavyImpact();
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 120),
                                  );
                                  await HapticFeedback.heavyImpact();
                                }

                                controle.concluir();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  mensagens.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Terço concluído. Deus te abençoe! 🙏',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : () => _avancarComFeedback(estado, controle, ref),
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
/// Decide o que desenhar conforme o tipo do passo.
class _ConteudoDoPasso extends StatelessWidget {
  const _ConteudoDoPasso({required this.passo, required this.conteudo});

  final Passo passo;
  final Conteudo conteudo;

  void _compartilharAlegria(BuildContext context, Alegria alegria) {
    final box = context.findRenderObject() as RenderBox?;
    final origem = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    final texto = [
      '🕊️ Sete Alegrias de Nossa Senhora (Coroa Franciscana)',
      '',
      '${alegria.id}ª Alegria: ${alegria.titulo} (${alegria.referencia})',
      '',
      if (alegria.trechoBiblico.isNotEmpty) ...[
        '"${alegria.trechoBiblico.trim()}"',
        '',
      ],
      'Meditação: ${alegria.reflexao.trim()}',
      '',
      'Reze conosco a Coroa Franciscana no app Sete Alegrias de Maria! 🙏',
    ].join('\n');

    SharePlus.instance.share(
      ShareParams(
        text: texto,
        subject: '${alegria.id}ª Alegria de Maria: ${alegria.titulo}',
        sharePositionOrigin: origem,
      ),
    );
  }

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
            Row(
              children: [
                Expanded(
                  child: Text('${alegria.id}ª Alegria', style: tema.titleMedium),
                ),
                IconButton(
                  tooltip: 'Compartilhar meditação',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _compartilharAlegria(context, alegria),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(alegria.titulo, style: tema.headlineMedium),
            const SizedBox(height: 4),
            Text(alegria.referencia, style: tema.titleSmall),
            const SizedBox(height: 20),
            if (alegria.trechoBiblico.isNotEmpty) ...[
              Text(alegria.trechoBiblico, style: tema.titleLarge),
              const SizedBox(height: 20),
            ],
            Text(alegria.reflexao, style: tema.bodyLarge),
          ],
        );

      // <-- OS DOIS CASES DEVEM ESTAR PRESENTES AQUI:
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
            if (ehAveMaria && passo.contador != null && passo.total != null)
              IndicadorContas(
                atual: passo.contador!,
                total: passo.total!,
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
