import 'package:sete_alegrias_de_maria/features/backup/data/arquivo_de_backup.dart';
import 'dart:ui';
/// Arquivo de mentira para os testes de backup.
class ArquivoFalso implements ArquivoDeBackup {
  ArquivoFalso({this.paraLer});

  /// Texto que "o fiel escolheu" ao restaurar (null = cancelou).
  String? paraLer;

  String? nomeCompartilhado;
  String? conteudoCompartilhado;

  @override
  Future<void> compartilhar({
    required String nome,
    required String conteudo,
    Rect? origem, // <-- Adicione aqui
  }) async {
    nomeCompartilhado = nome;
    conteudoCompartilhado = conteudo;
  }

  @override
  Future<String?> escolherELer() async => paraLer;
}
