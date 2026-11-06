import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';

/// Controla o idioma selecionado para as orações e o app.
class IdiomaController extends Notifier<String> {
  @override
  String build() {
    return ref.watch(configuracoesRepositoryProvider).lerIdioma();
  }

  Future<void> definirIdioma(String idioma) async {
    state = idioma;
    await ref.read(configuracoesRepositoryProvider).salvarIdioma(idioma);
  }
}

final idiomaProvider =
    NotifierProvider<IdiomaController, String>(IdiomaController.new);
