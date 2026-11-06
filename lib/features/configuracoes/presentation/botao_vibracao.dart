import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/vibracao_controller.dart';

/// Botão na AppBar para alternar rapidamente a vibração das contas.
class BotaoVibracao extends ConsumerWidget {
  const BotaoVibracao({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ativa = ref.watch(vibracaoProvider);
    final controle = ref.read(vibracaoProvider.notifier);

    return IconButton(
      tooltip: ativa ? 'Silenciar vibração' : 'Ativar vibração',
      icon: Icon(ativa ? Icons.vibration : Icons.smartphone),
      onPressed: () {
        controle.alternar();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              !ativa ? 'Vibração nas contas ativada' : 'Vibração silenciada',
            ),
          ),
        );
      },
    );
  }
}