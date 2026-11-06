import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';

/// Controla o idioma ativo do app e das orações (nulo = padrão do sistema).
class IdiomaController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final salvo = ref.watch(configuracoesRepositoryProvider).lerIdioma();
    return salvo != null ? Locale(salvo) : null;
  }

  Future<void> definirIdioma(Locale? locale) async {
    state = locale;
    await ref
        .read(configuracoesRepositoryProvider)
        .salvarIdioma(locale?.languageCode);
  }
}

final idiomaControllerProvider =
    NotifierProvider<IdiomaController, Locale?>(IdiomaController.new);

/// Provider derivado para ler o código do idioma ativo para carregamento de orações (ex: "pt", "es").
/// Se estiver em automático (nulo), usa o idioma do celular do fiel.
final codigoIdiomaProvider = Provider<String>((ref) {
  final locale = ref.watch(idiomaControllerProvider);
  if (locale != null) return locale.languageCode;
  return PlatformDispatcher.instance.locale.languageCode;
});
