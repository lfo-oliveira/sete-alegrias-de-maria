import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/lembretes/data/lembretes_repository.dart';

/// O arquivo escolhido não é um backup válido (ou é de uma versão mais nova).
class BackupInvalido implements Exception {
  const BackupInvalido(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Gera e restaura o backup: um arquivo de texto (JSON) com os dados do fiel.
///
/// Só lê e grava as chaves LISTADAS em [_formatos]. Para incluir um dado novo
/// no backup (ex.: modo escuro manual), acrescente a chave aqui.
/// Chaves desconhecidas dentro de um arquivo de backup são ignoradas.
class BackupService {
  BackupService(this._prefs);

  final SharedPreferences _prefs;

  static const app = 'sete_alegrias_de_maria';
  static const versao = 1;

  static final _data = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Verificação do tipo de cada dado. Garante que um arquivo estranho ou
  /// editado à mão nunca grave algo que faça o app falhar ao abrir.
  static final Map<RegExp, bool Function(Object)> _formatos = {
    RegExp(r'^terco\.indice_atual$'): (v) => v is int && v >= 0,
    RegExp(r'^historico\.tercos_rezados$'): (v) => v is int && v >= 0,
    RegExp(r'^historico\.sequencia$'): (v) => v is int && v >= 0,
    RegExp(r'^historico\.ultimo_dia$'): (v) => v is String && _data.hasMatch(v),
    RegExp(r'^historico\.dias_rezados$'): (v) =>
        v is List && v.every((d) => d is String && _data.hasMatch(d)),
    RegExp(r'^config\.tamanho_letra$'): (v) => v is String,
    RegExp(r'^lembretes\.ativo\.\d+$'): (v) => v is bool,
    RegExp(r'^lembretes\.terco$'): (v) =>
        v is String && LembretesRepository.textoValido(v),
  };

  static bool Function(Object)? _verificador(String chave) {
    for (final entrada in _formatos.entries) {
      if (entrada.key.hasMatch(chave)) return entrada.value;
    }
    return null;
  }

  /// Monta o texto do arquivo de backup.
  String gerar(DateTime agora) {
    final dados = <String, Object>{};
    for (final chave in _prefs.getKeys()) {
      if (_verificador(chave) == null) continue;
      final valor = _prefs.get(chave);
      if (valor == null) continue;
      dados[chave] = valor is List ? valor.cast<String>() : valor;
    }
    return const JsonEncoder.withIndent('  ').convert({
      'app': app,
      'versao': versao,
      'criado_em': agora.toIso8601String(),
      'dados': dados,
    });
  }

  /// Confere o arquivo inteiro ANTES de gravar qualquer coisa.
  /// Se algo estiver errado, lança [BackupInvalido] e nada é alterado.
  Future<void> restaurar(String texto) async {
    final Object? bruto;
    try {
      bruto = jsonDecode(texto);
    } on FormatException {
      throw const BackupInvalido('Este arquivo não é um backup válido.');
    }

    if (bruto is! Map || bruto['app'] != app) {
      throw const BackupInvalido('Este arquivo não é um backup do app.');
    }
    final versaoDoArquivo = bruto['versao'];
    if (versaoDoArquivo is! int) {
      throw const BackupInvalido('Este arquivo não é um backup válido.');
    }
    if (versaoDoArquivo > versao) {
      throw const BackupInvalido(
        'Este backup foi feito por uma versão mais nova do app. '
        'Atualize o app e tente de novo.',
      );
    }

    final dados = bruto['dados'];
    if (dados is! Map) {
      throw const BackupInvalido('Este arquivo não é um backup válido.');
    }

    final aceitos = <String, Object>{};
    for (final entrada in dados.entries) {
      final chave = entrada.key;
      final valor = entrada.value;
      if (chave is! String || valor == null) continue;
      final verificador = _verificador(chave);
      if (verificador == null) continue; // chave desconhecida: ignora
      if (!verificador(valor)) {
        throw const BackupInvalido('O backup tem dados inválidos.');
      }
      aceitos[chave] = valor;
    }

    // Tudo certo: troca os dados atuais pelos do backup.
    for (final chave in _prefs.getKeys().toList()) {
      if (_verificador(chave) != null) await _prefs.remove(chave);
    }
    for (final entrada in aceitos.entries) {
      final valor = entrada.value;
      if (valor is int) {
        await _prefs.setInt(entrada.key, valor);
      } else if (valor is bool) {
        await _prefs.setBool(entrada.key, valor);
      } else if (valor is String) {
        await _prefs.setString(entrada.key, valor);
      } else if (valor is List) {
        await _prefs.setStringList(entrada.key, valor.cast<String>());
      }
    }
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(sharedPreferencesProvider)),
);
