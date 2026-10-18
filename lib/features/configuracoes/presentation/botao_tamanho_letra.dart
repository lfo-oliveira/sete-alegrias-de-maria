import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/models/tamanho_letra.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/tamanho_letra_controller.dart';

/// Botão "Aa" que abre o painel para escolher o tamanho da letra.
/// Pode ser colocado em qualquer AppBar (actions).
class BotaoTamanhoLetra extends StatelessWidget {
  const BotaoTamanhoLetra({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Tamanho da letra',
      icon: const Text(
        'Aa',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => const _PainelTamanhoLetra(),
      ),
    );
  }
}

class _PainelTamanhoLetra extends ConsumerWidget {
  const _PainelTamanhoLetra();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = ref.watch(tamanhoLetraProvider);
    final tema = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tamanho da letra', style: tema.titleLarge),
            const SizedBox(height: 8),
            for (final tamanho in TamanhoLetra.values)
              ListTile(
                title: Text(tamanho.rotulo),
                selected: tamanho == atual,
                trailing: tamanho == atual ? const Icon(Icons.check) : null,
                onTap: () =>
                    ref.read(tamanhoLetraProvider.notifier).definir(tamanho),
              ),
            const Divider(),
            // Prévia: muda na hora, junto com a escolha.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Ave, Maria, cheia de graça, o Senhor é convosco.',
                style: tema.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
