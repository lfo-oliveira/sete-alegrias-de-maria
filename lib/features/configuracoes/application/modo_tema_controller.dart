import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sete_alegrias_de_maria/data/repositories/configuracoes_repository.dart';

/// Controla a escolha de tema do fiel (Claro, Escuro ou Automático do sistema).
class ModoTemaController extends Notifier<ThemeMode> {
  ConfiguracoesRepository get _config =>
      ref.read(configuracoesRepositoryProvider);

  @override
  ThemeMode build() => _config.lerModoTema();

  void definir(ThemeMode modo) {
    if (modo == state) return;
    state = modo;
    unawaited(_config.salvarModoTema(modo));
  }
}

final modoTemaProvider = NotifierProvider<ModoTemaController, ThemeMode>(
  ModoTemaController.new,
);