import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/core/utils/relogio.dart';
import 'package:sete_alegrias_de_maria/data/models/historico.dart';
import 'package:sete_alegrias_de_maria/features/historico/application/historico_controller.dart';
import 'package:sete_alegrias_de_maria/features/historico/domain/mensagem_historico.dart';
import 'package:sete_alegrias_de_maria/features/historico/domain/semana.dart';

/// Resumo do histórico para a tela inicial: terços rezados, dias seguidos,
/// calendário da semana e uma mensagem acolhedora.
class CartaoHistorico extends ConsumerWidget {
  const CartaoHistorico({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historico = ref.watch(historicoProvider);
    final agora = ref.watch(relogioProvider)();
    final tema = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Numero(
                    valor: historico.tercosRezados,
                    rotulo: 'Terços rezados',
                  ),
                ),
                Expanded(
                  child: _Numero(
                    valor: historico.diasSeguidos(agora),
                    rotulo: 'Dias seguidos',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Esta semana', style: tema.titleSmall),
            const SizedBox(height: 8),
            _SemanaDeOracao(historico: historico, agora: agora),
            const SizedBox(height: 16),
            Text(
              mensagemHistorico(historico, agora),
              style: tema.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final int valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('$valor', style: tema.headlineMedium),
        Text(rotulo, style: tema.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Calendário da semana: um círculo por dia, marcado se o fiel rezou.
class _SemanaDeOracao extends StatelessWidget {
  const _SemanaDeOracao({required this.historico, required this.agora});

  final Historico historico;
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final hoje = Historico.soData(agora);
    final dias = diasDaSemana(agora);

    return Row(
      children: [
        for (var i = 0; i < dias.length; i++)
          Expanded(
            child: _DiaDaSemana(
              letra: letrasDiasSemana[i],
              nome: nomesDiasSemana[i],
              rezou: historico.rezouNoDia(dias[i]),
              ehHoje: dias[i] == hoje,
              ehFuturo: dias[i].isAfter(hoje),
            ),
          ),
      ],
    );
  }
}

class _DiaDaSemana extends StatelessWidget {
  const _DiaDaSemana({
    required this.letra,
    required this.nome,
    required this.rezou,
    required this.ehHoje,
    required this.ehFuturo,
  });

  final String letra;
  final String nome;
  final bool rezou;
  final bool ehHoje;
  final bool ehFuturo;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    final circulo = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rezou ? cores.primary : null,
        border: Border.all(
          color: ehHoje ? cores.primary : cores.outlineVariant,
          width: ehHoje ? 2.5 : 1,
        ),
      ),
      child: rezou ? Icon(Icons.check, size: 18, color: cores.onPrimary) : null,
    );

    final descricao = [
      nome,
      if (rezou) 'rezou',
      if (ehHoje) 'hoje',
    ].join(', ');

    return Semantics(
      container: true,
      label: descricao,
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(letra, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Opacity(opacity: ehFuturo ? 0.5 : 1, child: circulo),
          ],
        ),
      ),
    );
  }
}
