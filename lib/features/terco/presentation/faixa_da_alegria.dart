import 'package:flutter/material.dart';
import 'package:sete_alegrias_de_maria/data/models/passo.dart';
import 'package:sete_alegrias_de_maria/data/repositories/conteudo_repository.dart';

/// Faixa fixa no alto da tela de oração que diz qual alegria (mistério) está
/// sendo rezada, ex.: "1ª Alegria · A Anunciação".
///
/// Aparece no Pai-Nosso, nas Ave-Marias e no Glória de cada dezena. Na
/// meditação ela some, porque a própria tela já mostra o título em destaque.
/// Nas orações iniciais, finais e nas Ave-Marias extras (sem alegria) não
/// aparece.
class FaixaDaAlegria extends StatelessWidget {
  const FaixaDaAlegria({
    super.key,
    required this.passo,
    required this.conteudo,
  });

  final Passo passo;
  final Conteudo conteudo;

  /// Texto da faixa, ou null se este passo não mostra a faixa.
  static String? textoDoPasso(Passo passo, Conteudo conteudo) {
    if (passo.tipo == TipoPasso.meditacao) return null;
    final id = passo.alegriaId;
    if (id == null) return null;
    final alegria = conteudo.alegrias[id];
    if (alegria == null) return null;
    return '${alegria.id}ª Alegria · ${alegria.titulo}';
  }

  @override
  Widget build(BuildContext context) {
    final texto = textoDoPasso(passo, conteudo);
    if (texto == null) return const SizedBox.shrink();

    final cores = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Alegria em oração: $texto',
      child: Container(
        width: double.infinity,
        color: cores.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cores.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
