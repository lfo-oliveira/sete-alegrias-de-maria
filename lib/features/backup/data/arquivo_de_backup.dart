import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Parte do backup que depende do celular: compartilhar e escolher o arquivo.
/// É uma interface para que os testes usem uma versão falsa.
abstract class ArquivoDeBackup {
  /// Abre a folha de compartilhar do celular com o arquivo de backup
  /// (o fiel escolhe: Drive, WhatsApp, e-mail, salvar no aparelho...).
  Future<void> compartilhar({required String nome, required String conteudo});

  /// Deixa o fiel escolher um arquivo e devolve o texto dele,
  /// ou null se ele cancelar.
  Future<String?> escolherELer();
}

final arquivoDeBackupProvider = Provider<ArquivoDeBackup>(
  (ref) => ArquivoDeBackupReal(),
);

class ArquivoDeBackupReal implements ArquivoDeBackup {
  @override
  Future<void> compartilhar({
    required String nome,
    required String conteudo,
  }) async {
    final pasta = await getTemporaryDirectory();
    final arquivo = File('${pasta.path}${Platform.pathSeparator}$nome');
    await arquivo.writeAsString(conteudo);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(arquivo.path, mimeType: 'application/json')],
        subject: 'Backup - Sete Alegrias de Maria',
      ),
    );
  }

  @override
  Future<String?> escolherELer() async {
    final arquivo = await FilePicker.pickFile();
    if (arquivo == null) return null;
    return utf8.decode(await arquivo.readAsBytes());
  }
}
