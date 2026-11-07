import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sete_alegrias_de_maria/data/repositories/progresso_repository.dart';
import 'package:sete_alegrias_de_maria/features/configuracoes/application/idioma_controller.dart';

const _chave = 'config.idioma';

Future<ProviderContainer> _criar(Map<String, Object> valoresSalvos) async {
  SharedPreferences.setMockInitialValues(valoresSalvos);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('IdiomaController', () {
    test('sem nada salvo, retorna nulo (padrão automático do sistema)', () async {
      final container = await _criar({});
      expect(container.read(idiomaControllerProvider), isNull);
    });

    test('restaura o idioma forçado salvo no SharedPreferences', () async {
      final container = await _criar({_chave: 'es'});
      expect(container.read(idiomaControllerProvider), const Locale('es'));
      expect(container.read(codigoIdiomaProvider), 'es');
    });

    test('definirIdioma altera o estado e persiste nas preferências', () async {
      final container = await _criar({});
      final prefs = container.read(sharedPreferencesProvider);

      await container
          .read(idiomaControllerProvider.notifier)
          .definirIdioma(const Locale('es'));

      expect(container.read(idiomaControllerProvider), const Locale('es'));
      expect(prefs.getString(_chave), 'es');
      expect(container.read(codigoIdiomaProvider), 'es');
    });

    test('definirIdioma com null remove a preferência e volta para o padrão', () async {
      final container = await _criar({_chave: 'es'});
      final prefs = container.read(sharedPreferencesProvider);

      await container
          .read(idiomaControllerProvider.notifier)
          .definirIdioma(null);

      expect(container.read(idiomaControllerProvider), isNull);
      expect(prefs.getString(_chave), isNull);
    });
  });
}
