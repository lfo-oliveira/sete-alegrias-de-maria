import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/application/lembretes_controller.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/domain/lembrete.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/presentation/editor_lembrete.dart';

/// Tela de lembretes: o fixo da Hora da Ave-Maria e os do terço,
/// que o fiel cria no horário que quiser.
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

            // ---- Seus lembretes do terço ----
            Text('Hora do terço', style: tema.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Escolha o horário em que você quer ser lembrado de rezar o '
              'terço inteiro.',
              style: tema.bodyLarge,
            ),
            const SizedBox(height: 8),
            if (estado.personalizados.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Você ainda não criou nenhum lembrete do terço.',
                  style: tema.bodyMedium,
                ),
              ),
            for (final lembrete in estado.personalizados)
              _LinhaPersonalizada(lembrete: lembrete),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _adicionar(context, controle),
              icon: const Icon(Icons.add_alarm),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Adicionar lembrete do terço'),
              ),
            ),

            // ---- Hora da Ave-Maria ----
            const SizedBox(height: 32),
            Text('A Hora da Ave-Maria', style: tema.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Antigamente, ao toque do sino, os trabalhadores paravam ao '
              'meio-dia e ao entardecer para rezar uma Ave-Maria. Algumas '
              'rádios antigas fazem isso até hoje. Receba um aviso '
              'nesses horários e faça essa pausa com Maria.',
              style: tema.bodyLarge,
            ),
            const SizedBox(height: 8),
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

  Future<void> _adicionar(
    BuildContext context,
    LembretesController controle,
  ) async {
    final resultado = await mostrarEditorLembrete(context);
    if (resultado == null || resultado.excluir) return;
    await controle.adicionar(
      hora: resultado.hora,
      minuto: resultado.minuto,
      dias: resultado.dias,
    );
  }
}

class _LinhaPersonalizada extends ConsumerWidget {
  const _LinhaPersonalizada({required this.lembrete});

  final Lembrete lembrete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context).textTheme;
    final controle = ref.read(lembretesProvider.notifier);

    return Card(
      child: ListTile(
        onTap: () => _editar(context, controle),
        title: Text(lembrete.horario, style: tema.headlineSmall),
        subtitle: Text(lembrete.descricao),
        trailing: Switch(
          value: lembrete.ativo,
          onChanged: (valor) => controle.alternar(lembrete.id, valor),
        ),
      ),
    );
  }

  Future<void> _editar(
    BuildContext context,
    LembretesController controle,
  ) async {
    final resultado = await mostrarEditorLembrete(context, atual: lembrete);
    if (resultado == null) return;
    if (resultado.excluir) {
      await controle.remover(lembrete.id);
    } else {
      await controle.editar(
        lembrete.id,
        hora: resultado.hora,
        minuto: resultado.minuto,
        dias: resultado.dias,
      );
    }
  }
}
