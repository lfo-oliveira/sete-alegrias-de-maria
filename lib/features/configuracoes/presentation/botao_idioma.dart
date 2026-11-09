import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';
import 'package:sete_alegrias_de_maria/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final idiomasComAudio = ref.watch(idiomasComAudioProvider);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Idioma / Language', style: tema.titleLarge),
              const SizedBox(height: 12),
              for (final opcao in opcoesDeIdioma)
                _ItemOpcaoIdioma(
                  opcao: opcao,
                  selecionado: opcao.locale?.languageCode == atual?.languageCode,
                  temAudio: idiomasComAudio.contains(
                    opcao.locale?.languageCode ??
                        PlatformDispatcher.instance.locale.languageCode,
                  ),
                  tooltipAudio: l10n?.audioDisponivel ?? 'Áudio disponível',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref
                        .read(idiomaControllerProvider.notifier)
                        .definirIdioma(opcao.locale);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemOpcaoIdioma extends StatelessWidget {
  const _ItemOpcaoIdioma({
    required this.opcao,
    required this.selecionado,
    required this.temAudio,
    required this.tooltipAudio,
    required this.onTap,
  });

  final OpcaoIdioma opcao;
  final bool selecionado;
  final bool temAudio;
  final String tooltipAudio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(opcao.nomeNativo)),
          if (temAudio) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: tooltipAudio,
              child: Icon(
                Icons.volume_up_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(opcao.detalhe),
      selected: selecionado,
      trailing: selecionado ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
