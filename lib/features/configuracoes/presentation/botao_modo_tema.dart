import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/modo_tema_controller.dart';

/// Botão na AppBar para alternar entre tema Claro, Escuro e Automático.
class BotaoModoTema extends ConsumerWidget {
  const BotaoModoTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(modoTemaProvider);

    final IconData icone;
    final String dica;

    switch (modo) {
      case ThemeMode.light:
        icone = Icons.light_mode_outlined;
        dica = 'Tema claro ativo';
      case ThemeMode.dark:
        icone = Icons.dark_mode_outlined;
        dica = 'Tema escuro ativo';
      case ThemeMode.system:
        icone = Icons.brightness_auto_outlined;
        dica = 'Tema do sistema';
    }

    return IconButton(
      tooltip: dica,
      icon: Icon(icone),
      onPressed: () => _mostrarOpcoes(context, ref),
    );
  }

  void _mostrarOpcoes(BuildContext context, WidgetRef ref) {
    final atual = ref.read(modoTemaProvider);
    final tema = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aparência', style: tema.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.brightness_auto_outlined),
                title: const Text('Padrão do sistema'),
                selected: atual == ThemeMode.system,
                trailing: atual == ThemeMode.system ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(modoTemaProvider.notifier).definir(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text('Tema claro'),
                selected: atual == ThemeMode.light,
                trailing: atual == ThemeMode.light ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(modoTemaProvider.notifier).definir(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Tema escuro'),
                selected: atual == ThemeMode.dark,
                trailing: atual == ThemeMode.dark ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(modoTemaProvider.notifier).definir(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}