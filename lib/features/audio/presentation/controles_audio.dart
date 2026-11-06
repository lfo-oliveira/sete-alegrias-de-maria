import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audio_controller.dart';
import 'package:sete_alegrias_de_maria/features/audio/application/audios_disponiveis.dart';

/// Botão Ouvir / Pausar, Seletor de Velocidade e chave de "Avanço automático".
class ControlesAudio extends ConsumerWidget {
  const ControlesAudio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existeAudio =
        ref.watch(audiosDisponiveisProvider).valueOrNull?.isNotEmpty ?? false;
    if (existeAudio) ref.watch(audioControllerProvider);

    final caminho = ref.watch(caminhoDoAudioProvider);
    if (!existeAudio || caminho == null) return const SizedBox.shrink();

    final audio = ref.watch(audioControllerProvider);
    final controle = ref.read(audioControllerProvider.notifier);
    final tema = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 1. Botão Ouvir / Pausar
              FilledButton.tonalIcon(
                onPressed: controle.alternarTocar,
                icon: Icon(audio.tocando ? Icons.pause : Icons.play_arrow),
                label: Text(audio.tocando ? 'Pausar' : 'Ouvir'),
              ),
              const SizedBox(width: 8),

              // 2. BOTÃO DE VELOCIDADE (Cápsula com setinha 1.0x ▾):
              PopupMenuButton<double>(
                tooltip: 'Velocidade do áudio',
                initialValue: audio.velocidade,
                onSelected: controle.definirVelocidade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: cores.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cores.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${audio.velocidade}x',
                        style: tema.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cores.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: cores.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0.8, child: Text('0.8x (Mais lento)')),
                  PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                  PopupMenuItem(value: 1.2, child: Text('1.2x (Mais rápido)')),
                ],
              ),

              const Spacer(),

              // 3. Chave Avanço Automático
              Flexible(
                child: Text('Avanço automático', style: tema.bodyMedium),
              ),
              Switch(
                value: audio.avancoAutomatico,
                onChanged: controle.definirAvancoAutomatico,
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