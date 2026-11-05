import 'package:flutter/material.dart';

/// Mostrador visual das contas da dezena (estilo contas de terço franciscano).
class IndicadorContas extends StatelessWidget {
  const IndicadorContas({
    super.key,
    required this.atual,
    required this.total,
  });

  final int atual;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: 'Ave-Maria $atual de $total',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$atual de $total',
              style: tema.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cores.primary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 1; i <= total; i++)
                  _Conta(
                    rezada: i < atual,
                    atual: i == atual,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Conta extends StatelessWidget {
  const _Conta({
    required this.rezada,
    required this.atual,
  });

  final bool rezada;
  final bool atual;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: atual ? 24 : 18,
      height: atual ? 24 : 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (rezada || atual) ? cores.primary : cores.surfaceContainerHighest,
        border: Border.all(
          color: atual ? cores.primary : (rezada ? cores.primary : cores.outlineVariant),
          width: atual ? 2.5 : 1.5,
        ),
        boxShadow: atual
            ? [
                BoxShadow(
                  color: cores.primary.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: rezada
          ? Icon(Icons.check, size: 12, color: cores.onPrimary)
          : null,
    );
  }
}