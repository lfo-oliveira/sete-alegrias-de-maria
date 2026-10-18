import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';

/// Tela para ligar e desligar os lembretes da Hora da Ave-Maria.
class LembretesPage extends ConsumerWidget {
  const LembretesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final estado = ref.watch(lembretesProvider);
    final controle = ref.read(lembretesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('A Hora da Ave-Maria', style: tema.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Antigamente, ao toque do sino, os trabalhadores paravam ao '
              'meio-dia e ao entardecer para rezar uma Ave-Maria. Algumas '
              'rádios antigas fazem isso até hoje. Receba um aviso '
              'nesses horários e faça essa pausa com Maria.',
              style: tema.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (estado.permissaoNegada)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'As notificações estão desligadas no seu celular. Para '
                    'receber os lembretes, ative as notificações do app '
                    'nas configurações do aparelho.',
                    style: tema.bodyMedium,
                  ),
                ),
              ),
            for (final lembrete in estado.lembretes)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${lembrete.horario} · ${lembrete.titulo}'),
                subtitle: Text(lembrete.descricao),
                value: lembrete.ativo,
                onChanged: (valor) => controle.alternar(lembrete.id, valor),
              ),
          ],
        ),
      ),
    );
  }
}
