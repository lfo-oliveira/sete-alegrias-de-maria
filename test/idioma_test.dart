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
    test('sem nada salvo, usa o idioma padrão "pt"', () async {
      final container = await _criar({});
      expect(container.read(idiomaProvider), 'pt');
    });

    test('restaura o idioma salvo no SharedPreferences', () async {
      final container = await _criar({_chave: 'es'});
      expect(container.read(idiomaProvider), 'es');
    });

    test('definirIdioma altera o estado e persiste nas preferências', () async {
      final container = await _criar({});
      final prefs = container.read(sharedPreferencesProvider);

      await container.read(idiomaProvider.notifier).definirIdioma('es');

      expect(container.read(idiomaProvider), 'es');
      expect(prefs.getString(_chave), 'es');
    });
  });
}
