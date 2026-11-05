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
// Vibração inteligente ao avançar:
  void _avancarComFeedback(TercoState estado, TercoController controle) {
    if (estado.ehUltimo) return;
    final passo = estado.passoAtual;
    // Se acabou de rezar a 10ª Ave-Maria da dezena (10 de 10):
    if (passo.tipo == TipoPasso.aveMaria && passo.contador == passo.total) {
      HapticFeedback.mediumImpact(); // Vibração dupla/firme: fim da dezena
    } else {
      HapticFeedback.lightImpact(); // Vibração suave de conta de terço
    }
    controle.avancar();
  }

  // Vibração ao voltar:
  void _voltarComFeedback(TercoState estado, TercoController controle) {
    if (estado.ehPrimeiro) return;
    HapticFeedback.selectionClick();
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
        
        // 1. Área central de leitura da oração com detector de gestos (Swipe):
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
                _avancarComFeedback(estado, controle);
              } else if (paraEsquerda) {
                _voltarComFeedback(estado, controle);
              }
              // if (paraDireita) {
              //   // Deslizar para a direita (→) avança para a próxima
              //   if (!estado.ehUltimo) controle.avancar();
              // } else if (paraEsquerda) {
              //   // Deslizar para a esquerda (←) volta para a anterior
              //   if (!estado.ehPrimeiro) controle.voltar();
              // }
              arrastoX = 0;
            },
          //   child: SingleChildScrollView(
          //     key: ValueKey(estado.indice),
          //     padding: const EdgeInsets.all(24),
          //     child: _ConteudoDoPasso(passo: estado.passoAtual, conteudo: conteudo),
          //   ),
          // ),
        // ),
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
                // duration: const Duration(milliseconds: 250),
                // switchInCurve: Curves.easeIn,
                // switchOutCurve: Curves.easeOut,
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
        // 2. Barra inferior com áudio e botões Voltar / Próxima:
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
                        onPressed: estado.ehPrimeiro ? null : () => _voltarComFeedback(estado, controle),                       
                        child: const Text('Voltar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: estado.ehUltimo
                            ? () async{
                                final mensagens = ScaffoldMessenger.of(context);
                                await HapticFeedback.heavyImpact(); // Vibração forte de conclusão
                                await Future<void>.delayed(const Duration(milliseconds: 120)); // Pequena pausa para a vibração ser sentida
                                await HapticFeedback.heavyImpact(); // Segunda vibração forte de conclusão
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
                            : () => _avancarComFeedback(estado, controle),
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
