import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audio_controller.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';

/// Botão Ouvir / Pausar e a chave de "Avanço automático".
/// Só aparece nos passos que têm áudio; sem nenhum MP3 no app, não aparece.
class ControlesAudio extends ConsumerWidget {
  const ControlesAudio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantém o controle de áudio vivo durante toda a tela do terço (inclusive
    // nos passos sem áudio), mas só se houver algum áudio no app.
    final existeAudio =
        ref.watch(audiosDisponiveisProvider).valueOrNull?.isNotEmpty ?? false;
    if (existeAudio) ref.watch(audioControllerProvider);

    final caminho = ref.watch(caminhoDoAudioProvider);
    if (!existeAudio || caminho == null) return const SizedBox.shrink();

    final audio = ref.watch(audioControllerProvider);
    final controle = ref.read(audioControllerProvider.notifier);
    final tema = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap: com letra grande a chave desce para a linha de baixo em vez
          // de estourar a tela.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: controle.alternarTocar,
                icon: Icon(audio.tocando ? Icons.pause : Icons.play_arrow),
                label: Text(audio.tocando ? 'Pausar' : 'Ouvir'),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Limite de largura: em letra enorme o texto quebra em
                  // duas linhas e a chave continua visível.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width - 120,
                    ),
                    child: Text('Avanço automático', style: tema.bodyMedium),
                  ),
                  Switch(
                    value: audio.avancoAutomatico,
                    onChanged: controle.definirAvancoAutomatico,
                  ),
                ],
              ),
            ],
          ),
          if (audio.erro)
            Text(
              'Não foi possível tocar este áudio.',
              style: tema.bodyMedium,
            ),
        ],
      ),
    );
  }
}
