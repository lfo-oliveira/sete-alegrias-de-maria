import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sete_alegrias_de_maria/data/models/alegria.dart';
import 'package:sete_alegrias_de_maria/data/models/oracao.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_config.dart';
import 'package:sete_alegrias_de_maria/features/terco/domain/terco_sequencia.dart';

/// Confere os textos REAIS de assets/content/, que vão para a Play Store.
void main() {
  const idiomas = ['pt', 'es', 'en', 'la', 'it'];

  for (final idioma in idiomas) {
    group('Conteúdo em $idioma', () {
      Map<String, dynamic> lerJson(String nome) =>
          jsonDecode(File('assets/content/$idioma/$nome').readAsStringSync())
              as Map<String, dynamic>;

      final oracoes = {
        for (final item in lerJson('oracoes.json')['oracoes'] as List<dynamic>)
          Oracao.fromJson(item as Map<String, dynamic>),
      };
      final alegrias = [
        for (final item
            in lerJson('alegrias.json')['alegrias'] as List<dynamic>)
          Alegria.fromJson(item as Map<String, dynamic>),
      ];

      test('toda oração usada no terço existe em oracoes.json ($idioma)', () {
        final ids = oracoes.map((o) => o.id).toSet();
        for (final passo in construirTerco()) {
          final id = passo.oracaoId;
          if (id != null) expect(ids, contains(id), reason: 'falta "$id"');
        }
      });

      test('há uma alegria para cada dezena, com ids de 1 a 7 ($idioma)', () {
        expect(
          alegrias.map((a) => a.id).toList(),
          [for (var i = 1; i <= TercoConfig.totalAlegrias; i++) i],
        );
      });

      test('nenhum texto provisório ou resto de edição ($idioma)', () {
        final textos = [
          for (final o in oracoes) ...[o.titulo, o.texto],
          for (final a in alegrias) ...[
            a.titulo,
            a.referencia,
            a.trechoBiblico,
            a.reflexao,
          ],
        ];
        for (final texto in textos) {
          expect(texto, isNot(contains('A DEFINIR')));
          expect(texto, isNot(matches(RegExp(r'\[\d'))), reason: texto);
          expect(texto, isNot(contains('  ')), reason: texto);
          expect(texto, texto.trim(), reason: 'espaço sobrando no início ou fim');
        }
      });
    });
  }
}
