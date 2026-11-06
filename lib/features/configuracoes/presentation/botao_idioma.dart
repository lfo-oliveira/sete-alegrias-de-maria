import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';

/// Informação de exibição de cada opção de idioma.
class OpcaoIdioma {
  const OpcaoIdioma({
    required this.locale,
    required this.nomeNativo,
    required this.detalhe,
  });

  /// Nulo representa o padrão do sistema operacional.
  final Locale? locale;
  final String nomeNativo;
  final String detalhe;
}

const opcoesDeIdioma = <OpcaoIdioma>[
  OpcaoIdioma(
    locale: null,
    nomeNativo: 'Padrão do sistema',
    detalhe: 'Detecta automaticamente o idioma do celular',
  ),
  OpcaoIdioma(
    locale: Locale('pt'),
    nomeNativo: 'Português',
    detalhe: 'Português (Brasil)',
  ),
  OpcaoIdioma(
    locale: Locale('es'),
    nomeNativo: 'Español',
    detalhe: 'Corona Franciscana',
  ),
  OpcaoIdioma(
    locale: Locale('en'),
    nomeNativo: 'English',
    detalhe: 'The Franciscan Crown',
  ),
  OpcaoIdioma(
    locale: Locale('it'),
    nomeNativo: 'Italiano',
    detalhe: 'Corona Francescana',
  ),
  OpcaoIdioma(
    locale: Locale('la'),
    nomeNativo: 'Latina',
    detalhe: 'Corona Septem Gaudiorum B.V.M.',
  ),
];

/// Botão na AppBar para alternar o idioma do aplicativo e das orações.
class BotaoIdioma extends ConsumerWidget {
  const BotaoIdioma({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idiomaAtual = ref.watch(idiomaControllerProvider);

    return IconButton(
      tooltip: 'Idioma / Language',
      icon: const Icon(Icons.translate_outlined),
      onPressed: () => _mostrarOpcoes(context, ref, idiomaAtual),
    );
  }

  void _mostrarOpcoes(
    BuildContext context,
    WidgetRef ref,
    Locale? atual,
  ) {
    final tema = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Idioma / Language', style: tema.titleLarge),
              const SizedBox(height: 12),
              for (final opcao in opcoesDeIdioma)
                ListTile(
                  title: Text(opcao.nomeNativo),
                  subtitle: Text(opcao.detalhe),
                  selected: opcao.locale?.languageCode == atual?.languageCode,
                  trailing: opcao.locale?.languageCode == atual?.languageCode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    ref
                        .read(idiomaControllerProvider.notifier)
                        .definirIdioma(opcao.locale);
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
